output "vpc_id" {
  description = "ID of the VPC"
  value       = module.main.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.main.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.main.private_subnets
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.main.private_subnets_cidr_blocks
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.main.database_subnets
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = module.main.database_subnets_cidr_blocks
}

output "vpc_security_group_id" {
  description = "ID of the VPC-only security group"
  value       = module.main.vpc_security_group_id
}

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = module.main.db_security_group_id
}

output "endpoint_security_group_id" {
  description = "ID of the endpoint security group"
  value       = module.main.endpoint_security_group_id
}

output "gateway_endpoint_ids" {
  description = "Map of service names to their Gateway endpoint IDs"
  value       = module.main.gateway_endpoint_ids
}

output "interface_endpoint_ids" {
  description = "Map of service names to their Interface endpoint IDs"
  value       = module.main.interface_endpoint_ids
}

output "vpc_flow_logs_id" {
  description = "ID of the VPC Flow Log"
  value       = module.main.vpc_flow_logs_id
}

output "block_public_access_enabled" {
  description = "Whether VPC block public access is enabled"
  value       = module.main.block_public_access_enabled
}