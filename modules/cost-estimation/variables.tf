variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "region" {
  description = "AWS region where the parent module deploys its resources, e.g. us-west-2"
  type        = string
}

variable "nat_gateway_count" {
  description = "Number of NAT gateways, each billed 730 hours per month"
  type        = number
  default     = 0

  validation {
    condition     = var.nat_gateway_count >= 0
    error_message = "NAT gateway count must be zero or positive."
  }
}

variable "nat_gateway_data_gb" {
  description = "GB of data processed by all NAT gateways per month"
  type        = number
  default     = 0

  validation {
    condition     = var.nat_gateway_data_gb >= 0
    error_message = "NAT gateway data processed must be zero or positive."
  }
}

variable "public_ipv4_address_count" {
  description = "Number of in-use public IPv4 addresses (e.g. NAT gateway Elastic IPs), each billed 730 hours per month"
  type        = number
  default     = 0

  validation {
    condition     = var.public_ipv4_address_count >= 0
    error_message = "Public IPv4 address count must be zero or positive."
  }
}

variable "interface_endpoint_az_count" {
  description = "Number of interface VPC endpoint AZ placements (interface endpoints x subnets), each billed 730 hours per month"
  type        = number
  default     = 0

  validation {
    condition     = var.interface_endpoint_az_count >= 0
    error_message = "Interface endpoint AZ count must be zero or positive."
  }
}

variable "interface_endpoint_data_gb" {
  description = "GB of data processed by all interface VPC endpoints per month"
  type        = number
  default     = 0

  validation {
    condition     = var.interface_endpoint_data_gb >= 0
    error_message = "Interface endpoint data processed must be zero or positive."
  }
}

variable "flow_logs_ingestion_gb" {
  description = "GB of VPC flow logs delivered to CloudWatch Logs per month"
  type        = number
  default     = 0

  validation {
    condition     = var.flow_logs_ingestion_gb >= 0
    error_message = "Flow logs ingestion must be zero or positive."
  }
}

variable "flow_logs_storage_gb" {
  description = "GB of VPC flow logs stored in CloudWatch Logs (average over the month)"
  type        = number
  default     = 0

  validation {
    condition     = var.flow_logs_storage_gb >= 0
    error_message = "Flow logs storage must be zero or positive."
  }
}

variable "kms_key_count" {
  description = "Number of customer managed KMS keys"
  type        = number
  default     = 0

  validation {
    condition     = var.kms_key_count >= 0
    error_message = "KMS key count must be zero or positive."
  }
}

variable "transit_gateway_attachment_count" {
  description = "Number of transit gateway VPC attachments, each billed 730 hours per month"
  type        = number
  default     = 0

  validation {
    condition     = var.transit_gateway_attachment_count >= 0
    error_message = "Transit gateway attachment count must be zero or positive."
  }
}
