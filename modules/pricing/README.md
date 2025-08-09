# AWS VPC Terraform Module

Terraform module which creates VPC resources on AWS. It takes an opinionated approach on dividing up
and configuring subnets. Resources have standardized tags which enable deployment of resources
into the VPC across multiple environments without having to specify VPC, subnet, or security group ids.

## Features

- Complete VPC with public, private, database, and non-routable subnets
- IPv4 and IPv6 support with proper CIDR allocation
- NAT Gateways with single or multi-AZ resilience options
- VPC Endpoints for S3, DynamoDB, and other AWS services
- Security Groups with predefined named rules for common services
- Flow logs with CloudWatch integration and KMS encryption
- Network ACLs with sensible defaults
- Database subnet groups for RDS deployment
- Support for IPAM pool allocation

## Usage

### Basic Example

```hcl
module "vpc" {
  source = "path/to/terraform-aws-vpc"

  name_prefix = "my-project"
  
  cidr_primary = "10.0.0.0/16"
  
  availability_zone_count = 3
  
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Complete Example

```hcl
module "vpc" {
  source = "path/to/terraform-aws-vpc"

  name_prefix = "complete"
  
  cidr_primary = "10.0.0.0/20"
  
  allowed_availability_zone_ids = ["us-west-2a", "us-west-2b", "us-west-2c"]
  availability_zone_count       = 3
  
  nat_gateway_enabled          = true
  resilient_natgateway_enabled = true
  create_database_route_table  = true
  
  enabled_databases = ["postgres", "redis"]
  enabled_caches    = ["redis", "memcached"]
  
  vpc_flow_logs_enabled = true
  
  tags = {
    Environment = "production"
    Project     = "complete-vpc-example"
    Owner       = "devops-team"
  }
}
```

## Requirements

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.3.0 |

## Modules

## Modules

No modules.

## Resources

## Resources

| Name | Type |
|------|------|
| [aws_pricing_product.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/pricing_product) | data source |
| [aws_pricing_product.cloudwatch_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/pricing_product) | data source |
| [aws_pricing_product.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/pricing_product) | data source |
| [aws_pricing_product.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/pricing_product) | data source |
| [aws_pricing_product.nat_gateway_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/pricing_product) | data source |
| [aws_pricing_product.vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/pricing_product) | data source |
| [aws_pricing_product.vpc_endpoint_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/pricing_product) | data source |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region_code"></a> [aws\_region\_code](#input\_aws\_region\_code) | AWS region code for pricing lookup (e.g., 'us-east-1') | `string` | n/a | yes |
| <a name="input_aws_region_display_name"></a> [aws\_region\_display\_name](#input\_aws\_region\_display\_name) | AWS region display name for pricing lookup (e.g., 'US East (N. Virginia)') | `string` | n/a | yes |
| <a name="input_create_vpc_flow_logs_kms_key"></a> [create\_vpc\_flow\_logs\_kms\_key](#input\_create\_vpc\_flow\_logs\_kms\_key) | Whether to create a customer-managed KMS key for VPC Flow Logs | `bool` | `true` | no |
| <a name="input_data_transfer_mb_per_hour"></a> [data\_transfer\_mb\_per\_hour](#input\_data\_transfer\_mb\_per\_hour) | Expected data transfer in MB per hour | `number` | `10` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| <a name="input_interface_endpoints_az_count"></a> [interface\_endpoints\_az\_count](#input\_interface\_endpoints\_az\_count) | Number of availability zones for interface endpoints (affects total endpoint hours) | `number` | `1` | no |
| <a name="input_interface_endpoints_count"></a> [interface\_endpoints\_count](#input\_interface\_endpoints\_count) | Number of interface endpoints to include in cost calculations | `number` | `0` | no |
| <a name="input_nat_gateway_count"></a> [nat\_gateway\_count](#input\_nat\_gateway\_count) | Number of NAT Gateways to include in cost calculations | `number` | `0` | no |
| <a name="input_vpc_flow_logs_enabled"></a> [vpc\_flow\_logs\_enabled](#input\_vpc\_flow\_logs\_enabled) | Whether VPC Flow Logs are enabled | `bool` | `false` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cost_breakdown"></a> [cost\_breakdown](#output\_cost\_breakdown) | Detailed breakdown of monthly costs by service |
| <a name="output_data_transfer_estimates"></a> [data\_transfer\_estimates](#output\_data\_transfer\_estimates) | Data transfer calculations |
| <a name="output_monthly_cost_estimate"></a> [monthly\_cost\_estimate](#output\_monthly\_cost\_estimate) | Total estimated monthly cost in USD for VPC resources |
| <a name="output_pricing_api_status"></a> [pricing\_api\_status](#output\_pricing\_api\_status) | Status of AWS Pricing API availability |
| <a name="output_pricing_rates"></a> [pricing\_rates](#output\_pricing\_rates) | Current AWS pricing rates used in calculations |
| <a name="output_resource_counts"></a> [resource\_counts](#output\_resource\_counts) | Count of billable resources |

## Security Groups

The module creates several security groups with predefined rules:

| Security Group | NetworkTags | Purpose | Ingress | Egress |
|----------------|-------------|---------|---------|--------|
| default-sg | private | Default security group | VPC traffic | HTTPS to internet, VPC traffic |
| lb-sg | public | Load balancer | HTTPS from internet | HTTPS to private/non-routable subnets |
| db-sg | database | Database services | Database ports from private/non-routable | None |
| cache-sg | cache | Cache services | Cache ports from private/non-routable | None |
| vpc-sg | vpconly | VPC-only traffic | VPC traffic | VPC traffic |
| endpoint-sg | endpoint | VPC endpoints | HTTPS from private/non-routable | None |

## Named Rules

The security group submodule includes predefined named rules for common services:

### Web Services
- `http` (80/tcp), `http-8080` (8080/tcp)
- `https` (443/tcp), `https-8443` (8443/tcp)

### Databases
- `mysql` (3306/tcp), `postgres` (5432/tcp), `oracle` (1521/tcp)
- `mssql` (1433/tcp), `mariadb` (3306/tcp), `db2` (50000/tcp)
- `neptune` (8182/tcp), `redshift` (5439/tcp), `documentdb` (27017/tcp)
- `timestream` (443/tcp), `qldb` (443/tcp), `dynamodb` (443/tcp)

### Cache Services
- `redis` (6379/tcp), `memcached` (11211/tcp)

### Messaging
- `activemq` (61617/tcp), `activemq-web` (8162/tcp)
- `rabbitmq` (5672/tcp), `rabbitmq-web` (15672/tcp)

### Monitoring & Analytics
- `opensearch` (443/tcp), `opensearch-dashboards` (5601/tcp)
- `prometheus` (9090/tcp), `grafana` (3000/tcp)

### Protocol Rules
- `all-all` (all protocols), `all-tcp` (all TCP), `all-udp` (all UDP)
- `all-icmp` (all ICMP), `all-icmpv6` (all ICMPv6)

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
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