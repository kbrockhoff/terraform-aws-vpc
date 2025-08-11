# ----
# VPC Endpoints
# ----

module "vpc_endpoints" {
  source = "./modules/vpc-endpoints"

  enabled = local.gateway_endpoints_enabled || local.interface_endpoints_enabled

  name_prefix        = var.name_prefix
  vpc_id             = var.enabled ? aws_vpc.main[0].id : null
  region             = local.region
  reverse_dns_prefix = local.reverse_dns_prefix

  # Gateway endpoints use route tables
  route_table_ids = local.gateway_endpoints_enabled ? compact(concat(
    aws_route_table.private[*].id,
    aws_route_table.database[*].id
  )) : []

  # Interface endpoints use non-routable subnets if enabled, otherwise private subnets
  subnet_ids = local.interface_endpoints_enabled ? (
    local.effective_config.nonroutable_subnets_enabled ? aws_subnet.nonroutable[*].id : aws_subnet.private[*].id
  ) : []
  security_group_ids = local.interface_endpoints_enabled ? [module.endpoint_security_group.security_group_id] : []

  gateway_endpoints   = var.gateway_endpoints
  interface_endpoints = var.interface_endpoints

  policy_enabled         = var.endpoint_policy_enabled
  endpoint_policies      = var.endpoint_policies
  private_dns_enabled    = var.endpoint_private_dns_enabled
  default_policy_enabled = var.endpoint_default_policy_enabled
  default_policy         = var.endpoint_default_policy

  tags = local.common_tags
}