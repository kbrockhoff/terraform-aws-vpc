variable "name_prefix" {
  description = "Organization unique prefix to use for resource names. Recommend including environment and region. e.g. 'prod-usw2'."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,22}[a-z0-9]$", var.name_prefix))
    error_message = "The name_prefix value must be between 2 and 24 characters."
  }
}

variable "cidr_primary" {
  description = "The primary IPv4 CIDR block for the VPC."
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_primary, 0))
    error_message = "The cidr_primary value must be a valid IPv4 CIDR block."
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

variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags/labels to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "use_mock_azs" {
  description = "Use mock availability zones instead of querying AWS (useful for testing with restricted SCPs)"
  type        = bool
  default     = false
}

variable "dry_run_mode" {
  description = "Enable dry-run mode for validation without creating AWS resources (useful for testing with restricted SCPs)"
  type        = bool
  default     = false
}
