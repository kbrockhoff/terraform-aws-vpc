# Security Group Module

This module creates AWS Security Groups with support for both explicit rules and named rule references.

## Features

- Create security groups with custom ingress and egress rules
- Support for named rules with predefined port/protocol combinations
- Automatic tagging with NetworkTags for subnet classification
- Comprehensive set of predefined named rules for common services

## Usage

### Basic Security Group

```hcl
module "web_security_group" {
  source = "./modules/security-group"

  name               = "web-sg"
  description        = "Security group for web servers"
  vpc_id             = var.vpc_id
  vpc_cidr_block     = var.vpc_cidr_block
  networktags_name   = "NetworkTags"
  networktags_value  = "web"

  ingress_rules = [
    {
      description = "HTTP from anywhere"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      description = "All outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
```

### Using Named Rules

```hcl
module "database_security_group" {
  source = "./modules/security-group"

  name               = "db-sg"
  description        = "Security group for databases"
  vpc_id             = var.vpc_id
  vpc_cidr_block     = var.vpc_cidr_block
  networktags_name   = "NetworkTags"
  networktags_value  = "database"

  ingress_named_rules = [
    {
      named_rule  = "postgres"
      cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
    },
    {
      named_rule  = "redis"
      cidr_blocks = ["10.0.1.0/24"]
    }
  ]
}
```

### Mixed Rules

```hcl
module "app_security_group" {
  source = "./modules/security-group"

  name               = "app-sg"
  description        = "Security group for application servers"
  vpc_id             = var.vpc_id
  vpc_cidr_block     = var.vpc_cidr_block
  networktags_name   = "NetworkTags"
  networktags_value  = "private"

  # Explicit rules
  ingress_rules = [
    {
      description = "Custom application port"
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]

  # Named rules
  ingress_named_rules = [
    {
      named_rule  = "https"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]

  egress_named_rules = [
    {
      named_rule  = "postgres"
      cidr_blocks = ["10.0.3.0/24"]
    },
    {
      named_rule  = "https"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
```

## Named Rules Reference

### Web Services
| Rule | Port | Protocol | Description |
|------|------|----------|-------------|
| `http` | 80 | tcp | HTTP |
| `http-8080` | 8080 | tcp | HTTP |
| `https` | 443 | tcp | HTTPS |
| `https-8443` | 8443 | tcp | HTTPS |

### Database Services
| Rule | Port | Protocol | Description |
|------|------|----------|-------------|
| `mysql` | 3306 | tcp | MySQL/Aurora |
| `postgres` | 5432 | tcp | PostgreSQL |
| `oracle` | 1521 | tcp | Oracle |
| `mssql` | 1433 | tcp | Microsoft SQL Server |
| `mariadb` | 3306 | tcp | MariaDB |
| `db2` | 50000 | tcp | IBM Db2 |
| `neptune` | 8182 | tcp | Neptune |
| `redshift` | 5439 | tcp | Redshift |
| `timestream` | 443 | tcp | Timestream |
| `documentdb` | 27017 | tcp | DocumentDB |
| `qldb` | 443 | tcp | QLDB |
| `dynamodb` | 443 | tcp | DynamoDB |

### Cache Services
| Rule | Port | Protocol | Description |
|------|------|----------|-------------|
| `redis` | 6379 | tcp | Redis |
| `memcached` | 11211 | tcp | Memcached |

### Message Queue Services
| Rule | Port | Protocol | Description |
|------|------|----------|-------------|
| `activemq` | 61617 | tcp | ActiveMQ |
| `activemq-web` | 8162 | tcp | ActiveMQ Web Console |
| `rabbitmq` | 5672 | tcp | RabbitMQ |
| `rabbitmq-web` | 15672 | tcp | RabbitMQ Web Console |

### Monitoring & Analytics
| Rule | Port | Protocol | Description |
|------|------|----------|-------------|
| `opensearch` | 443 | tcp | OpenSearch |
| `opensearch-dashboards` | 5601 | tcp | OpenSearch Dashboards |
| `prometheus` | 9090 | tcp | Prometheus |
| `grafana` | 3000 | tcp | Grafana |

### Protocol Rules
| Rule | Port | Protocol | Description |
|------|------|----------|-------------|
| `all-all` | 0 | -1 | All protocols |
| `all-tcp` | 0-65535 | tcp | All TCP |
| `all-udp` | 0-65535 | udp | All UDP |
| `all-icmp` | -1 | icmp | All ICMP |
| `all-icmpv6` | -1 | icmpv6 | All ICMPv6 |

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
| [aws_security_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description for the security group | `string` | `"Security group managed by Terraform"` | no |
| <a name="input_egress_named_rules"></a> [egress\_named\_rules](#input\_egress\_named\_rules) | List of egress rules using named rule references | <pre>list(object({<br/>    named_rule       = string<br/>    cidr_blocks      = optional(list(string))<br/>    ipv6_cidr_blocks = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | List of egress rules | <pre>list(object({<br/>    description      = optional(string)<br/>    from_port        = number<br/>    to_port          = number<br/>    protocol         = string<br/>    cidr_blocks      = optional(list(string))<br/>    ipv6_cidr_blocks = optional(list(string))<br/>    security_groups  = optional(list(string))<br/>    self             = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| <a name="input_ingress_named_rules"></a> [ingress\_named\_rules](#input\_ingress\_named\_rules) | List of ingress rules using named rule references | <pre>list(object({<br/>    named_rule       = string<br/>    cidr_blocks      = optional(list(string))<br/>    ipv6_cidr_blocks = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | List of ingress rules | <pre>list(object({<br/>    description      = optional(string)<br/>    from_port        = number<br/>    to_port          = number<br/>    protocol         = string<br/>    cidr_blocks      = optional(list(string))<br/>    ipv6_cidr_blocks = optional(list(string))<br/>    security_groups  = optional(list(string))<br/>    self             = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the security group | `string` | n/a | yes |
| <a name="input_named_rules"></a> [named\_rules](#input\_named\_rules) | Map of named rules with port ranges and protocols | <pre>map(object({<br/>    from_port   = number<br/>    to_port     = number<br/>    protocol    = string<br/>    description = string<br/>  }))</pre> | <pre>{<br/>  "activemq": {<br/>    "description": "ActiveMQ",<br/>    "from_port": 61617,<br/>    "protocol": "tcp",<br/>    "to_port": 61617<br/>  },<br/>  "activemq-web": {<br/>    "description": "ActiveMQ Web Console",<br/>    "from_port": 8162,<br/>    "protocol": "tcp",<br/>    "to_port": 8162<br/>  },<br/>  "all-all": {<br/>    "description": "All protocols",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "to_port": 0<br/>  },<br/>  "all-icmp": {<br/>    "description": "All ICMP",<br/>    "from_port": -1,<br/>    "protocol": "icmp",<br/>    "to_port": -1<br/>  },<br/>  "all-icmpv6": {<br/>    "description": "All ICMPv6",<br/>    "from_port": -1,<br/>    "protocol": "icmpv6",<br/>    "to_port": -1<br/>  },<br/>  "all-tcp": {<br/>    "description": "All TCP",<br/>    "from_port": 0,<br/>    "protocol": "tcp",<br/>    "to_port": 65535<br/>  },<br/>  "all-udp": {<br/>    "description": "All UDP",<br/>    "from_port": 0,<br/>    "protocol": "udp",<br/>    "to_port": 65535<br/>  },<br/>  "db2": {<br/>    "description": "IBM Db2",<br/>    "from_port": 50000,<br/>    "protocol": "tcp",<br/>    "to_port": 50000<br/>  },<br/>  "documentdb": {<br/>    "description": "DocumentDB",<br/>    "from_port": 27017,<br/>    "protocol": "tcp",<br/>    "to_port": 27017<br/>  },<br/>  "dynamodb": {<br/>    "description": "DynamoDB",<br/>    "from_port": 443,<br/>    "protocol": "tcp",<br/>    "to_port": 443<br/>  },<br/>  "grafana": {<br/>    "description": "Grafana",<br/>    "from_port": 3000,<br/>    "protocol": "tcp",<br/>    "to_port": 3000<br/>  },<br/>  "http": {<br/>    "description": "HTTP",<br/>    "from_port": 80,<br/>    "protocol": "tcp",<br/>    "to_port": 80<br/>  },<br/>  "http-8080": {<br/>    "description": "HTTP",<br/>    "from_port": 8080,<br/>    "protocol": "tcp",<br/>    "to_port": 8080<br/>  },<br/>  "https": {<br/>    "description": "HTTPS",<br/>    "from_port": 443,<br/>    "protocol": "tcp",<br/>    "to_port": 443<br/>  },<br/>  "https-8443": {<br/>    "description": "HTTPS",<br/>    "from_port": 8443,<br/>    "protocol": "tcp",<br/>    "to_port": 8443<br/>  },<br/>  "mariadb": {<br/>    "description": "MariaDB",<br/>    "from_port": 3306,<br/>    "protocol": "tcp",<br/>    "to_port": 3306<br/>  },<br/>  "memcached": {<br/>    "description": "Memcached",<br/>    "from_port": 11211,<br/>    "protocol": "tcp",<br/>    "to_port": 11211<br/>  },<br/>  "mssql": {<br/>    "description": "Microsoft SQL Server",<br/>    "from_port": 1433,<br/>    "protocol": "tcp",<br/>    "to_port": 1433<br/>  },<br/>  "mysql": {<br/>    "description": "MySQL/Aurora",<br/>    "from_port": 3306,<br/>    "protocol": "tcp",<br/>    "to_port": 3306<br/>  },<br/>  "neptune": {<br/>    "description": "Neptune",<br/>    "from_port": 8182,<br/>    "protocol": "tcp",<br/>    "to_port": 8182<br/>  },<br/>  "opensearch": {<br/>    "description": "OpenSearch",<br/>    "from_port": 443,<br/>    "protocol": "tcp",<br/>    "to_port": 443<br/>  },<br/>  "opensearch-dashboards": {<br/>    "description": "OpenSearch Dashboards",<br/>    "from_port": 5601,<br/>    "protocol": "tcp",<br/>    "to_port": 5601<br/>  },<br/>  "oracle": {<br/>    "description": "Oracle",<br/>    "from_port": 1521,<br/>    "protocol": "tcp",<br/>    "to_port": 1521<br/>  },<br/>  "postgres": {<br/>    "description": "PostgreSQL",<br/>    "from_port": 5432,<br/>    "protocol": "tcp",<br/>    "to_port": 5432<br/>  },<br/>  "prometheus": {<br/>    "description": "Prometheus",<br/>    "from_port": 9090,<br/>    "protocol": "tcp",<br/>    "to_port": 9090<br/>  },<br/>  "qldb": {<br/>    "description": "QLDB",<br/>    "from_port": 443,<br/>    "protocol": "tcp",<br/>    "to_port": 443<br/>  },<br/>  "rabbitmq": {<br/>    "description": "RabbitMQ",<br/>    "from_port": 5672,<br/>    "protocol": "tcp",<br/>    "to_port": 5672<br/>  },<br/>  "rabbitmq-web": {<br/>    "description": "RabbitMQ Web Console",<br/>    "from_port": 15672,<br/>    "protocol": "tcp",<br/>    "to_port": 15672<br/>  },<br/>  "redis": {<br/>    "description": "Redis",<br/>    "from_port": 6379,<br/>    "protocol": "tcp",<br/>    "to_port": 6379<br/>  },<br/>  "redshift": {<br/>    "description": "Redshift",<br/>    "from_port": 5439,<br/>    "protocol": "tcp",<br/>    "to_port": 5439<br/>  },<br/>  "timestream": {<br/>    "description": "Timestream",<br/>    "from_port": 443,<br/>    "protocol": "tcp",<br/>    "to_port": 443<br/>  }<br/>}</pre> | no |
| <a name="input_networktags_name"></a> [networktags\_name](#input\_networktags\_name) | Name of the network tags key used for security group classification | `string` | `"NetworkTags"` | no |
| <a name="input_networktags_value"></a> [networktags\_value](#input\_networktags\_value) | Value for the network tags key | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags/labels to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | CIDR block of the VPC | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where security group will be created | `string` | n/a | yes |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | ARN of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | Name of the security group |

## License

MIT Licensed. See [LICENSE](../../LICENSE) for full details.