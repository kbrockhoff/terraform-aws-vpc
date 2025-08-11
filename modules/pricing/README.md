# Cost Estimation Terraform Module

Estimates the monthly cost of resources provisioned by the parent module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_create_vpc_flow_logs_kms_key"></a> [create\_vpc\_flow\_logs\_kms\_key](#input\_create\_vpc\_flow\_logs\_kms\_key) | Whether to create a customer-managed KMS key for VPC Flow Logs | `bool` | `true` | no |
| <a name="input_data_transfer_mb_per_hour"></a> [data\_transfer\_mb\_per\_hour](#input\_data\_transfer\_mb\_per\_hour) | Expected data transfer in MB per hour | `number` | `10` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| <a name="input_interface_endpoints_az_count"></a> [interface\_endpoints\_az\_count](#input\_interface\_endpoints\_az\_count) | Number of availability zones for interface endpoints (affects total endpoint hours) | `number` | `1` | no |
| <a name="input_interface_endpoints_count"></a> [interface\_endpoints\_count](#input\_interface\_endpoints\_count) | Number of interface endpoints to include in cost calculations | `number` | `0` | no |
| <a name="input_nat_gateway_count"></a> [nat\_gateway\_count](#input\_nat\_gateway\_count) | Number of NAT Gateways to include in cost calculations | `number` | `0` | no |
| <a name="input_vpc_flow_logs_enabled"></a> [vpc\_flow\_logs\_enabled](#input\_vpc\_flow\_logs\_enabled) | Whether VPC Flow Logs are enabled | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cost_breakdown"></a> [cost\_breakdown](#output\_cost\_breakdown) | Detailed breakdown of monthly costs by service |
| <a name="output_data_transfer_estimates"></a> [data\_transfer\_estimates](#output\_data\_transfer\_estimates) | Data transfer calculations |
| <a name="output_monthly_cost_estimate"></a> [monthly\_cost\_estimate](#output\_monthly\_cost\_estimate) | Total estimated monthly cost in USD for VPC resources |
| <a name="output_pricing_api_status"></a> [pricing\_api\_status](#output\_pricing\_api\_status) | Status of AWS Pricing API availability |
| <a name="output_pricing_rates"></a> [pricing\_rates](#output\_pricing\_rates) | Current AWS pricing rates used in calculations |
| <a name="output_resource_counts"></a> [resource\_counts](#output\_resource\_counts) | Count of billable resources |
<!-- END_TF_DOCS -->
