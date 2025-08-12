name_prefix = "ipam-example"

environment_type = "Development"

# IPAM Configuration - replace with your actual IPAM pool ID
# You can find IPAM pool IDs in the VPC console under IPAM -> Pools
ipam_pool_enabled   = true
ipv4_ipam_pool_id   = "ipam-pool-xxxxxxxxxxxxxxxxx"
ipv4_netmask_length = 20

# Optional: Enable IPv6 with IPAM
ipv6_enabled           = true
ipv6_ipam_pool_enabled = true
ipv6_ipam_pool_id      = "ipam-pool-xxxxxxxxxxxxxxxxx"
ipv6_netmask_length    = 56

# VPC Configuration
instance_tenancy      = "default"
dns_hostnames_enabled = true
dns_support_enabled   = true
igw_enabled           = true

# Subnet Configuration
availability_zone_count       = 2
desired_database_subnet_count = 2
nonroutable_subnets_enabled   = true

# Gateway Configuration
nat_gateway_enabled          = true
resilient_natgateway_enabled = false

# Database Configuration
enabled_databases           = ["postgres"]
enabled_caches              = ["redis"]
create_database_route_table = true

# Flow Logs Configuration
vpc_flow_logs_enabled        = true
vpc_flow_logs_retention_days = 14
create_vpc_flow_logs_kms_key = true

# VPC Endpoints
gateway_endpoints   = ["s3", "dynamodb"]
interface_endpoints = []

# Cost Estimation
cost_estimation_config = {
  enabled                   = true
  data_transfer_mb_per_hour = 50
}

tags = {
  Environment = "dev"
  Project     = "ipam-vpc-example"
  Purpose     = "Demonstrate IPAM integration"
}

data_tags = {
  DataClassification = "Internal"
}