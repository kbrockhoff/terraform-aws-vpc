# ----
# Gateway Endpoints
# ----

output "gateway_endpoint_ids" {
  description = "Map of service names to their Gateway endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.gateway : k => v.id }
}

output "gateway_endpoint_dns_entries" {
  description = "Map of service names to their Gateway endpoint DNS entries"
  value       = { for k, v in aws_vpc_endpoint.gateway : k => v.dns_entry }
}

output "gateway_endpoint_prefix_list_ids" {
  description = "Map of service names to their Gateway endpoint prefix list IDs"
  value       = { for k, v in aws_vpc_endpoint.gateway : k => v.prefix_list_id }
}

# ----
# Interface Endpoints
# ----

output "interface_endpoint_ids" {
  description = "Map of service names to their Interface endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.id }
}

output "interface_endpoint_dns_entries" {
  description = "Map of service names to their Interface endpoint DNS entries"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.dns_entry }
}

output "interface_endpoint_network_interface_ids" {
  description = "Map of service names to their Interface endpoint network interface IDs"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.network_interface_ids }
}

# ----
# All Endpoints
# ----

output "all_endpoint_ids" {
  description = "Map of all endpoint service names to their IDs"
  value = merge(
    { for k, v in aws_vpc_endpoint.gateway : k => v.id },
    { for k, v in aws_vpc_endpoint.interface : k => v.id }
  )
}

output "all_endpoint_arns" {
  description = "Map of all endpoint service names to their ARNs"
  value = merge(
    { for k, v in aws_vpc_endpoint.gateway : k => v.arn },
    { for k, v in aws_vpc_endpoint.interface : k => v.arn }
  )
}

output "gateway_endpoint_count" {
  description = "Number of Gateway endpoints created"
  value       = length(aws_vpc_endpoint.gateway)
}

output "interface_endpoint_count" {
  description = "Number of Interface endpoints created"
  value       = length(aws_vpc_endpoint.interface)
}

output "total_endpoint_count" {
  description = "Total number of VPC endpoints created"
  value       = length(aws_vpc_endpoint.gateway) + length(aws_vpc_endpoint.interface)
}