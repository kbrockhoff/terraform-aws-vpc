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
| [aws_iam_policy.vpc_management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.vpc_management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_openid_connect_provider.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID | `string` | n/a | yes |
| <a name="input_github_branch"></a> [github\_branch](#input\_github\_branch) | GitHub branch name for OIDC trust | `string` | `"*"` | no |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | GitHub organization name | `string` | n/a | yes |
| <a name="input_github_repo"></a> [github\_repo](#input\_github\_repo) | GitHub repository name | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Organization unique prefix to use for resource names. Recommend including environment and region. e.g. 'prod-usw2'. | `string` | n/a | yes |
| <a name="input_partition"></a> [partition](#input\_partition) | AWS partition | `string` | `"aws"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags/labels to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_actions_role_arn"></a> [github\_actions\_role\_arn](#output\_github\_actions\_role\_arn) | ARN of the GitHub Actions IAM role |
| <a name="output_github_actions_role_name"></a> [github\_actions\_role\_name](#output\_github\_actions\_role\_name) | Name of the GitHub Actions IAM role |
| <a name="output_vpc_management_policy_arn"></a> [vpc\_management\_policy\_arn](#output\_vpc\_management\_policy\_arn) | ARN of the VPC management policy |
| <a name="output_vpc_management_policy_name"></a> [vpc\_management\_policy\_name](#output\_vpc\_management\_policy\_name) | Name of the VPC management policy |

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
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
| [aws_iam_policy.aws_services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ec2_describe](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.iam_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.vpc_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.vpc_networking](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.aws_services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ec2_describe](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.iam_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.vpc_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.vpc_networking](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID | `string` | n/a | yes |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | GitHub organization name | `string` | n/a | yes |
| <a name="input_github_repo"></a> [github\_repo](#input\_github\_repo) | GitHub repository name | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Organization unique prefix to use for resource names. Recommend including environment and region. e.g. 'prod-usw2'. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_s3_backend_bucket"></a> [s3\_backend\_bucket](#input\_s3\_backend\_bucket) | S3 bucket name for Terraform state backend | `string` | n/a | yes |
| <a name="input_s3_backend_lock_table"></a> [s3\_backend\_lock\_table](#input\_s3\_backend\_lock\_table) | DynamoDB table name for Terraform state locking | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name for OIDC trust (e.g., 'development', 'staging', 'production') | `string` | `"*"` | no |
| <a name="input_partition"></a> [partition](#input\_partition) | AWS partition | `string` | `"aws"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags/labels to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_services_policy_arn"></a> [aws\_services\_policy\_arn](#output\_aws\_services\_policy\_arn) | ARN of the AWS services policy |
| <a name="output_ec2_describe_policy_arn"></a> [ec2\_describe\_policy\_arn](#output\_ec2\_describe\_policy\_arn) | ARN of the EC2 describe policy |
| <a name="output_github_actions_role_arn"></a> [github\_actions\_role\_arn](#output\_github\_actions\_role\_arn) | ARN of the GitHub Actions IAM role |
| <a name="output_github_actions_role_name"></a> [github\_actions\_role\_name](#output\_github\_actions\_role\_name) | Name of the GitHub Actions IAM role |
| <a name="output_iam_kms_policy_arn"></a> [iam\_kms\_policy\_arn](#output\_iam\_kms\_policy\_arn) | ARN of the IAM and KMS management policy |
| <a name="output_policy_arns"></a> [policy\_arns](#output\_policy\_arns) | List of all policy ARNs attached to the GitHub Actions role |
| <a name="output_vpc_core_policy_arn"></a> [vpc\_core\_policy\_arn](#output\_vpc\_core\_policy\_arn) | ARN of the VPC core management policy |
| <a name="output_vpc_networking_policy_arn"></a> [vpc\_networking\_policy\_arn](#output\_vpc\_networking\_policy\_arn) | ARN of the VPC networking policy |
<!-- END_TF_DOCS -->