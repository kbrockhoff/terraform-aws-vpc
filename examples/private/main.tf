# Main AWS provider - uses the current region
provider "aws" {
  # This is the default provider used for VPC resources
}

# Pricing provider - always uses us-east-1 where the AWS Pricing API is available
provider "aws" {
  alias  = "pricing"
  region = "us-east-1"
}

module "main" {
  source = "../../"

  providers = {
    aws         = aws
    aws.pricing = aws.pricing
  }

  name_prefix      = var.name_prefix
  cidr_primary     = var.cidr_primary
  environment_type = var.environment_type
  tags             = var.tags

  # Disable internet access completely
  igw_enabled         = false
  nat_gateway_enabled = false

  # Block all public access
  block_public_access_enabled = true

  # Enable flow logs for monitoring
  vpc_flow_logs_enabled = true

  # Gateway endpoints for AWS services without internet
  gateway_endpoints = var.gateway_endpoints

  # Interface endpoints for AWS services without internet
  interface_endpoints = var.interface_endpoints
}