resource "aws_kms_key" "vmseries" {
  description         = "vmseries disk encryption key"
  enable_key_rotation = true
}

resource "aws_kms_alias" "vmseries" {
  name          = "alias/vmseries"
  target_key_id = aws_kms_key.vmseries.key_id
}


module "security_vpc" {
  source = "PaloAltoNetworks/vmseries-modules/aws//modules/vpc"

  name                    = var.security_vpc_name
  cidr_block              = var.security_vpc_cidr
  security_groups         = var.security_vpc_security_groups
  create_internet_gateway = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  instance_tenancy        = "default"
}

module "security_subnet_sets" {
  source = "PaloAltoNetworks/vmseries-modules/aws//modules/subnet_set"

  for_each = toset(distinct([for _, v in var.security_vpc_subnets : v.set]))

  name                = each.key
  vpc_id              = module.security_vpc.id
  has_secondary_cidrs = module.security_vpc.has_secondary_cidrs
  cidrs               = { for k, v in var.security_vpc_subnets : k => v if v.set == each.key }
}

module "vmseries" {
  for_each = var.vmseries
  source   = "../../"

  name              = var.name
  ssh_key_name      = var.ssh_key_name
  bootstrap_options = var.bootstrap_options
  ebs_kms_key_alias = aws_kms_alias.vmseries.name

  interfaces = {
    mgmt = {
      device_index       = 0
      security_group_ids = [module.security_vpc.security_group_ids["vmseries_mgmt"]]
      source_dest_check  = true
      subnet_id          = module.security_subnet_sets["mgmt"].subnets[each.value.az].id
      create_public_ip   = true
    }
    public = {
      device_index       = 1
      security_group_ids = [module.security_vpc.security_group_ids["vmseries_public"]]
      source_dest_check  = false
      subnet_id          = module.security_subnet_sets["public"].subnets[each.value.az].id
      create_public_ip   = true
    }
    private = {
      device_index       = 2
      security_group_ids = [module.security_vpc.security_group_ids["vmseries_private"]]
      source_dest_check  = false
      subnet_id          = module.security_subnet_sets["private"].subnets[each.value.az].id
      create_public_ip   = false
    }
  }

  tags = var.global_tags

  depends_on = [
    aws_kms_alias.vmseries
  ]
}

locals {
  security_vpc_routes = concat(
    [for cidr in var.security_vpc_routes_outbound_destin_cidrs :
      {
        subnet_key   = "mgmt"
        next_hop_set = module.security_vpc.igw_as_next_hop_set
        to_cidr      = cidr
      }
    ],
    [
      for cidr in var.security_vpc_routes_outbound_destin_cidrs :
      {
        subnet_key   = "public"
        next_hop_set = module.security_vpc.igw_as_next_hop_set
        to_cidr      = cidr
      }
    ],
  )
}

module "security_vpc_routes" {
  for_each = { for route in local.security_vpc_routes : "${route.subnet_key}_${route.to_cidr}" => route }
  source   = "PaloAltoNetworks/vmseries-modules/aws//modules/vpc_route"

  route_table_ids = module.security_subnet_sets[each.value.subnet_key].unique_route_table_ids
  to_cidr         = each.value.to_cidr
  next_hop_set    = each.value.next_hop_set
}
