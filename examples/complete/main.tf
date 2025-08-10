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

  enabled                                         = var.enabled
  name_prefix                                     = var.name_prefix
  tags                                            = var.tags
  data_tags                                       = var.data_tags
  environment_type                                = var.environment_type
  networktags_name                                = var.networktags_name
  cidr_primary                                    = var.cidr_primary
  nonroutable_subnets_enabled                     = var.nonroutable_subnets_enabled
  ipam_pool_enabled                               = var.ipam_pool_enabled
  ipv6_ipam_pool_enabled                          = var.ipv6_ipam_pool_enabled
  ipv4_ipam_pool_id                               = var.ipv4_ipam_pool_id
  ipv4_netmask_length                             = var.ipv4_netmask_length
  ipv6_ipam_pool_id                               = var.ipv6_ipam_pool_id
  ipv6_netmask_length                             = var.ipv6_netmask_length
  instance_tenancy                                = var.instance_tenancy
  dns_hostnames_enabled                           = var.dns_hostnames_enabled
  dns_support_enabled                             = var.dns_support_enabled
  ipv6_enabled                                    = var.ipv6_enabled
  block_public_access_enabled                     = var.block_public_access_enabled
  igw_enabled                                     = var.igw_enabled
  map_public_ip_on_launch                         = var.map_public_ip_on_launch
  create_database_route_table                     = var.create_database_route_table
  nat_gateway_enabled                             = var.nat_gateway_enabled
  resilient_natgateway_enabled                    = var.resilient_natgateway_enabled
  enabled_databases                               = var.enabled_databases
  enabled_caches                                  = var.enabled_caches
  default_network_acl_ingress                     = var.default_network_acl_ingress
  default_network_acl_egress                      = var.default_network_acl_egress
  allowed_availability_zone_ids                   = var.allowed_availability_zone_ids
  availability_zone_count                         = var.availability_zone_count
  desired_database_subnet_count                   = var.desired_database_subnet_count
  vpc_flow_logs_enabled                           = var.vpc_flow_logs_enabled
  vpc_flow_logs_retention_days                    = var.vpc_flow_logs_retention_days
  vpc_flow_logs_traffic_type                      = var.vpc_flow_logs_traffic_type
  create_vpc_flow_logs_kms_key                    = var.create_vpc_flow_logs_kms_key
  vpc_flow_logs_kms_key_id                        = var.vpc_flow_logs_kms_key_id
  vpc_flow_logs_custom_format                     = var.vpc_flow_logs_custom_format
  gateway_endpoints                               = var.gateway_endpoints
  interface_endpoints                             = var.interface_endpoints
  endpoint_policy_enabled                         = var.endpoint_policy_enabled
  endpoint_policies                               = var.endpoint_policies
  endpoint_private_dns_enabled                    = var.endpoint_private_dns_enabled
  endpoint_default_policy_enabled                 = var.endpoint_default_policy_enabled
  endpoint_default_policy                         = var.endpoint_default_policy
  transit_gateway_attachment_enabled              = var.transit_gateway_attachment_enabled
  transit_gateway_id                              = var.transit_gateway_id
  transit_gateway_route_table_id                  = var.transit_gateway_route_table_id
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation
  transit_gateway_attachment_subnets              = var.transit_gateway_attachment_subnets
  cost_estimation_config                          = var.cost_estimation_config
}
