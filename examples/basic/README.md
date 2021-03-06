<!-- BEGIN_TF_DOCS -->
# Palo Alto Networks VM-Series NGFW Module Example for AWS Cloud

A Terraform module example for deploying a VM-Series NGFW in AWS Cloud using the [User Data](https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/bootstrap-the-vm-series-firewall/choose-a-bootstrap-method.html#idf6412176-e973-488e-9d7a-c568fe1e33a9_id3433e9c0-a589-40d5-b0bd-4bc42234aa0f) bootstrap method.

This example can be used to familarize oneself with both the VM-Series NGFW and Terraform - it creates two instances of virtualized firewalls in a Security VPC with three interfaces.

<p align="center">
  <img src="https://raw.githubusercontent.com/aws-ia/terraform-aws-paloalto-vmseries/main/images/vm_series.png" alt="Simple" width="100%">
</p>

For a more complex scenario of using the `vmseries` module check the rest of our [Examples](https://github.com/PaloAltoNetworks/terraform-aws-vmseries-modules/tree/develop/examples).

**NOTE:**
The Security Group attached to the Management interface uses an inbound rule allowing traffic to port `22` and `443` from `0.0.0.0/0`, which means that SSH and HTTP access to the NFGW is possible from all over the Internet. You should update the Security Group rules and limit access to the Management interface, for example - to only the public IP address from which you will connect to VM-Series.

## Usage

Create a `terraform.tfvars` file and copy the content of `example.tfvars.sample` into it, adjust if needed.

Then execute:

```sh
terraform init
terraform apply
terraform output -json mgmt_eip
```

Connect through SSH to the VM-Series Management interface IP address using the SSH key you provided as the  `ssh_key_name` parameter in your `terraform.tfvars` file:

```sh
ssh <username>@<mgmt_eip> -i <path_to_your_private_ssh_key>
```

## Cleanup

To delete all the resources created by the previous `apply` attempts, execute:

```sh
terraform destroy
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.74 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.74 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_security_subnet_sets"></a> [security\_subnet\_sets](#module\_security\_subnet\_sets) | PaloAltoNetworks/vmseries-modules/aws//modules/subnet_set | n/a |
| <a name="module_security_vpc"></a> [security\_vpc](#module\_security\_vpc) | PaloAltoNetworks/vmseries-modules/aws//modules/vpc | n/a |
| <a name="module_security_vpc_routes"></a> [security\_vpc\_routes](#module\_security\_vpc\_routes) | PaloAltoNetworks/vmseries-modules/aws//modules/vpc_route | n/a |
| <a name="module_vmseries"></a> [vmseries](#module\_vmseries) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.vmseries](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.vmseries](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bootstrap_options"></a> [bootstrap\_options](#input\_bootstrap\_options) | n/a | `any` | n/a | yes |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | n/a | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `any` | n/a | yes |
| <a name="input_security_vpc_cidr"></a> [security\_vpc\_cidr](#input\_security\_vpc\_cidr) | n/a | `any` | n/a | yes |
| <a name="input_security_vpc_name"></a> [security\_vpc\_name](#input\_security\_vpc\_name) | n/a | `any` | n/a | yes |
| <a name="input_security_vpc_routes_outbound_destin_cidrs"></a> [security\_vpc\_routes\_outbound\_destin\_cidrs](#input\_security\_vpc\_routes\_outbound\_destin\_cidrs) | n/a | `any` | n/a | yes |
| <a name="input_security_vpc_security_groups"></a> [security\_vpc\_security\_groups](#input\_security\_vpc\_security\_groups) | n/a | `any` | n/a | yes |
| <a name="input_security_vpc_subnets"></a> [security\_vpc\_subnets](#input\_security\_vpc\_subnets) | n/a | `any` | n/a | yes |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | n/a | `any` | n/a | yes |
| <a name="input_vmseries"></a> [vmseries](#input\_vmseries) | n/a | `any` | n/a | yes |
| <a name="input_vmseries_version"></a> [vmseries\_version](#input\_vmseries\_version) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_public_ips"></a> [public\_ips](#output\_public\_ips) | Map of public IPs created within the module. |
<!-- END_TF_DOCS -->
