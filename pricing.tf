# ----
# Pricing Calculator
# ----

module "pricing" {
  source = "./modules/pricing"

  providers = {
    aws = aws.pricing
  }

  enabled                      = var.enabled && var.cost_estimation_config.enabled
  region                       = local.region
  data_transfer_mb_per_hour    = local.effective_config.data_transfer_mb_per_hour
  nat_gateway_count            = local.nat_gateway_count
  vpc_flow_logs_enabled        = local.effective_config.vpc_flow_logs_enabled
  create_vpc_flow_logs_kms_key = local.effective_config.create_vpc_flow_logs_kms_key
  interface_endpoints_count    = local.interface_endpoints_count
  interface_endpoints_az_count = local.interface_endpoints_az_count
}