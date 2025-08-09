# ----
# Pricing Calculator Outputs
# ----

output "monthly_cost_estimate" {
  description = "Total estimated monthly cost in USD for VPC resources"
  value       = local.pricing_enabled ? local.total_monthly_cost : 0
}

output "cost_breakdown" {
  description = "Detailed breakdown of monthly costs by service"
  value = local.pricing_enabled ? {
    nat_gateway_fixed           = local.costs.nat_gateway_fixed
    nat_gateway_data_processing = local.costs.nat_gateway_data
    vpc_flow_logs_ingestion     = local.costs.flow_logs_ingestion
    vpc_flow_logs_storage       = local.costs.flow_logs_storage
    kms_keys                    = local.costs.kms_keys
    interface_endpoints_fixed   = local.costs.interface_endpoints_fixed
    interface_endpoints_data    = local.costs.interface_endpoints_data
    gateway_endpoints           = local.costs.gateway_endpoints
    total                       = local.total_monthly_cost
  } : {}
}

output "resource_counts" {
  description = "Count of billable resources"
  value = {
    nat_gateways                       = var.nat_gateway_count
    interface_endpoints_count          = var.interface_endpoints_count
    interface_endpoints_az_count       = var.interface_endpoints_az_count
    total_interface_endpoint_instances = local.total_interface_endpoint_instances
    kms_keys                           = var.create_vpc_flow_logs_kms_key && var.vpc_flow_logs_enabled ? 1 : 0
  }
}

output "data_transfer_estimates" {
  description = "Data transfer calculations"
  value = {
    data_transfer_mb_per_hour  = var.data_transfer_mb_per_hour
    data_transfer_gb_per_month = local.data_transfer_gb_per_month
  }
}

output "pricing_rates" {
  description = "Current AWS pricing rates used in calculations"
  value = {
    nat_gateway_hourly               = local.nat_gateway_hourly
    nat_gateway_data_per_gb          = local.nat_gateway_data_per_gb
    vpc_endpoint_hourly              = local.vpc_endpoint_hourly
    vpc_endpoint_data_per_gb         = local.vpc_endpoint_data_per_gb
    cloudwatch_logs_ingestion_per_gb = local.cloudwatch_logs_ingestion_per_gb
    cloudwatch_storage_per_gb_month  = local.cloudwatch_storage_per_gb_month
    kms_monthly                      = local.kms_monthly
  }
}

output "pricing_api_status" {
  description = "Status of AWS Pricing API availability"
  value = {
    region_code           = var.region
    pricing_api_available = true # Always true since we use dedicated provider pointing to us-east-1
    pricing_enabled       = local.pricing_enabled
    supported_regions     = local.pricing_api_supported_regions
    using_fallback_rates  = false # Never using fallback rates since we always use supported region
  }
}