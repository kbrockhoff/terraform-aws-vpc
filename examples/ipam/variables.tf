variable "enabled" {
  description = "Set to false to prevent the module from creating any resources."
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "Organization unique prefix to use for resource names. Recommend including environment and region. e.g. 'prod-usw2'."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,22}[a-z0-9]$", var.name_prefix))
    error_message = "The name_prefix value must be between 2 and 24 characters."
  }
}

variable "environment_type" {
  description = "Environment type for automatic configuration sizing."
  type        = string
  default     = "Development"

  validation {
    condition = contains([
      "None", "Ephemeral", "Development", "Testing",
      "UAT", "Production", "MissionCritical"
    ], var.environment_type)
    error_message = "Environment type must be one of: None, Ephemeral, Development, Testing, UAT, Production, MissionCritical."
  }
}

variable "tags" {
  description = "Tags/labels to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "data_tags" {
  description = "Tags to apply to data resources."
  type        = map(string)
  default     = {}
}

variable "networktags_name" {
  description = "The name of the NetworkTags tag to apply to all network resources."
  type        = string
  default     = "NetworkTags"
}

# IPAM Configuration
variable "ipam_pool_enabled" {
  description = "Flag to enable IPAM pool for IPv4 addresses."
  type        = bool
  default     = true
}

variable "ipv4_ipam_pool_id" {
  description = "The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR."
  type        = string
}

variable "ipv4_netmask_length" {
  description = "The netmask length of the IPv4 CIDR you want to allocate to this VPC from an IPAM pool."
  type        = number
  default     = 16

  validation {
    condition     = var.ipv4_netmask_length >= 16 && var.ipv4_netmask_length <= 28
    error_message = "IPv4 netmask length must be between 16 and 28."
  }
}

# IPv6 IPAM Configuration
variable "ipv6_enabled" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC."
  type        = bool
  default     = false
}

variable "ipv6_ipam_pool_enabled" {
  description = "Flag to enable IPAM pool for IPv6 addresses."
  type        = bool
  default     = false
}

variable "ipv6_ipam_pool_id" {
  description = "The ID of an IPv6 IPAM pool you want to use for allocating this VPC's CIDR."
  type        = string
  default     = null
}

variable "ipv6_netmask_length" {
  description = "The netmask length of the IPv6 CIDR you want to allocate to this VPC from an IPAM pool."
  type        = number
  default     = 56

  validation {
    condition     = var.ipv6_netmask_length >= 44 && var.ipv6_netmask_length <= 60
    error_message = "IPv6 netmask length must be between 44 and 60."
  }
}

# VPC Configuration
variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC."
  type        = string
  default     = null
}

variable "dns_hostnames_enabled" {
  description = "Should be true to enable DNS hostnames in the VPC."
  type        = bool
  default     = null
}

variable "dns_support_enabled" {
  description = "Should be true to enable DNS support in the VPC."
  type        = bool
  default     = null
}

variable "block_public_access_enabled" {
  description = "Enable VPC Block Public Access to prevent resources in VPC from reaching or being reached from internet."
  type        = bool
  default     = false
}

variable "igw_enabled" {
  description = "Controls if an Internet Gateway is created for public subnets and the related routes that connect them."
  type        = bool
  default     = null
}

# Subnet Configuration
variable "availability_zone_count" {
  description = "Number of Availability Zones to use for the VPC."
  type        = number
  default     = null
}

variable "desired_database_subnet_count" {
  description = "Number of database subnets to create."
  type        = number
  default     = null
}

variable "nonroutable_subnets_enabled" {
  description = "Should be true if you want to provision non-routable subnets in the VPC for EKS pods."
  type        = bool
  default     = null
}

# Gateway Configuration
variable "nat_gateway_enabled" {
  description = "Should be true if you want to provision a NAT Gateway for each private network."
  type        = bool
  default     = null
}

variable "resilient_natgateway_enabled" {
  description = "Should be true if you want to provision NAT Gateways in multiple AZs instead of single AZ."
  type        = bool
  default     = null
}

# Database Configuration
variable "enabled_databases" {
  description = "List of databases for which to create subnet groups."
  type        = list(string)
  default     = ["rds"]
}

variable "enabled_caches" {
  description = "List of caches for which to create subnet groups."
  type        = list(string)
  default     = ["elasticache"]
}

variable "create_database_route_table" {
  description = "Controls if separate route table for database should be created."
  type        = bool
  default     = null
}

# Flow Logs Configuration
variable "vpc_flow_logs_enabled" {
  description = "Should be true to enable VPC Flow Logs."
  type        = bool
  default     = null
}

variable "vpc_flow_logs_retention_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group for VPC flow logs."
  type        = number
  default     = null
}

variable "create_vpc_flow_logs_kms_key" {
  description = "Controls if a KMS key for VPC flow logs should be created."
  type        = bool
  default     = null
}

# VPC Endpoints Configuration
variable "gateway_endpoints" {
  description = "Gateway VPC endpoints."
  type        = list(string)
  default     = ["s3", "dynamodb"]
}

variable "interface_endpoints" {
  description = "Interface VPC endpoints."
  type        = list(string)
  default     = []
}

variable "endpoint_private_dns_enabled" {
  description = "Should be true if you want to associate a private hosted zone with the specified VPC for interface endpoints."
  type        = bool
  default     = null
}

# Cost Estimation Configuration
variable "cost_estimation_config" {
  description = "Configuration for cost estimation of the VPC."
  type = object({
    enabled                   = optional(bool, true)
    data_transfer_mb_per_hour = optional(number, 100)
  })
  default = {
    enabled                   = true
    data_transfer_mb_per_hour = 100
  }
}