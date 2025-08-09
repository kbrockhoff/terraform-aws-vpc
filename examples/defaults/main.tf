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
  use_mock_azs     = var.use_mock_azs
  dry_run_mode     = var.dry_run_mode
}
