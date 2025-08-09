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

  name_prefix                                     = var.name_prefix
  cidr_primary                                    = var.cidr_primary
  environment_type                                = var.environment_type
  allowed_availability_zone_ids                   = var.allowed_availability_zone_ids
  create_database_route_table                     = var.create_database_route_table
  cost_estimation_config                          = var.cost_estimation_config
  gateway_endpoints                               = var.gateway_endpoints
  interface_endpoints                             = var.interface_endpoints
  nat_gateway_enabled                             = var.nat_gateway_enabled
  igw_enabled                                     = var.igw_enabled
  vpc_flow_logs_enabled                           = var.vpc_flow_logs_enabled
  ipv6_enabled                                    = var.ipv6_enabled
  availability_zone_count                         = var.availability_zone_count
  tags                                            = var.tags
  transit_gateway_attachment_enabled              = var.transit_gateway_attachment_enabled
  transit_gateway_id                              = var.transit_gateway_id
  transit_gateway_route_table_id                  = var.transit_gateway_route_table_id
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation
  transit_gateway_attachment_subnets              = var.transit_gateway_attachment_subnets
}
