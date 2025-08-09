variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "data_transfer_mb_per_hour" {
  description = "Expected data transfer in MB per hour"
  type        = number
  default     = 10

  validation {
    condition     = var.data_transfer_mb_per_hour >= 0
    error_message = "Data transfer must be a non-negative number."
  }
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to include in cost calculations"
  type        = number
  default     = 0

  validation {
    condition     = var.nat_gateway_count >= 0 && var.nat_gateway_count <= 6
    error_message = "NAT Gateway count must be between 0 and 6."
  }
}

variable "vpc_flow_logs_enabled" {
  description = "Whether VPC Flow Logs are enabled"
  type        = bool
  default     = false
}

variable "create_vpc_flow_logs_kms_key" {
  description = "Whether to create a customer-managed KMS key for VPC Flow Logs"
  type        = bool
  default     = true
}

variable "interface_endpoints_count" {
  description = "Number of interface endpoints to include in cost calculations"
  type        = number
  default     = 0

  validation {
    condition     = var.interface_endpoints_count >= 0
    error_message = "Interface endpoints count must be a non-negative number."
  }
}

variable "interface_endpoints_az_count" {
  description = "Number of availability zones for interface endpoints (affects total endpoint hours)"
  type        = number
  default     = 1

  validation {
    condition     = var.interface_endpoints_az_count >= 1 && var.interface_endpoints_az_count <= 6
    error_message = "Interface endpoints AZ count must be between 1 and 6."
  }
}

