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
# Main AWS provider - uses the current region
provider "aws" {
  # This is the default provider used for VPC resources
}

# Pricing provider - always uses us-east-1 where the AWS Pricing API is available
provider "aws" {
  alias  = "pricing"
  region = "us-east-1"
}

module "vpc" {
  source = "kbrockhoff/vpc/aws"

  providers = {
    aws         = aws
    aws.pricing = aws.pricing
  }

  name_prefix      = "vpc-example"
  cidr_primary     = "172.20.0.0/24"
  environment_type = "Development"
  
  tags = {
    Environment = "dev"
    Project     = "vpc-example"
  }
}
```

### Complete Example

```hcl
# Main AWS provider - uses the current region
provider "aws" {
  # This is the default provider used for VPC resources
}

# Pricing provider - always uses us-east-1 where the AWS Pricing API is available
provider "aws" {
  alias  = "pricing"
  region = "us-east-1"
}

module "vpc" {
  source = "kbrockhoff/vpc/aws"

  providers = {
    aws         = aws
    aws.pricing = aws.pricing
  }

  name_prefix      = "complete-example"
  cidr_primary     = "10.28.0.0/20"
  environment_type = "Production"
  
  # Specify which AZs to use (optional)
  allowed_availability_zone_ids = ["us-east-1c", "us-east-1d", "us-east-1f"]
  
  # Enable database subnet route table
  create_database_route_table = true
  
  # Enable cost estimation
  cost_estimation_config = {
    enabled                   = true
    data_transfer_mb_per_hour = 10
  }
  
  # VPC Endpoints
  gateway_endpoints   = ["s3", "dynamodb"]
  interface_endpoints = ["kms", "ec2", "ec2messages", "ssmmessages", "ssm", "logs"]
  
  tags = {
    Environment = "production"
    Project     = "complete-vpc-example"
    Owner       = "devops-team"
  }
}
```

## Environment Type Configuration

The `environment_type` variable provides a standardized way to configure resource defaults based on environment 
characteristics. This follows cloud well-architected framework recommendations for different deployment stages. 
Resiliency settings comply with the recovery point objective (RPO) and recovery time objective (RTO) values in
the table below. Cost optimization settings focus on shutting down resources during off-hours.

### Available Environment Types

| Type | Use Case | Configuration Focus | RPO | RTO |
|------|----------|---------------------|-----|-----|
| `None` | Custom configuration | No defaults applied, use individual config values | N/A | N/A |
| `Ephemeral` | Temporary environments | Cost-optimized, minimal durability requirements | N/A | 48h |
| `Development` | Developer workspaces | Balanced cost and functionality for active development | 24h | 48h |
| `Testing` | Automated testing | Consistent, repeatable configurations | 24h | 48h |
| `UAT` | User acceptance testing | Production-like settings with some cost optimization | 12h | 24h |
| `Production` | Live systems | High availability, durability, and performance | 1h  | 4h  |
| `MissionCritical` | Critical production | Maximum reliability, redundancy, and monitoring | 5m  | 1h  |

### Usage Examples

#### Development Environment
```hcl
module "dev_resources" {
  source = "path/to/terraform-module"
  
  name_prefix      = "dev-usw2"
  environment_type = "Development"
  
  tags = {
    Environment = "development"
    Team        = "platform"
  }
}
```

#### Production Environment
```hcl
module "prod_resources" {
  source = "path/to/terraform-module"
  
  name_prefix      = "prod-usw2"
  environment_type = "Production"
  
  tags = {
    Environment = "production"
    Team        = "platform"
    Backup      = "required"
  }
}
```

#### Custom Configuration (None)
```hcl
module "custom_resources" {
  source = "path/to/terraform-module"
  
  name_prefix      = "custom-usw2"
  environment_type = "None"
  
  # Specify all individual configuration values
  # when environment_type is "None"
}
```
## Network Tags Configuration

Resources deployed to subnets use lookup by `NetworkTags` values to determine which subnets to deploy to. 
This eliminates the need to manage different subnet IDs variable values for each environment.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_security_group"></a> [app\_security\_group](#module\_app\_security\_group) | ./modules/security-group | n/a |
| <a name="module_cache_security_group"></a> [cache\_security\_group](#module\_cache\_security\_group) | ./modules/security-group | n/a |
| <a name="module_db_security_group"></a> [db\_security\_group](#module\_db\_security\_group) | ./modules/security-group | n/a |
| <a name="module_endpoint_security_group"></a> [endpoint\_security\_group](#module\_endpoint\_security\_group) | ./modules/security-group | n/a |
| <a name="module_lb_security_group"></a> [lb\_security\_group](#module\_lb\_security\_group) | ./modules/security-group | n/a |
| <a name="module_pricing"></a> [pricing](#module\_pricing) | ./modules/pricing | n/a |
| <a name="module_subnets"></a> [subnets](#module\_subnets) | hashicorp/subnets/cidr | 1.0.0 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | ./modules/vpc-endpoints | n/a |
| <a name="module_vpc_security_group"></a> [vpc\_security\_group](#module\_vpc\_security\_group) | ./modules/security-group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.vpc_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_db_subnet_group.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_default_network_acl.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_route_table.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_ec2_transit_gateway_route_table_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_egress_only_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/egress_only_internet_gateway) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_elasticache_subnet_group.cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_flow_log.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_kms_alias.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_nat_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_egress_only_internet_gateway_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet_gateway_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.nonroutable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.nonroutable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_block_public_access_options.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_block_public_access_options) | resource |
| [aws_vpc_ipv4_cidr_block_association.nonroutable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Organization unique prefix to use for resource names. Recommend including environment and region. e.g. 'prod-usw2' | `string` | n/a | yes |
| <a name="input_allowed_availability_zone_ids"></a> [allowed\_availability\_zone\_ids](#input\_allowed\_availability\_zone\_ids) | List of allowed availability zone IDs. If empty, randomly select from all available AZs in the region.<br/><br/>Specify allowed AZs when you need to:<br/>- Support private endpoints to endpoint services in other AWS accounts (requires matching AZs)<br/>- Avoid cross-AZ data transfer charges by ensuring resources are co-located<br/>- Meet compliance requirements for data locality within specific AZs<br/>- Maintain consistency with existing infrastructure deployments<br/><br/>Use AZ IDs (e.g., use1-az1, use1-az2) rather than AZ names (e.g., us-east-1a, us-east-1b) <br/>to ensure consistent mapping across AWS accounts. | `list(string)` | `[]` | no |
| <a name="input_availability_zone_count"></a> [availability\_zone\_count](#input\_availability\_zone\_count) | Number of availability zones to use for private subnets | `number` | `2` | no |
| <a name="input_block_public_access_enabled"></a> [block\_public\_access\_enabled](#input\_block\_public\_access\_enabled) | Enable VPC block public access to prevent creation of public subnets and block bidirectional internet access | `bool` | `false` | no |
| <a name="input_cidr_primary"></a> [cidr\_primary](#input\_cidr\_primary) | The IPv4 CIDR block for the VPC | `string` | `"10.0.0.0/24"` | no |
| <a name="input_cost_estimation_config"></a> [cost\_estimation\_config](#input\_cost\_estimation\_config) | Configuration object for monthly cost estimation | <pre>object({<br/>    enabled                   = bool<br/>    data_transfer_mb_per_hour = number<br/>  })</pre> | <pre>{<br/>  "data_transfer_mb_per_hour": 10,<br/>  "enabled": true<br/>}</pre> | no |
| <a name="input_create_database_route_table"></a> [create\_database\_route\_table](#input\_create\_database\_route\_table) | Controls if separate route table for database should be created | `bool` | `false` | no |
| <a name="input_create_vpc_flow_logs_kms_key"></a> [create\_vpc\_flow\_logs\_kms\_key](#input\_create\_vpc\_flow\_logs\_kms\_key) | Set to true to create a customer-managed KMS key for encrypting VPC Flow Logs | `bool` | `true` | no |
| <a name="input_data_tags"></a> [data\_tags](#input\_data\_tags) | Additional tags to apply specifically to data storage resources (e.g., VPC Flow Logs, S3) beyond the common tags. | `map(string)` | `{}` | no |
| <a name="input_default_network_acl_egress"></a> [default\_network\_acl\_egress](#input\_default\_network\_acl\_egress) | List of maps of egress rules to set on the default network ACL | `list(map(string))` | <pre>[<br/>  {<br/>    "action": "allow",<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_no": 100,<br/>    "to_port": 0<br/>  },<br/>  {<br/>    "action": "allow",<br/>    "from_port": 0,<br/>    "ipv6_cidr_block": "::/0",<br/>    "protocol": "-1",<br/>    "rule_no": 101,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_default_network_acl_ingress"></a> [default\_network\_acl\_ingress](#input\_default\_network\_acl\_ingress) | List of maps of ingress rules to set on the default network ACL | `list(map(string))` | <pre>[<br/>  {<br/>    "action": "allow",<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_no": 100,<br/>    "to_port": 0<br/>  },<br/>  {<br/>    "action": "allow",<br/>    "from_port": 0,<br/>    "ipv6_cidr_block": "::/0",<br/>    "protocol": "-1",<br/>    "rule_no": 101,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_desired_database_subnet_count"></a> [desired\_database\_subnet\_count](#input\_desired\_database\_subnet\_count) | Number of database subnets to create | `number` | `2` | no |
| <a name="input_dns_hostnames_enabled"></a> [dns\_hostnames\_enabled](#input\_dns\_hostnames\_enabled) | Should be true to enable DNS hostnames in the VPC | `bool` | `true` | no |
| <a name="input_dns_support_enabled"></a> [dns\_support\_enabled](#input\_dns\_support\_enabled) | Should be true to enable DNS support in the VPC | `bool` | `true` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| <a name="input_enabled_caches"></a> [enabled\_caches](#input\_enabled\_caches) | List of cache types to enable security group rules for | `list(string)` | <pre>[<br/>  "redis"<br/>]</pre> | no |
| <a name="input_enabled_databases"></a> [enabled\_databases](#input\_enabled\_databases) | List of database types to enable security group rules for | `list(string)` | <pre>[<br/>  "postgres"<br/>]</pre> | no |
| <a name="input_endpoint_default_policy"></a> [endpoint\_default\_policy](#input\_endpoint\_default\_policy) | Default policy (JSON string) to apply to all VPC endpoints when endpoint\_default\_policy\_enabled is true | `string` | `null` | no |
| <a name="input_endpoint_default_policy_enabled"></a> [endpoint\_default\_policy\_enabled](#input\_endpoint\_default\_policy\_enabled) | Enable default restrictive policy for all VPC endpoints | `bool` | `false` | no |
| <a name="input_endpoint_policies"></a> [endpoint\_policies](#input\_endpoint\_policies) | Map of service names to their custom endpoint policies | `map(string)` | `{}` | no |
| <a name="input_endpoint_policy_enabled"></a> [endpoint\_policy\_enabled](#input\_endpoint\_policy\_enabled) | Enable custom endpoint policies | `bool` | `false` | no |
| <a name="input_endpoint_private_dns_enabled"></a> [endpoint\_private\_dns\_enabled](#input\_endpoint\_private\_dns\_enabled) | Enable private DNS for Interface endpoints | `bool` | `true` | no |
| <a name="input_environment_type"></a> [environment\_type](#input\_environment\_type) | Environment type for resource configuration defaults. Select 'None' to use individual config values. | `string` | `"Development"` | no |
| <a name="input_gateway_endpoints"></a> [gateway\_endpoints](#input\_gateway\_endpoints) | List of AWS service names for Gateway endpoints (S3, DynamoDB) | `list(string)` | <pre>[<br/>  "s3",<br/>  "dynamodb"<br/>]</pre> | no |
| <a name="input_igw_enabled"></a> [igw\_enabled](#input\_igw\_enabled) | Controls if an Internet Gateway is created for public subnets | `bool` | `true` | no |
| <a name="input_instance_tenancy"></a> [instance\_tenancy](#input\_instance\_tenancy) | A tenancy option for instances launched into the VPC | `string` | `"default"` | no |
| <a name="input_interface_endpoints"></a> [interface\_endpoints](#input\_interface\_endpoints) | List of AWS service names for Interface endpoints (e.g., ec2, ssm, logs) | `list(string)` | `[]` | no |
| <a name="input_ipam_pool_enabled"></a> [ipam\_pool\_enabled](#input\_ipam\_pool\_enabled) | Enable IPAM pool for VPC CIDR allocation | `bool` | `false` | no |
| <a name="input_ipv4_ipam_pool_id"></a> [ipv4\_ipam\_pool\_id](#input\_ipv4\_ipam\_pool\_id) | The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR | `string` | `null` | no |
| <a name="input_ipv4_netmask_length"></a> [ipv4\_netmask\_length](#input\_ipv4\_netmask\_length) | The netmask length of the IPv4 CIDR you want to allocate to this VPC | `number` | `24` | no |
| <a name="input_ipv6_enabled"></a> [ipv6\_enabled](#input\_ipv6\_enabled) | Enable IPv6 support for VPC and subnets | `bool` | `true` | no |
| <a name="input_ipv6_ipam_pool_enabled"></a> [ipv6\_ipam\_pool\_enabled](#input\_ipv6\_ipam\_pool\_enabled) | Enable IPv6 IPAM pool for VPC CIDR allocation | `bool` | `false` | no |
| <a name="input_ipv6_ipam_pool_id"></a> [ipv6\_ipam\_pool\_id](#input\_ipv6\_ipam\_pool\_id) | The ID of an IPv6 IPAM pool you want to use for allocating this VPC's CIDR | `string` | `null` | no |
| <a name="input_ipv6_netmask_length"></a> [ipv6\_netmask\_length](#input\_ipv6\_netmask\_length) | The netmask length of the IPv6 CIDR you want to allocate to this VPC | `number` | `56` | no |
| <a name="input_nat_gateway_enabled"></a> [nat\_gateway\_enabled](#input\_nat\_gateway\_enabled) | Should be true if you want to provision NAT Gateways for each of your private networks | `bool` | `true` | no |
| <a name="input_networktags_name"></a> [networktags\_name](#input\_networktags\_name) | Name of the network tags key used for subnet classification | `string` | `"NetworkTags"` | no |
| <a name="input_networktags_value_vpc"></a> [networktags\_value\_vpc](#input\_networktags\_value\_vpc) | Value to assign to the network tags key for the VPC and only the VPC. Use the default unless you have a specific reason to change it. | `string` | `"standard"` | no |
| <a name="input_nonroutable_subnets_enabled"></a> [nonroutable\_subnets\_enabled](#input\_nonroutable\_subnets\_enabled) | Enable creation of non-routable subnets for EKS pods | `bool` | `true` | no |
| <a name="input_resilient_natgateway_enabled"></a> [resilient\_natgateway\_enabled](#input\_resilient\_natgateway\_enabled) | Enable resilient NAT Gateway deployment (one per public subnet for high availability). If false, provisions a single NAT Gateway. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags/labels to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_transit_gateway_attachment_enabled"></a> [transit\_gateway\_attachment\_enabled](#input\_transit\_gateway\_attachment\_enabled) | Enable attachment of VPC to a Transit Gateway | `bool` | `false` | no |
| <a name="input_transit_gateway_attachment_subnets"></a> [transit\_gateway\_attachment\_subnets](#input\_transit\_gateway\_attachment\_subnets) | Subnet types to use for Transit Gateway attachment. Options: private, database | `string` | `"private"` | no |
| <a name="input_transit_gateway_default_route_table_association"></a> [transit\_gateway\_default\_route\_table\_association](#input\_transit\_gateway\_default\_route\_table\_association) | Enable association with the Transit Gateway default route table | `bool` | `true` | no |
| <a name="input_transit_gateway_default_route_table_propagation"></a> [transit\_gateway\_default\_route\_table\_propagation](#input\_transit\_gateway\_default\_route\_table\_propagation) | Enable route propagation to the Transit Gateway default route table | `bool` | `true` | no |
| <a name="input_transit_gateway_id"></a> [transit\_gateway\_id](#input\_transit\_gateway\_id) | ID of the Transit Gateway to attach the VPC to | `string` | `null` | no |
| <a name="input_transit_gateway_route_table_id"></a> [transit\_gateway\_route\_table\_id](#input\_transit\_gateway\_route\_table\_id) | ID of the Transit Gateway route table to associate with the attachment | `string` | `null` | no |
| <a name="input_vpc_flow_logs_custom_format"></a> [vpc\_flow\_logs\_custom\_format](#input\_vpc\_flow\_logs\_custom\_format) | Custom format for VPC Flow Logs. If null, default format will be used | `string` | `null` | no |
| <a name="input_vpc_flow_logs_enabled"></a> [vpc\_flow\_logs\_enabled](#input\_vpc\_flow\_logs\_enabled) | Enable VPC Flow Logs | `bool` | `false` | no |
| <a name="input_vpc_flow_logs_kms_key_id"></a> [vpc\_flow\_logs\_kms\_key\_id](#input\_vpc\_flow\_logs\_kms\_key\_id) | KMS Key ID for encrypting VPC Flow Logs. If null, a customer-managed key will be created | `string` | `null` | no |
| <a name="input_vpc_flow_logs_retention_days"></a> [vpc\_flow\_logs\_retention\_days](#input\_vpc\_flow\_logs\_retention\_days) | Number of days to retain VPC Flow Logs in CloudWatch | `number` | `30` | no |
| <a name="input_vpc_flow_logs_traffic_type"></a> [vpc\_flow\_logs\_traffic\_type](#input\_vpc\_flow\_logs\_traffic\_type) | Type of traffic to capture in VPC Flow Logs | `string` | `"ALL"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all_endpoint_ids"></a> [all\_endpoint\_ids](#output\_all\_endpoint\_ids) | Map of all endpoint service names to their IDs |
| <a name="output_all_security_group_ids"></a> [all\_security\_group\_ids](#output\_all\_security\_group\_ids) | List of all security group IDs |
| <a name="output_app_security_group_id"></a> [app\_security\_group\_id](#output\_app\_security\_group\_id) | ID of the application security group |
| <a name="output_azs"></a> [azs](#output\_azs) | A list of availability zones specified as argument to this module |
| <a name="output_block_public_access_enabled"></a> [block\_public\_access\_enabled](#output\_block\_public\_access\_enabled) | Whether VPC block public access is enabled, preventing creation of public subnets and internet gateways |
| <a name="output_cache_security_group_id"></a> [cache\_security\_group\_id](#output\_cache\_security\_group\_id) | ID of the cache security group |
| <a name="output_cache_subnet_group"></a> [cache\_subnet\_group](#output\_cache\_subnet\_group) | ID of cache subnet group |
| <a name="output_cache_subnet_group_name"></a> [cache\_subnet\_group\_name](#output\_cache\_subnet\_group\_name) | Name of cache subnet group |
| <a name="output_cost_breakdown"></a> [cost\_breakdown](#output\_cost\_breakdown) | Detailed breakdown of monthly costs by service |
| <a name="output_database_route_table_ids"></a> [database\_route\_table\_ids](#output\_database\_route\_table\_ids) | List of IDs of the database route tables |
| <a name="output_database_subnet_arns"></a> [database\_subnet\_arns](#output\_database\_subnet\_arns) | List of ARNs of database subnets |
| <a name="output_database_subnet_availability_zone_ids"></a> [database\_subnet\_availability\_zone\_ids](#output\_database\_subnet\_availability\_zone\_ids) | List of availability zone IDs for database subnets |
| <a name="output_database_subnet_availability_zones"></a> [database\_subnet\_availability\_zones](#output\_database\_subnet\_availability\_zones) | List of availability zone names for database subnets |
| <a name="output_database_subnet_group"></a> [database\_subnet\_group](#output\_database\_subnet\_group) | ID of database subnet group |
| <a name="output_database_subnet_group_name"></a> [database\_subnet\_group\_name](#output\_database\_subnet\_group\_name) | Name of database subnet group |
| <a name="output_database_subnets"></a> [database\_subnets](#output\_database\_subnets) | List of IDs of database subnets |
| <a name="output_database_subnets_cidr_blocks"></a> [database\_subnets\_cidr\_blocks](#output\_database\_subnets\_cidr\_blocks) | List of cidr\_blocks of database subnets |
| <a name="output_database_subnets_ipv6_cidr_blocks"></a> [database\_subnets\_ipv6\_cidr\_blocks](#output\_database\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 CIDR blocks assigned to the database subnets |
| <a name="output_db_security_group_id"></a> [db\_security\_group\_id](#output\_db\_security\_group\_id) | ID of the database security group |
| <a name="output_default_network_acl_id"></a> [default\_network\_acl\_id](#output\_default\_network\_acl\_id) | The ID of the default network ACL |
| <a name="output_default_route_table_id"></a> [default\_route\_table\_id](#output\_default\_route\_table\_id) | The ID of the default route table |
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | The ID of the security group created by default on VPC creation |
| <a name="output_eigw_id"></a> [eigw\_id](#output\_eigw\_id) | The ID of the Egress-Only Internet Gateway |
| <a name="output_endpoint_count"></a> [endpoint\_count](#output\_endpoint\_count) | Total number of VPC endpoints created |
| <a name="output_endpoint_security_group_id"></a> [endpoint\_security\_group\_id](#output\_endpoint\_security\_group\_id) | ID of the endpoint security group |
| <a name="output_environment_config"></a> [environment\_config](#output\_environment\_config) | Effective environment configuration applied |
| <a name="output_environment_type"></a> [environment\_type](#output\_environment\_type) | Environment type used for configuration defaults |
| <a name="output_gateway_endpoint_ids"></a> [gateway\_endpoint\_ids](#output\_gateway\_endpoint\_ids) | Map of service names to their Gateway endpoint IDs |
| <a name="output_igw_arn"></a> [igw\_arn](#output\_igw\_arn) | The ARN of the Internet Gateway |
| <a name="output_igw_id"></a> [igw\_id](#output\_igw\_id) | The ID of the Internet Gateway |
| <a name="output_interface_endpoint_ids"></a> [interface\_endpoint\_ids](#output\_interface\_endpoint\_ids) | Map of service names to their Interface endpoint IDs |
| <a name="output_lb_security_group_id"></a> [lb\_security\_group\_id](#output\_lb\_security\_group\_id) | ID of the load balancer security group |
| <a name="output_managed_default_network_acl_id"></a> [managed\_default\_network\_acl\_id](#output\_managed\_default\_network\_acl\_id) | The ID of the managed default network ACL |
| <a name="output_managed_default_route_table_id"></a> [managed\_default\_route\_table\_id](#output\_managed\_default\_route\_table\_id) | The ID of the managed default route table |
| <a name="output_monthly_cost_estimate"></a> [monthly\_cost\_estimate](#output\_monthly\_cost\_estimate) | Estimated monthly cost in USD for VPC resources |
| <a name="output_nat_ids"></a> [nat\_ids](#output\_nat\_ids) | List of IDs of the NAT Gateways |
| <a name="output_nat_public_ips"></a> [nat\_public\_ips](#output\_nat\_public\_ips) | List of public Elastic IPs created for AWS NAT Gateway |
| <a name="output_natgw_ids"></a> [natgw\_ids](#output\_natgw\_ids) | List of IDs of the NAT Gateways |
| <a name="output_nonroutable_subnet_arns"></a> [nonroutable\_subnet\_arns](#output\_nonroutable\_subnet\_arns) | List of ARNs of non-routable subnets |
| <a name="output_nonroutable_subnet_availability_zone_ids"></a> [nonroutable\_subnet\_availability\_zone\_ids](#output\_nonroutable\_subnet\_availability\_zone\_ids) | List of availability zone IDs for non-routable subnets |
| <a name="output_nonroutable_subnet_availability_zones"></a> [nonroutable\_subnet\_availability\_zones](#output\_nonroutable\_subnet\_availability\_zones) | List of availability zone names for non-routable subnets |
| <a name="output_nonroutable_subnets"></a> [nonroutable\_subnets](#output\_nonroutable\_subnets) | List of IDs of non-routable subnets |
| <a name="output_nonroutable_subnets_cidr_blocks"></a> [nonroutable\_subnets\_cidr\_blocks](#output\_nonroutable\_subnets\_cidr\_blocks) | List of cidr\_blocks of non-routable subnets |
| <a name="output_nonroutable_subnets_ipv6_cidr_blocks"></a> [nonroutable\_subnets\_ipv6\_cidr\_blocks](#output\_nonroutable\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 CIDR blocks assigned to the non-routable subnets |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | List of IDs of the private route tables |
| <a name="output_private_subnet_arns"></a> [private\_subnet\_arns](#output\_private\_subnet\_arns) | List of ARNs of private subnets |
| <a name="output_private_subnet_availability_zone_ids"></a> [private\_subnet\_availability\_zone\_ids](#output\_private\_subnet\_availability\_zone\_ids) | List of availability zone IDs for private subnets |
| <a name="output_private_subnet_availability_zones"></a> [private\_subnet\_availability\_zones](#output\_private\_subnet\_availability\_zones) | List of availability zone names for private subnets |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of IDs of private subnets |
| <a name="output_private_subnets_cidr_blocks"></a> [private\_subnets\_cidr\_blocks](#output\_private\_subnets\_cidr\_blocks) | List of cidr\_blocks of private subnets |
| <a name="output_private_subnets_ipv6_cidr_blocks"></a> [private\_subnets\_ipv6\_cidr\_blocks](#output\_private\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 CIDR blocks assigned to the private subnets |
| <a name="output_public_route_table_ids"></a> [public\_route\_table\_ids](#output\_public\_route\_table\_ids) | List of IDs of the public route tables |
| <a name="output_public_subnet_arns"></a> [public\_subnet\_arns](#output\_public\_subnet\_arns) | List of ARNs of public subnets |
| <a name="output_public_subnet_availability_zone_ids"></a> [public\_subnet\_availability\_zone\_ids](#output\_public\_subnet\_availability\_zone\_ids) | List of availability zone IDs for public subnets |
| <a name="output_public_subnet_availability_zones"></a> [public\_subnet\_availability\_zones](#output\_public\_subnet\_availability\_zones) | List of availability zone names for public subnets |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of IDs of public subnets |
| <a name="output_public_subnets_cidr_blocks"></a> [public\_subnets\_cidr\_blocks](#output\_public\_subnets\_cidr\_blocks) | List of cidr\_blocks of public subnets |
| <a name="output_public_subnets_ipv6_cidr_blocks"></a> [public\_subnets\_ipv6\_cidr\_blocks](#output\_public\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 CIDR blocks assigned to the public subnets |
| <a name="output_transit_gateway_attachment_id"></a> [transit\_gateway\_attachment\_id](#output\_transit\_gateway\_attachment\_id) | ID of the Transit Gateway VPC attachment |
| <a name="output_transit_gateway_attachment_vpc_owner_id"></a> [transit\_gateway\_attachment\_vpc\_owner\_id](#output\_transit\_gateway\_attachment\_vpc\_owner\_id) | VPC owner ID of the Transit Gateway VPC attachment |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | The ARN of the VPC |
| <a name="output_vpc_block_public_access_options_internet_gateway_block_mode"></a> [vpc\_block\_public\_access\_options\_internet\_gateway\_block\_mode](#output\_vpc\_block\_public\_access\_options\_internet\_gateway\_block\_mode) | The internet gateway block mode for VPC block public access options |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_dns_hostnames_enabled"></a> [vpc\_dns\_hostnames\_enabled](#output\_vpc\_dns\_hostnames\_enabled) | Whether or not the VPC has DNS hostname support |
| <a name="output_vpc_dns_support_enabled"></a> [vpc\_dns\_support\_enabled](#output\_vpc\_dns\_support\_enabled) | Whether or not the VPC has DNS support |
| <a name="output_vpc_flow_logs_iam_role_arn"></a> [vpc\_flow\_logs\_iam\_role\_arn](#output\_vpc\_flow\_logs\_iam\_role\_arn) | ARN of the IAM role used for VPC Flow Logs |
| <a name="output_vpc_flow_logs_id"></a> [vpc\_flow\_logs\_id](#output\_vpc\_flow\_logs\_id) | ID of the VPC Flow Log |
| <a name="output_vpc_flow_logs_kms_key_arn"></a> [vpc\_flow\_logs\_kms\_key\_arn](#output\_vpc\_flow\_logs\_kms\_key\_arn) | ARN of the KMS key used for VPC Flow Logs encryption |
| <a name="output_vpc_flow_logs_kms_key_id"></a> [vpc\_flow\_logs\_kms\_key\_id](#output\_vpc\_flow\_logs\_kms\_key\_id) | ID of the KMS key used for VPC Flow Logs encryption |
| <a name="output_vpc_flow_logs_log_group_arn"></a> [vpc\_flow\_logs\_log\_group\_arn](#output\_vpc\_flow\_logs\_log\_group\_arn) | ARN of the CloudWatch Log Group for VPC Flow Logs |
| <a name="output_vpc_flow_logs_log_group_name"></a> [vpc\_flow\_logs\_log\_group\_name](#output\_vpc\_flow\_logs\_log\_group\_name) | Name of the CloudWatch Log Group for VPC Flow Logs |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC |
| <a name="output_vpc_instance_tenancy"></a> [vpc\_instance\_tenancy](#output\_vpc\_instance\_tenancy) | Tenancy of instances spin up within VPC |
| <a name="output_vpc_ipv6_cidr_block"></a> [vpc\_ipv6\_cidr\_block](#output\_vpc\_ipv6\_cidr\_block) | The IPv6 CIDR block of the VPC |
| <a name="output_vpc_security_group_id"></a> [vpc\_security\_group\_id](#output\_vpc\_security\_group\_id) | ID of the VPC-only security group |
<!-- END_TF_DOCS -->    

## License

This project is licensed under the Apache License, Version 2.0 - see the [LICENSE](LICENSE) file for details.
