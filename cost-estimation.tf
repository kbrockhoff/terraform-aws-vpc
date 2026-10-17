# ----
# Pricing Calculator
# ----

locals {
  # Usage assumption: MB per hour through NAT gateways and interface endpoints combined, as GB per month
  cost_data_gb_per_month = local.effective_config.data_transfer_mb_per_hour * 730 / 1024

  cost_flow_logs_enabled = var.enabled && local.effective_config.vpc_flow_logs_enabled
  cost_nat_gateway_count = var.enabled && local.effective_config.nat_gateway_enabled ? local.nat_gateway_count : 0
  cost_interface_endpoint_az_count = local.interface_endpoints_enabled ? (
    local.interface_endpoints_count * local.interface_endpoints_az_count
  ) : 0
  cost_flow_logs_gb_per_month = local.cost_flow_logs_enabled ? var.cost_estimation_config.flow_logs_gb_per_month : 0

  # Split the traffic between NAT gateways and interface endpoints so it is not counted twice;
  # when only one of them exists it carries all of it
  cost_endpoint_traffic_share = local.cost_interface_endpoint_az_count == 0 ? 0 : (
    local.cost_nat_gateway_count == 0 ? 1 : var.cost_estimation_config.vpc_endpoint_traffic_percent / 100
  )
  cost_nat_gateway_data_gb        = local.cost_nat_gateway_count > 0 ? local.cost_data_gb_per_month * (1 - local.cost_endpoint_traffic_share) : 0
  cost_interface_endpoint_data_gb = local.cost_data_gb_per_month * local.cost_endpoint_traffic_share
}

module "pricing" {
  source = "./modules/cost-estimation"

  providers = {
    aws = aws.pricing
  }

  enabled = var.enabled && var.cost_estimation_config.enabled
  region  = local.region

  nat_gateway_count           = local.cost_nat_gateway_count
  nat_gateway_data_gb         = local.cost_nat_gateway_data_gb
  public_ipv4_address_count   = local.cost_nat_gateway_count # One Elastic IP per NAT gateway
  interface_endpoint_az_count = local.cost_interface_endpoint_az_count
  interface_endpoint_data_gb  = local.cost_interface_endpoint_data_gb
  flow_logs_ingestion_gb      = local.cost_flow_logs_gb_per_month
  # Steady state: each month's logs are kept for the retention period
  flow_logs_storage_gb             = local.cost_flow_logs_gb_per_month * local.effective_config.vpc_flow_logs_retention_days / 30
  kms_key_count                    = local.create_vpc_flow_logs_kms_key ? 1 : 0
  transit_gateway_attachment_count = var.enabled && var.transit_gateway_attachment_enabled ? 1 : 0
}
