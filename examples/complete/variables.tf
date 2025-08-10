# ----
# Common
# ----

variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "Organization unique prefix to use for resource names. Recommend including environment and region. e.g. 'prod-usw2'"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,22}[a-z0-9]$", var.name_prefix))
    error_message = "The name_prefix value must start with a lowercase letter, followed by 0 to 22 alphanumeric or hyphen characters, ending with alphanumeric, for a total length of 2 to 24 characters."
  }
}

variable "tags" {
  description = "Tags/labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "data_tags" {
  description = "Additional tags to apply specifically to data storage resources (e.g., S3, RDS, EBS) beyond the common tags."
  type        = map(string)
  default     = {}
}

variable "environment_type" {
  description = "Environment type for resource configuration defaults. Select 'None' to use individual config values."
  type        = string
  default     = "Development"

  validation {
    condition = contains([
      "None", "Ephemeral", "Development", "Testing", "UAT", "Production", "MissionCritical"
    ], var.environment_type)
    error_message = "Environment type must be one of: None, Ephemeral, Development, Testing, UAT, Production, MissionCritical."
  }
}

variable "networktags_name" {
  description = "Name of the network tags key used for subnet classification"
  type        = string
  default     = "NetworkTags"

  validation {
    condition     = var.networktags_name != null && var.networktags_name != ""
    error_message = "Network tags name cannot be null or blank."
  }
}

# ----
# VPC
# ----

variable "cidr_primary" {
  description = "The IPv4 CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/24"

  validation {
    condition     = can(cidrhost(var.cidr_primary, 0))
    error_message = "VPC CIDR block must be a valid IPv4 CIDR."
  }
}

variable "nonroutable_subnets_enabled" {
  description = "Enable creation of non-routable subnets for EKS pods"
  type        = bool
  default     = true
}

variable "ipam_pool_enabled" {
  description = "Enable IPAM pool for VPC CIDR allocation"
  type        = bool
  default     = false
}

variable "ipv6_ipam_pool_enabled" {
  description = "Enable IPv6 IPAM pool for VPC CIDR allocation"
  type        = bool
  default     = false

  validation {
    condition     = var.ipv6_ipam_pool_enabled ? var.ipv6_enabled : true
    error_message = "ipv6_enabled must be true when ipv6_ipam_pool_enabled is true."
  }
}

variable "ipv4_ipam_pool_id" {
  description = "The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR"
  type        = string
  default     = null

  validation {
    condition     = var.ipam_pool_enabled ? var.ipv4_ipam_pool_id != null : true
    error_message = "ipv4_ipam_pool_id must be provided when ipam_pool_enabled is true."
  }
}

variable "ipv4_netmask_length" {
  description = "The netmask length of the IPv4 CIDR you want to allocate to this VPC"
  type        = number
  default     = 24

  validation {
    condition     = var.ipv4_netmask_length >= 16 && var.ipv4_netmask_length <= 28
    error_message = "IPv4 netmask length must be between 16 and 28."
  }
}

variable "ipv6_ipam_pool_id" {
  description = "The ID of an IPv6 IPAM pool you want to use for allocating this VPC's CIDR"
  type        = string
  default     = null

  validation {
    condition     = var.ipv6_ipam_pool_enabled ? var.ipv6_ipam_pool_id != null : true
    error_message = "ipv6_ipam_pool_id must be provided when ipv6_ipam_pool_enabled is true."
  }
}

variable "ipv6_netmask_length" {
  description = "The netmask length of the IPv6 CIDR you want to allocate to this VPC"
  type        = number
  default     = 56

  validation {
    condition     = var.ipv6_netmask_length >= 44 && var.ipv6_netmask_length <= 60
    error_message = "IPv6 netmask length must be between 44 and 60."
  }
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated", "host"], var.instance_tenancy)
    error_message = "Instance tenancy must be one of: default, dedicated, host."
  }
}

variable "dns_hostnames_enabled" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "dns_support_enabled" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "ipv6_enabled" {
  description = "Enable IPv6 support for VPC and subnets"
  type        = bool
  default     = true
}

variable "block_public_access_enabled" {
  description = "Enable VPC block public access to prevent creation of public subnets and block bidirectional internet access"
  type        = bool
  default     = false
}

# ----
# Internet Gateway
# ----

variable "igw_enabled" {
  description = "Controls if an Internet Gateway is created for public subnets"
  type        = bool
  default     = true
}

# ----
# Public Subnets
# ----

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP for public subnets"
  type        = bool
  default     = true
}

# ----
# Private Subnets
# ----

# ----
# Database Subnets
# ----

variable "create_database_route_table" {
  description = "Controls if separate route table for database should be created"
  type        = bool
  default     = false
}

# ----
# NAT Gateway
# ----

variable "nat_gateway_enabled" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = true
}

variable "resilient_natgateway_enabled" {
  description = "Enable resilient NAT Gateway deployment (one per public subnet for high availability). If false, provisions a single NAT Gateway."
  type        = bool
  default     = false
}

# ----
# Route Tables
# ----

# ----
# Security Groups
# ----


variable "enabled_databases" {
  description = "List of database types to enable security group rules for"
  type        = list(string)
  default     = ["postgres"]

  validation {
    condition = alltrue([
      for db in var.enabled_databases : contains([
        "mysql", "postgres", "oracle", "mssql", "mariadb", "db2",
        "neptune", "redshift", "timestream", "documentdb", "qldb", "dynamodb"
      ], db)
    ])
    error_message = "All enabled_databases must be valid database named rules: mysql, postgres, oracle, mssql, mariadb, db2, neptune, redshift, timestream, documentdb, qldb, dynamodb."
  }
}

variable "enabled_caches" {
  description = "List of cache types to enable security group rules for"
  type        = list(string)
  default     = ["redis"]

  validation {
    condition = alltrue([
      for cache in var.enabled_caches : contains([
        "redis", "memcached"
      ], cache)
    ])
    error_message = "All enabled_caches must be valid cache named rules: redis, memcached."
  }
}


# ----
# Default Network ACL
# ----


variable "default_network_acl_ingress" {
  description = "List of maps of ingress rules to set on the default network ACL"
  type        = list(map(string))
  default = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    }
  ]
}

variable "default_network_acl_egress" {
  description = "List of maps of egress rules to set on the default network ACL"
  type        = list(map(string))
  default = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    }
  ]
}

# ----
# Availability Zones
# ----

variable "allowed_availability_zone_ids" {
  description = <<-EOT
    List of allowed availability zone IDs. If empty, randomly select from all available AZs in the region.
    
    Specify allowed AZs when you need to:
    - Support private endpoints to endpoint services in other AWS accounts (requires matching AZs)
    - Avoid cross-AZ data transfer charges by ensuring resources are co-located
    - Meet compliance requirements for data locality within specific AZs
    - Maintain consistency with existing infrastructure deployments
    
    Use AZ IDs (e.g., use1-az1, use1-az2) rather than AZ names (e.g., us-east-1a, us-east-1b) 
    to ensure consistent mapping across AWS accounts.
  EOT
  type        = list(string)
  default     = []

  validation {
    condition = length(var.allowed_availability_zone_ids) == 0 || (
      length(var.allowed_availability_zone_ids) >= var.availability_zone_count &&
      length(var.allowed_availability_zone_ids) >= var.desired_database_subnet_count
    )
    error_message = "When provided, allowed_availability_zone_ids must contain enough AZs to meet availability_zone_count and desired_database_subnet_count requirements."
  }
}

variable "availability_zone_count" {
  description = "Number of availability zones to use for private subnets"
  type        = number
  default     = 2

  validation {
    condition     = var.availability_zone_count >= 1 && var.availability_zone_count <= 6
    error_message = "Availability zone count must be between 1 and 6."
  }
}


variable "desired_database_subnet_count" {
  description = "Number of database subnets to create"
  type        = number
  default     = 2

  validation {
    condition     = var.desired_database_subnet_count >= 0 && var.desired_database_subnet_count <= 6
    error_message = "Database subnet count must be between 0 and 6."
  }
}

# ----
# VPC Flow Logs
# ----

variable "vpc_flow_logs_enabled" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "vpc_flow_logs_retention_days" {
  description = "Number of days to retain VPC Flow Logs in CloudWatch"
  type        = number
  default     = 30

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
    ], var.vpc_flow_logs_retention_days)
    error_message = "VPC Flow Logs retention days must be a valid CloudWatch Logs retention period."
  }
}

variable "vpc_flow_logs_traffic_type" {
  description = "Type of traffic to capture in VPC Flow Logs"
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ALL", "ACCEPT", "REJECT"], var.vpc_flow_logs_traffic_type)
    error_message = "VPC Flow Logs traffic type must be ALL, ACCEPT, or REJECT."
  }
}

variable "create_vpc_flow_logs_kms_key" {
  description = "Set to true to create a customer-managed KMS key for encrypting VPC Flow Logs"
  type        = bool
  default     = true
}

variable "vpc_flow_logs_kms_key_id" {
  description = "KMS Key ID for encrypting VPC Flow Logs. If null, a customer-managed key will be created"
  type        = string
  default     = null
}

variable "vpc_flow_logs_custom_format" {
  description = "Custom format for VPC Flow Logs. If null, default format will be used"
  type        = string
  default     = null
}

# ----
# VPC Endpoints
# ----

variable "gateway_endpoints" {
  description = "List of AWS service names for Gateway endpoints (S3, DynamoDB)"
  type        = list(string)
  default     = ["s3", "dynamodb"]

  validation {
    condition = alltrue([
      for service in var.gateway_endpoints : contains(["s3", "dynamodb"], service)
    ])
    error_message = "Gateway endpoints only support 's3' and 'dynamodb' services."
  }
}

variable "interface_endpoints" {
  description = "List of AWS service names for Interface endpoints (e.g., ec2, ssm, logs)"
  type        = list(string)
  default     = []
}

variable "endpoint_policy_enabled" {
  description = "Enable custom endpoint policies"
  type        = bool
  default     = false
}

variable "endpoint_policies" {
  description = "Map of service names to their custom endpoint policies"
  type        = map(string)
  default     = {}
}

variable "endpoint_private_dns_enabled" {
  description = "Enable private DNS for Interface endpoints"
  type        = bool
  default     = true
}

variable "endpoint_default_policy_enabled" {
  description = "Enable default restrictive policy for all VPC endpoints"
  type        = bool
  default     = false
}

variable "endpoint_default_policy" {
  description = "Default policy (JSON string) to apply to all VPC endpoints when endpoint_default_policy_enabled is true"
  type        = string
  default     = null
}

# ----
# Transit Gateway
# ----

variable "transit_gateway_attachment_enabled" {
  description = "Enable attachment of VPC to a Transit Gateway"
  type        = bool
  default     = false
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway to attach the VPC to"
  type        = string
  default     = null

  validation {
    condition     = var.transit_gateway_attachment_enabled ? var.transit_gateway_id != null : true
    error_message = "transit_gateway_id must be provided when transit_gateway_attachment_enabled is true."
  }
}

variable "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway route table to associate with the attachment"
  type        = string
  default     = null
}

variable "transit_gateway_default_route_table_association" {
  description = "Enable association with the Transit Gateway default route table"
  type        = bool
  default     = true
}

variable "transit_gateway_default_route_table_propagation" {
  description = "Enable route propagation to the Transit Gateway default route table"
  type        = bool
  default     = true
}

variable "transit_gateway_attachment_subnets" {
  description = "Subnet types to use for Transit Gateway attachment. Options: private, database"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["private", "database"], var.transit_gateway_attachment_subnets)
    error_message = "transit_gateway_attachment_subnets must be 'private' or 'database'."
  }
}

# ----
# Cost Estimation
# ----

variable "cost_estimation_config" {
  description = "Configuration object for monthly cost estimation"
  type = object({
    enabled                   = bool
    data_transfer_mb_per_hour = number
  })
  default = {
    enabled                   = true
    data_transfer_mb_per_hour = 10
  }
}
