# ----
# VPC
# ----

output "vpc_id" {
  description = "ID of the VPC"
  value       = local.create_resources ? aws_vpc.main[0].id : null
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = local.create_resources ? aws_vpc.main[0].arn : null
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = local.create_resources ? aws_vpc.main[0].cidr_block : null
}

output "vpc_ipv6_cidr_block" {
  description = "The IPv6 CIDR block of the VPC"
  value       = local.create_resources && var.ipv6_enabled ? aws_vpc.main[0].ipv6_cidr_block : null
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = local.create_resources ? aws_vpc.main[0].default_security_group_id : null
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = local.create_resources ? aws_vpc.main[0].default_network_acl_id : null
}

output "managed_default_network_acl_id" {
  description = "The ID of the managed default network ACL"
  value       = local.create_resources ? aws_default_network_acl.default[0].id : null
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = local.create_resources ? aws_default_route_table.default[0].id : null
}

output "managed_default_route_table_id" {
  description = "The ID of the managed default route table"
  value       = local.create_resources ? aws_default_route_table.default[0].id : null
}

output "block_public_access_enabled" {
  description = "Whether VPC block public access is enabled, preventing creation of public subnets and internet gateways"
  value       = var.block_public_access_enabled
}

output "vpc_block_public_access_options_internet_gateway_block_mode" {
  description = "The internet gateway block mode for VPC block public access options"
  value       = local.create_resources && var.block_public_access_enabled ? aws_vpc_block_public_access_options.main[0].internet_gateway_block_mode : null
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = local.create_resources ? aws_vpc.main[0].instance_tenancy : null
}

output "vpc_dns_support_enabled" {
  description = "Whether or not the VPC has DNS support"
  value       = local.create_resources ? aws_vpc.main[0].enable_dns_support : null
}

output "vpc_dns_hostnames_enabled" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = local.create_resources ? aws_vpc.main[0].enable_dns_hostnames : null
}

# ----
# Internet Gateway
# ----

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = local.create_resources && var.igw_enabled ? aws_internet_gateway.main[0].id : null
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = local.create_resources && var.igw_enabled ? aws_internet_gateway.main[0].arn : null
}

output "eigw_id" {
  description = "The ID of the Egress-Only Internet Gateway"
  value       = local.create_resources && var.ipv6_enabled ? aws_egress_only_internet_gateway.main[0].id : null
}

# ----
# Public Subnets
# ----

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = local.create_resources ? aws_subnet.public[*].id : []
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = local.create_resources ? aws_subnet.public[*].arn : []
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = local.create_resources ? aws_subnet.public[*].cidr_block : []
}

output "public_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 CIDR blocks assigned to the public subnets"
  value       = local.create_resources ? aws_subnet.public[*].ipv6_cidr_block : []
}

# ----
# Private Subnets
# ----

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = local.create_resources ? aws_subnet.private[*].id : []
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = local.create_resources ? aws_subnet.private[*].arn : []
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = local.create_resources ? aws_subnet.private[*].cidr_block : []
}

output "private_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 CIDR blocks assigned to the private subnets"
  value       = local.create_resources ? aws_subnet.private[*].ipv6_cidr_block : []
}

# ----
# Database Subnets
# ----

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = local.create_resources ? aws_subnet.database[*].id : []
}

output "database_subnet_arns" {
  description = "List of ARNs of database subnets"
  value       = local.create_resources ? aws_subnet.database[*].arn : []
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = local.create_resources ? aws_subnet.database[*].cidr_block : []
}

output "database_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 CIDR blocks assigned to the database subnets"
  value       = local.create_resources ? aws_subnet.database[*].ipv6_cidr_block : []
}

output "database_subnet_group" {
  description = "ID of database subnet group"
  value       = local.create_resources && length(local.database_subnet_cidrs) > 0 ? aws_db_subnet_group.database[0].id : null
}

output "database_subnet_group_name" {
  description = "Name of database subnet group"
  value       = local.create_resources && length(local.database_subnet_cidrs) > 0 ? aws_db_subnet_group.database[0].name : null
}

output "cache_subnet_group" {
  description = "ID of cache subnet group"
  value       = local.create_resources && length(var.enabled_caches) > 0 && length(local.database_subnet_cidrs) > 0 ? aws_elasticache_subnet_group.cache[0].name : null
}

output "cache_subnet_group_name" {
  description = "Name of cache subnet group"
  value       = local.create_resources && length(var.enabled_caches) > 0 && length(local.database_subnet_cidrs) > 0 ? aws_elasticache_subnet_group.cache[0].name : null
}

# ----
# NAT Gateways
# ----

output "nat_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = local.create_resources && local.effective_config.nat_gateway_enabled ? aws_nat_gateway.main[*].id : []
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = local.create_resources && local.effective_config.nat_gateway_enabled ? aws_eip.nat[*].public_ip : []
}

output "natgw_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = local.create_resources && local.effective_config.nat_gateway_enabled ? aws_nat_gateway.main[*].id : []
}

# ----
# Route Tables
# ----

output "public_route_table_ids" {
  description = "List of IDs of the public route tables"
  value       = local.create_resources && length(local.public_subnet_cidrs) > 0 && var.igw_enabled ? aws_route_table.public[*].id : []
}

output "private_route_table_ids" {
  description = "List of IDs of the private route tables"
  value       = local.create_resources && length(local.private_subnet_cidrs) > 0 ? aws_route_table.private[*].id : []
}

output "database_route_table_ids" {
  description = "List of IDs of the database route tables"
  value       = local.create_resources && length(local.database_subnet_cidrs) > 0 && var.create_database_route_table ? aws_route_table.database[*].id : []
}

# ----
# AZs
# ----

output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = local.azs
}

output "public_subnet_availability_zones" {
  description = "List of availability zone names for public subnets"
  value       = local.create_resources ? aws_subnet.public[*].availability_zone : []
}

output "public_subnet_availability_zone_ids" {
  description = "List of availability zone IDs for public subnets"
  value       = local.create_resources ? aws_subnet.public[*].availability_zone_id : []
}

output "private_subnet_availability_zones" {
  description = "List of availability zone names for private subnets"
  value       = local.create_resources ? aws_subnet.private[*].availability_zone : []
}

output "private_subnet_availability_zone_ids" {
  description = "List of availability zone IDs for private subnets"
  value       = local.create_resources ? aws_subnet.private[*].availability_zone_id : []
}

output "database_subnet_availability_zones" {
  description = "List of availability zone names for database subnets"
  value       = local.create_resources ? aws_subnet.database[*].availability_zone : []
}

output "database_subnet_availability_zone_ids" {
  description = "List of availability zone IDs for database subnets"
  value       = local.create_resources ? aws_subnet.database[*].availability_zone_id : []
}

# ----
# Non-routable Subnets
# ----

output "nonroutable_subnets" {
  description = "List of IDs of non-routable subnets"
  value       = local.create_resources && local.effective_config.nonroutable_subnets_enabled ? aws_subnet.nonroutable[*].id : []
}

output "nonroutable_subnet_arns" {
  description = "List of ARNs of non-routable subnets"
  value       = local.create_resources && local.effective_config.nonroutable_subnets_enabled ? aws_subnet.nonroutable[*].arn : []
}

output "nonroutable_subnets_cidr_blocks" {
  description = "List of cidr_blocks of non-routable subnets"
  value       = local.create_resources && local.effective_config.nonroutable_subnets_enabled ? aws_subnet.nonroutable[*].cidr_block : []
}

output "nonroutable_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 CIDR blocks assigned to the non-routable subnets"
  value       = local.create_resources && local.effective_config.nonroutable_subnets_enabled ? aws_subnet.nonroutable[*].ipv6_cidr_block : []
}

output "nonroutable_subnet_availability_zones" {
  description = "List of availability zone names for non-routable subnets"
  value       = local.create_resources && local.effective_config.nonroutable_subnets_enabled ? aws_subnet.nonroutable[*].availability_zone : []
}

output "nonroutable_subnet_availability_zone_ids" {
  description = "List of availability zone IDs for non-routable subnets"
  value       = local.create_resources && local.effective_config.nonroutable_subnets_enabled ? aws_subnet.nonroutable[*].availability_zone_id : []
}

# ----
# Security Groups
# ----

output "lb_security_group_id" {
  description = "ID of the load balancer security group"
  value       = module.lb_security_group.security_group_id
}

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = module.db_security_group.security_group_id
}

output "cache_security_group_id" {
  description = "ID of the cache security group"
  value       = module.cache_security_group.security_group_id
}

output "vpc_security_group_id" {
  description = "ID of the VPC-only security group"
  value       = module.vpc_security_group.security_group_id
}

output "endpoint_security_group_id" {
  description = "ID of the endpoint security group"
  value       = module.endpoint_security_group.security_group_id
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = module.app_security_group.security_group_id
}

output "all_security_group_ids" {
  description = "List of all security group IDs"
  value = compact([
    module.lb_security_group.security_group_id,
    module.db_security_group.security_group_id,
    module.cache_security_group.security_group_id,
    module.vpc_security_group.security_group_id,
    module.endpoint_security_group.security_group_id,
    module.app_security_group.security_group_id
  ])
}

# ----
# VPC Flow Logs
# ----

output "vpc_flow_logs_id" {
  description = "ID of the VPC Flow Log"
  value       = local.create_resources && local.effective_config.vpc_flow_logs_enabled ? aws_flow_log.vpc[0].id : null
}

output "vpc_flow_logs_log_group_name" {
  description = "Name of the CloudWatch Log Group for VPC Flow Logs"
  value       = local.create_resources && local.effective_config.vpc_flow_logs_enabled ? aws_cloudwatch_log_group.vpc_flow_logs[0].name : null
}

output "vpc_flow_logs_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for VPC Flow Logs"
  value       = local.create_resources && local.effective_config.vpc_flow_logs_enabled ? aws_cloudwatch_log_group.vpc_flow_logs[0].arn : null
}

output "vpc_flow_logs_kms_key_id" {
  description = "ID of the KMS key used for VPC Flow Logs encryption"
  value       = local.create_resources && local.effective_config.vpc_flow_logs_enabled ? (var.vpc_flow_logs_kms_key_id != null ? var.vpc_flow_logs_kms_key_id : aws_kms_key.flow_logs[0].key_id) : null
}

output "vpc_flow_logs_kms_key_arn" {
  description = "ARN of the KMS key used for VPC Flow Logs encryption"
  value       = local.create_resources && local.effective_config.vpc_flow_logs_enabled ? (var.vpc_flow_logs_kms_key_id != null ? var.vpc_flow_logs_kms_key_id : aws_kms_key.flow_logs[0].arn) : null
}

output "vpc_flow_logs_iam_role_arn" {
  description = "ARN of the IAM role used for VPC Flow Logs"
  value       = local.create_resources && local.effective_config.vpc_flow_logs_enabled ? aws_iam_role.flow_logs[0].arn : null
}

# ----
# VPC Endpoints
# ----

output "gateway_endpoint_ids" {
  description = "Map of service names to their Gateway endpoint IDs"
  value       = module.vpc_endpoints.gateway_endpoint_ids
}

output "interface_endpoint_ids" {
  description = "Map of service names to their Interface endpoint IDs"
  value       = module.vpc_endpoints.interface_endpoint_ids
}

output "all_endpoint_ids" {
  description = "Map of all endpoint service names to their IDs"
  value       = module.vpc_endpoints.all_endpoint_ids
}

output "endpoint_count" {
  description = "Total number of VPC endpoints created"
  value       = module.vpc_endpoints.total_endpoint_count
}

# ----
# Environment Configuration
# ----

output "environment_type" {
  description = "Environment type used for configuration defaults"
  value       = var.environment_type
}

output "environment_config" {
  description = "Effective environment configuration applied"
  value       = local.effective_config
}

# ----
# Pricing
# ----

output "monthly_cost_estimate" {
  description = "Estimated monthly cost in USD for VPC resources"
  value       = module.pricing.monthly_cost_estimate
}

output "cost_breakdown" {
  description = "Detailed breakdown of monthly costs by service"
  value       = module.pricing.cost_breakdown
}

# ----
# Transit Gateway
# ----

output "transit_gateway_attachment_id" {
  description = "ID of the Transit Gateway VPC attachment"
  value       = local.create_resources && var.transit_gateway_attachment_enabled ? aws_ec2_transit_gateway_vpc_attachment.main[0].id : null
}


output "transit_gateway_attachment_vpc_owner_id" {
  description = "VPC owner ID of the Transit Gateway VPC attachment"
  value       = local.create_resources && var.transit_gateway_attachment_enabled ? aws_ec2_transit_gateway_vpc_attachment.main[0].vpc_owner_id : null
}