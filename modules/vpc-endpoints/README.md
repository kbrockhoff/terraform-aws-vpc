# VPC Endpoints Module

This module creates AWS VPC Endpoints for both Gateway and Interface types to enable private connectivity to AWS services.

## Features

- Create Gateway endpoints for S3 and DynamoDB
- Create Interface endpoints for other AWS services
- Support for custom endpoint policies
- Configurable private DNS for Interface endpoints
- Comprehensive output mapping for all endpoints

## Usage

### Basic Gateway Endpoints

```hcl
module "vpc_endpoints" {
  source = "./modules/vpc-endpoints"

  name_prefix      = "my-project"
  vpc_id           = var.vpc_id
  route_table_ids  = [var.private_route_table_id]
  
  gateway_endpoints = ["s3", "dynamodb"]
  
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Interface Endpoints with Security Groups

```hcl
module "vpc_endpoints" {
  source = "./modules/vpc-endpoints"

  name_prefix         = "my-project"
  vpc_id              = var.vpc_id
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.endpoint_security_group_id]
  
  interface_endpoints = ["ec2", "ssm", "logs", "monitoring"]
  private_dns_enabled = true
  
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Mixed Endpoints with Custom Policies

```hcl
module "vpc_endpoints" {
  source = "./modules/vpc-endpoints"

  name_prefix         = "my-project"
  vpc_id              = var.vpc_id
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.endpoint_security_group_id]
  route_table_ids     = var.private_route_table_ids
  
  gateway_endpoints   = ["s3", "dynamodb"]
  interface_endpoints = ["ec2", "ssm", "secretsmanager"]
  
  policy_enabled = true
  endpoint_policies = {
    s3 = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = "*"
          Action = [
            "s3:GetObject",
            "s3:PutObject"
          ]
          Resource = "arn:aws:s3:::my-bucket/*"
        }
      ]
    })
  }
  
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Common AWS Service Names

### Gateway Endpoints (Route Table based)
- `s3` - Amazon S3
- `dynamodb` - Amazon DynamoDB

### Interface Endpoints (ENI based)
#### Compute & Management
- `ec2` - Amazon EC2
- `ec2messages` - EC2 Instance Connect
- `ssm` - AWS Systems Manager
- `ssmmessages` - SSM Session Manager
- `ecs` - Amazon ECS
- `ecs-agent` - ECS Container Agent
- `ecs-telemetry` - ECS Telemetry

#### Storage & Database
- `elasticfilesystem` - Amazon EFS
- `fsx` - Amazon FSx
- `rds` - Amazon RDS

#### Security & Identity
- `secretsmanager` - AWS Secrets Manager
- `kms` - AWS Key Management Service
- `sts` - AWS Security Token Service

#### Monitoring & Logging
- `logs` - Amazon CloudWatch Logs
- `monitoring` - Amazon CloudWatch
- `events` - Amazon EventBridge
- `sns` - Amazon SNS
- `sqs` - Amazon SQS

#### Developer Tools
- `git-codecommit` - AWS CodeCommit
- `codebuild` - AWS CodeBuild
- `codecommit` - AWS CodeCommit (Git)

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.8.0 |

## Resources

## Resources

| Name | Type |
|------|------|
| [aws_vpc_endpoint.gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.interface](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_policy"></a> [default\_policy](#input\_default\_policy) | Default policy to apply to all endpoints when default\_policy\_enabled is true | `string` | `null` | no |
| <a name="input_default_policy_enabled"></a> [default\_policy\_enabled](#input\_default\_policy\_enabled) | Enable default restrictive policy for all endpoints | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| <a name="input_endpoint_policies"></a> [endpoint\_policies](#input\_endpoint\_policies) | Map of service names to their custom endpoint policies | `map(string)` | `{}` | no |
| <a name="input_gateway_endpoints"></a> [gateway\_endpoints](#input\_gateway\_endpoints) | List of AWS service names for Gateway endpoints (e.g., s3, dynamodb) | `list(string)` | `[]` | no |
| <a name="input_interface_endpoints"></a> [interface\_endpoints](#input\_interface\_endpoints) | List of AWS service names for Interface endpoints (e.g., ec2, ssm, logs) | `list(string)` | `[]` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for endpoint names | `string` | n/a | yes |
| <a name="input_policy_enabled"></a> [policy\_enabled](#input\_policy\_enabled) | Enable custom endpoint policies | `bool` | `false` | no |
| <a name="input_private_dns_enabled"></a> [private\_dns\_enabled](#input\_private\_dns\_enabled) | Enable private DNS for Interface endpoints | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region for constructing service names | `string` | n/a | yes |
| <a name="input_reverse_dns_prefix"></a> [reverse\_dns\_prefix](#input\_reverse\_dns\_prefix) | AWS reverse DNS prefix for constructing service names | `string` | n/a | yes |
| <a name="input_route_table_ids"></a> [route\_table\_ids](#input\_route\_table\_ids) | List of route table IDs for Gateway endpoints (S3, DynamoDB) | `list(string)` | `[]` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to associate with Interface endpoints | `list(string)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs where Interface endpoints will be created | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags/labels to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where endpoints will be created | `string` | n/a | yes |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all_endpoint_arns"></a> [all\_endpoint\_arns](#output\_all\_endpoint\_arns) | Map of all endpoint service names to their ARNs |
| <a name="output_all_endpoint_ids"></a> [all\_endpoint\_ids](#output\_all\_endpoint\_ids) | Map of all endpoint service names to their IDs |
| <a name="output_gateway_endpoint_count"></a> [gateway\_endpoint\_count](#output\_gateway\_endpoint\_count) | Number of Gateway endpoints created |
| <a name="output_gateway_endpoint_dns_entries"></a> [gateway\_endpoint\_dns\_entries](#output\_gateway\_endpoint\_dns\_entries) | Map of service names to their Gateway endpoint DNS entries |
| <a name="output_gateway_endpoint_ids"></a> [gateway\_endpoint\_ids](#output\_gateway\_endpoint\_ids) | Map of service names to their Gateway endpoint IDs |
| <a name="output_gateway_endpoint_prefix_list_ids"></a> [gateway\_endpoint\_prefix\_list\_ids](#output\_gateway\_endpoint\_prefix\_list\_ids) | Map of service names to their Gateway endpoint prefix list IDs |
| <a name="output_interface_endpoint_count"></a> [interface\_endpoint\_count](#output\_interface\_endpoint\_count) | Number of Interface endpoints created |
| <a name="output_interface_endpoint_dns_entries"></a> [interface\_endpoint\_dns\_entries](#output\_interface\_endpoint\_dns\_entries) | Map of service names to their Interface endpoint DNS entries |
| <a name="output_interface_endpoint_ids"></a> [interface\_endpoint\_ids](#output\_interface\_endpoint\_ids) | Map of service names to their Interface endpoint IDs |
| <a name="output_interface_endpoint_network_interface_ids"></a> [interface\_endpoint\_network\_interface\_ids](#output\_interface\_endpoint\_network\_interface\_ids) | Map of service names to their Interface endpoint network interface IDs |
| <a name="output_total_endpoint_count"></a> [total\_endpoint\_count](#output\_total\_endpoint\_count) | Total number of VPC endpoints created |

## License

MIT Licensed. See [LICENSE](../../LICENSE) for full details.