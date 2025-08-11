# ----
# Transit Gateway VPC Attachment
# ----

locals {
  # Determine which subnets to use for TGW attachment
  transit_gateway_subnet_ids = var.transit_gateway_attachment_enabled ? (
    var.transit_gateway_attachment_subnets == "private" ? aws_subnet.private[*].id :
    var.transit_gateway_attachment_subnets == "database" ? aws_subnet.database[*].id :
    []
  ) : []
}

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  count = var.enabled && var.transit_gateway_attachment_enabled ? 1 : 0

  subnet_ids                                      = local.transit_gateway_subnet_ids
  transit_gateway_id                              = var.transit_gateway_id
  vpc_id                                          = aws_vpc.main[0].id
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-tgw-attachment"
    }
  )
}

# ----
# Transit Gateway Route Table Association (Custom)
# ----

resource "aws_ec2_transit_gateway_route_table_association" "main" {
  count = var.enabled && var.transit_gateway_attachment_enabled && var.transit_gateway_route_table_id != null ? 1 : 0

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main[0].id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}

# ----
# Transit Gateway Route Table Propagation (Custom)
# ----

resource "aws_ec2_transit_gateway_route_table_propagation" "main" {
  count = var.enabled && var.transit_gateway_attachment_enabled && var.transit_gateway_route_table_id != null ? 1 : 0

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main[0].id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}