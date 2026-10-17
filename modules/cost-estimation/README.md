# Cost Estimation Terraform Module

Estimates the monthly on-demand cost in USD of the resources the parent VPC module provisions,
using live prices from the AWS Pricing API.

The parent passes a provider pinned to `us-east-1`, where the Pricing API is available, and the
`region` it deploys to. Each price is looked up by `regionCode` with filters validated to match
exactly one product in every region.

## Components

| Key | Priced as | Quantity from the parent |
|-----|-----------|--------------------------|
| `nat_gateway_hours` | zonal NAT gateway hours | NAT gateways x 730 hours |
| `nat_gateway_data` | NAT gateway data processed per GB | `data_transfer_mb_per_hour` x 730 / 1024, minus the interface endpoint share |
| `public_ipv4_addresses` | in-use public IPv4 address hours | one Elastic IP per NAT gateway x 730 hours |
| `interface_endpoint_hours` | interface (PrivateLink) endpoint hours per AZ | interface endpoints x endpoint subnets x 730 hours |
| `interface_endpoint_data` | interface endpoint data processed per GB | `data_transfer_mb_per_hour` x 730 / 1024 x `vpc_endpoint_traffic_percent` / 100 |
| `flow_logs_ingestion` | vended logs delivered to CloudWatch Logs per GB | `cost_estimation_config.flow_logs_gb_per_month` |
| `flow_logs_storage` | CloudWatch Logs storage per GB-month | flow logs GB per month x retention days / 30 |
| `kms_keys` | customer managed KMS key per month | 1 when the module creates the flow logs key |
| `transit_gateway_attachment_hours` | transit gateway VPC attachment hours | 1 attachment x 730 hours when enabled |

Gateway endpoints (S3, DynamoDB), the VPC, subnets, route tables, security groups and IAM are free.

## Assumptions

- On-demand prices only; no Savings Plans or account free tiers (such as the 5 GB of free
  CloudWatch Logs ingestion and storage).
- Always-on resources run 730 hours per month.
- Tiered prices (interface endpoint data, vended log ingestion) use the lowest paid tier.
- `data_transfer_mb_per_hour` is the combined traffic through NAT gateways and interface
  endpoints. When both exist, `vpc_endpoint_traffic_percent` (default 50) of it is priced as
  endpoint data and the rest as NAT data; when only one exists, it carries all the traffic.
- Flow log storage is the steady state after one retention period, uncompressed; transit
  gateway data processing, KMS requests and Logs Insights queries are not estimated.
- If a price can't be parsed, a us-east-1 default is used instead.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.69.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_region"></a> [region](#input\_region) | AWS region where the parent module deploys its resources, e.g. us-west-2 | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| <a name="input_flow_logs_ingestion_gb"></a> [flow\_logs\_ingestion\_gb](#input\_flow\_logs\_ingestion\_gb) | GB of VPC flow logs delivered to CloudWatch Logs per month | `number` | `0` | no |
| <a name="input_flow_logs_storage_gb"></a> [flow\_logs\_storage\_gb](#input\_flow\_logs\_storage\_gb) | GB of VPC flow logs stored in CloudWatch Logs (average over the month) | `number` | `0` | no |
| <a name="input_interface_endpoint_az_count"></a> [interface\_endpoint\_az\_count](#input\_interface\_endpoint\_az\_count) | Number of interface VPC endpoint AZ placements (interface endpoints x subnets), each billed 730 hours per month | `number` | `0` | no |
| <a name="input_interface_endpoint_data_gb"></a> [interface\_endpoint\_data\_gb](#input\_interface\_endpoint\_data\_gb) | GB of data processed by all interface VPC endpoints per month | `number` | `0` | no |
| <a name="input_kms_key_count"></a> [kms\_key\_count](#input\_kms\_key\_count) | Number of customer managed KMS keys | `number` | `0` | no |
| <a name="input_nat_gateway_count"></a> [nat\_gateway\_count](#input\_nat\_gateway\_count) | Number of NAT gateways, each billed 730 hours per month | `number` | `0` | no |
| <a name="input_nat_gateway_data_gb"></a> [nat\_gateway\_data\_gb](#input\_nat\_gateway\_data\_gb) | GB of data processed by all NAT gateways per month | `number` | `0` | no |
| <a name="input_public_ipv4_address_count"></a> [public\_ipv4\_address\_count](#input\_public\_ipv4\_address\_count) | Number of in-use public IPv4 addresses (e.g. NAT gateway Elastic IPs), each billed 730 hours per month | `number` | `0` | no |
| <a name="input_transit_gateway_attachment_count"></a> [transit\_gateway\_attachment\_count](#input\_transit\_gateway\_attachment\_count) | Number of transit gateway VPC attachments, each billed 730 hours per month | `number` | `0` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cost_breakdown"></a> [cost\_breakdown](#output\_cost\_breakdown) | Detailed breakdown of monthly costs by service |
| <a name="output_monthly_cost_estimate"></a> [monthly\_cost\_estimate](#output\_monthly\_cost\_estimate) | Total estimated monthly cost in USD for module resources |
<!-- END_TF_DOCS -->
