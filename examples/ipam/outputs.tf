# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.main.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.main.vpc_arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC (allocated by IPAM)"
  value       = module.main.vpc_cidr_block
}

output "vpc_ipv6_cidr_block" {
  description = "The IPv6 CIDR block of the VPC (allocated by IPAM if enabled)"
  value       = module.main.vpc_ipv6_cidr_block
}

# IPAM Specific Outputs
output "ipam_pool_id" {
  description = "The ID of the IPAM pool used for IPv4 allocation"
  value       = var.ipv4_ipam_pool_id
}

output "ipv4_netmask_length" {
  description = "The netmask length of the IPv4 CIDR allocated from IPAM"
  value       = var.ipv4_netmask_length
}

output "ipv6_ipam_pool_id" {
  description = "The ID of the IPAM pool used for IPv6 allocation"
  value       = var.ipv6_ipam_pool_id
}

# Subnet Outputs
output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.main.public_subnets
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.main.private_subnets
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.main.database_subnets
}

output "nonroutable_subnets" {
  description = "List of IDs of non-routable subnets"
  value       = module.main.nonroutable_subnets
}

# Gateway Outputs
output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.main.igw_id
}

output "natgw_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = module.main.natgw_ids
}

# Database Subnet Groups
output "database_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = module.main.database_subnet_group_name
}

output "cache_subnet_group_name" {
  description = "Name of the cache subnet group"
  value       = module.main.cache_subnet_group_name
}

# Cost Estimation
output "monthly_cost_estimate" {
  description = "Estimated monthly cost in USD"
  value       = module.main.monthly_cost_estimate
}