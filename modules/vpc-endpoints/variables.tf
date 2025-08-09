variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID of the VPC where endpoints will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where Interface endpoints will be created"
  type        = list(string)
  default     = []
}

variable "route_table_ids" {
  description = "List of route table IDs for Gateway endpoints (S3, DynamoDB)"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with Interface endpoints"
  type        = list(string)
  default     = []
}

variable "gateway_endpoints" {
  description = "List of AWS service names for Gateway endpoints (e.g., s3, dynamodb)"
  type        = list(string)
  default     = []

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

variable "policy_enabled" {
  description = "Enable custom endpoint policies"
  type        = bool
  default     = false
}

variable "endpoint_policies" {
  description = "Map of service names to their custom endpoint policies"
  type        = map(string)
  default     = {}
}

variable "default_policy_enabled" {
  description = "Enable default restrictive policy for all endpoints"
  type        = bool
  default     = false
}

variable "default_policy" {
  description = "Default policy to apply to all endpoints when default_policy_enabled is true"
  type        = string
  default     = null
}

variable "private_dns_enabled" {
  description = "Enable private DNS for Interface endpoints"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags/labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix for endpoint names"
  type        = string
}

variable "region" {
  description = "AWS region for constructing service names"
  type        = string
}

variable "reverse_dns_prefix" {
  description = "AWS reverse DNS prefix for constructing service names"
  type        = string
}