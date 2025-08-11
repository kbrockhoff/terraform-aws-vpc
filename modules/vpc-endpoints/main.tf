# ----
# Gateway Endpoints (S3, DynamoDB)
# ----

resource "aws_vpc_endpoint" "gateway" {
  for_each = var.enabled ? toset(var.gateway_endpoints) : toset([])

  vpc_id            = var.vpc_id
  service_name      = "${var.reverse_dns_prefix}.${var.region}.${each.value}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  policy = (
    var.policy_enabled && contains(keys(var.endpoint_policies), each.value) ? var.endpoint_policies[each.value] :
    var.default_policy_enabled ? var.default_policy :
    null
  )

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.value}-gateway-endpoint"
    Type = "Gateway"
  })
}

# ----
# Interface Endpoints
# ----

resource "aws_vpc_endpoint" "interface" {
  for_each = var.enabled ? toset(var.interface_endpoints) : toset([])

  vpc_id              = var.vpc_id
  service_name        = "${var.reverse_dns_prefix}.${var.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = var.security_group_ids
  private_dns_enabled = var.private_dns_enabled

  policy = (
    var.policy_enabled && contains(keys(var.endpoint_policies), each.value) ? var.endpoint_policies[each.value] :
    var.default_policy_enabled ? var.default_policy :
    null
  )

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.value}-interface-endpoint"
    Type = "Interface"
  })
}