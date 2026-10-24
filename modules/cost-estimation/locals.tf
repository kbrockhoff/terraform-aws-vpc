# ----
# Cost calculation
# ----

locals {
  # The parent passes a provider pinned to us-east-1, where the Pricing API is available
  pricing_enabled = var.enabled

  # Hours per month for always-on resources
  hours_per_month = 730

  # Raw Pricing API results keyed by cost component
  pricing_results = local.pricing_enabled ? {
    nat_gateway_hours                = data.aws_pricing_product.nat_gateway_hours[0].result
    nat_gateway_data                 = data.aws_pricing_product.nat_gateway_data[0].result
    public_ipv4_addresses            = data.aws_pricing_product.public_ipv4_addresses[0].result
    interface_endpoint_hours         = data.aws_pricing_product.interface_endpoint_hours[0].result
    interface_endpoint_data          = data.aws_pricing_product.interface_endpoint_data[0].result
    flow_logs_ingestion              = data.aws_pricing_product.flow_logs_ingestion[0].result
    flow_logs_storage                = data.aws_pricing_product.flow_logs_storage[0].result
    kms_keys                         = data.aws_pricing_product.kms_keys[0].result
    transit_gateway_attachment_hours = data.aws_pricing_product.transit_gateway_attachment_hours[0].result
  } : {}

  # us-east-1 on-demand prices in USD, used only when a result cannot be parsed
  default_unit_prices = {
    nat_gateway_hours                = 0.045 # per NAT gateway-hour
    nat_gateway_data                 = 0.045 # per GB processed
    public_ipv4_addresses            = 0.005 # per in-use public IPv4 address-hour
    interface_endpoint_hours         = 0.01  # per endpoint-AZ-hour
    interface_endpoint_data          = 0.01  # per GB processed, first tier
    flow_logs_ingestion              = 0.50  # per GB of vended logs ingested, first tier
    flow_logs_storage                = 0.03  # per GB-month stored
    kms_keys                         = 1.00  # per key-month
    transit_gateway_attachment_hours = 0.05  # per attachment-hour
  }

  # Paid price tiers of each product's on-demand offer. $0 free tiers are account-wide,
  # so they are not credited to a single module.
  paid_price_dimensions = {
    for k, r in local.pricing_results : k => try([
      for d in values(values(jsondecode(r).terms.OnDemand)[0].priceDimensions) : d
      if tonumber(d.pricePerUnit.USD) > 0
    ], [])
  }

  # Unit price of the lowest paid tier per component
  unit_prices = {
    for k, default in local.default_unit_prices : k => try([
      for d in local.paid_price_dimensions[k] : tonumber(d.pricePerUnit.USD)
      if tonumber(d.beginRange) == min([for t in local.paid_price_dimensions[k] : tonumber(t.beginRange)]...)
    ][0], default)
  }

  costs = {
    nat_gateway_hours                = var.nat_gateway_count * local.hours_per_month * local.unit_prices.nat_gateway_hours
    nat_gateway_data                 = var.nat_gateway_data_gb * local.unit_prices.nat_gateway_data
    public_ipv4_addresses            = var.public_ipv4_address_count * local.hours_per_month * local.unit_prices.public_ipv4_addresses
    interface_endpoint_hours         = var.interface_endpoint_az_count * local.hours_per_month * local.unit_prices.interface_endpoint_hours
    interface_endpoint_data          = var.interface_endpoint_data_gb * local.unit_prices.interface_endpoint_data
    flow_logs_ingestion              = var.flow_logs_ingestion_gb * local.unit_prices.flow_logs_ingestion
    flow_logs_storage                = var.flow_logs_storage_gb * local.unit_prices.flow_logs_storage
    kms_keys                         = var.kms_key_count * local.unit_prices.kms_keys
    transit_gateway_attachment_hours = var.transit_gateway_attachment_count * local.hours_per_month * local.unit_prices.transit_gateway_attachment_hours
  }

  total_monthly_cost = sum(values(local.costs))
}
