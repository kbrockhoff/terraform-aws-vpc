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

  enabled          = var.enabled
  name_prefix      = var.name_prefix
  tags             = var.tags
  data_tags        = var.data_tags
  environment_type = var.environment_type
  networktags_name = var.networktags_name

  # IPAM Configuration - do not provide cidr_primary when using IPAM
  ipam_pool_enabled   = var.ipam_pool_enabled
  ipv4_ipam_pool_id   = var.ipv4_ipam_pool_id
  ipv4_netmask_length = var.ipv4_netmask_length

  # IPv6 IPAM Configuration (optional)
  ipv6_enabled           = var.ipv6_enabled
  ipv6_ipam_pool_enabled = var.ipv6_ipam_pool_enabled
  ipv6_ipam_pool_id      = var.ipv6_ipam_pool_id
  ipv6_netmask_length    = var.ipv6_netmask_length

  # VPC Configuration
  instance_tenancy            = var.instance_tenancy
  dns_hostnames_enabled       = var.dns_hostnames_enabled
  dns_support_enabled         = var.dns_support_enabled
  block_public_access_enabled = var.block_public_access_enabled
  igw_enabled                 = var.igw_enabled

  # Subnet Configuration
  availability_zone_count       = var.availability_zone_count
  desired_database_subnet_count = var.desired_database_subnet_count
  nonroutable_subnets_enabled   = var.nonroutable_subnets_enabled

  # Gateway Configuration
  nat_gateway_enabled          = var.nat_gateway_enabled
  resilient_natgateway_enabled = var.resilient_natgateway_enabled

  # Database Configuration
  enabled_databases           = var.enabled_databases
  enabled_caches              = var.enabled_caches
  create_database_route_table = var.create_database_route_table

  # Flow Logs Configuration
  vpc_flow_logs_enabled        = var.vpc_flow_logs_enabled
  vpc_flow_logs_retention_days = var.vpc_flow_logs_retention_days
  create_vpc_flow_logs_kms_key = var.create_vpc_flow_logs_kms_key

  # VPC Endpoints Configuration
  gateway_endpoints            = var.gateway_endpoints
  interface_endpoints          = var.interface_endpoints
  endpoint_private_dns_enabled = var.endpoint_private_dns_enabled

  # Cost Estimation Configuration
  cost_estimation_config = var.cost_estimation_config
}