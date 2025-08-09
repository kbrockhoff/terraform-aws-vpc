# ----
# Subnet CIDR Calculation
# ----

module "subnets" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = local.ipv4_cidr_block
  networks = concat(
    [for i in range(local.private_subnet_count) : {
      name     = "private-${i}"
      new_bits = local.private_new_bits
    }],
    [for i in range(local.public_subnet_count) : {
      name     = "public-${i}"
      new_bits = local.public_new_bits
    }],
    [for i in range(local.database_subnet_count) : {
      name     = "database-${i}"
      new_bits = local.database_new_bits
    }]
  )
}

# ----
# VPC
# ----

resource "aws_vpc" "main" {
  count = local.create_resources ? 1 : 0

  cidr_block                       = var.ipam_pool_enabled ? null : var.cidr_primary
  ipv4_ipam_pool_id                = var.ipam_pool_enabled ? var.ipv4_ipam_pool_id : null
  ipv4_netmask_length              = var.ipam_pool_enabled ? var.ipv4_netmask_length : null
  assign_generated_ipv6_cidr_block = var.ipv6_ipam_pool_enabled ? null : var.ipv6_enabled
  ipv6_ipam_pool_id                = var.ipv6_enabled && var.ipv6_ipam_pool_enabled ? var.ipv6_ipam_pool_id : null
  ipv6_netmask_length              = var.ipv6_enabled && var.ipv6_ipam_pool_enabled ? var.ipv6_netmask_length : null
  instance_tenancy                 = local.effective_config.instance_tenancy
  enable_dns_hostnames             = var.dns_hostnames_enabled
  enable_dns_support               = var.dns_support_enabled

  tags = merge(
    local.common_tags,
    {
      Name                      = "${var.name_prefix}-vpc"
      "${var.networktags_name}" = "standard"
    }
  )
}

# ----
# VPC Block Public Access Options
# ----

resource "aws_vpc_block_public_access_options" "main" {
  count = local.create_resources && var.block_public_access_enabled ? 1 : 0

  internet_gateway_block_mode = "block-bidirectional"

  depends_on = [aws_vpc.main]
}

# ----
# VPC Additional CIDR Block for Non-routable Subnets
# ----

resource "aws_vpc_ipv4_cidr_block_association" "nonroutable" {
  count = local.create_resources ? length(local.nonroutable_subnet_cidrs) : 0

  vpc_id     = aws_vpc.main[0].id
  cidr_block = local.nonroutable_subnet_cidrs[count.index]

  depends_on = [aws_vpc.main]
}

# ----
# Internet Gateway
# ----

resource "aws_internet_gateway" "main" {
  count = local.create_resources && var.igw_enabled && !var.block_public_access_enabled ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-igw"
    }
  )

  depends_on = [aws_vpc.main]
}

# ----
# Egress-Only Internet Gateway for IPv6
# ----

resource "aws_egress_only_internet_gateway" "main" {
  count = local.create_resources && var.ipv6_enabled ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eigw"
    }
  )
}

# ----
# Public Subnets
# ----

resource "aws_subnet" "public" {
  count = local.create_resources ? length(local.public_subnet_cidrs) : 0

  vpc_id                          = aws_vpc.main[0].id
  cidr_block                      = local.public_subnet_cidrs[count.index]
  ipv6_cidr_block                 = var.ipv6_enabled ? local.public_subnet_ipv6_cidrs[count.index] : null
  availability_zone               = local.azs[count.index]
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  assign_ipv6_address_on_creation = var.ipv6_enabled

  tags = merge(
    local.common_tags,
    {
      Name                      = "${local.name_prefix}-public-${local.azs[count.index]}"
      "${var.networktags_name}" = "public"
    }
  )
}

# ----
# Private Subnets
# ----

resource "aws_subnet" "private" {
  count = local.create_resources ? length(local.private_subnet_cidrs) : 0

  vpc_id                          = aws_vpc.main[0].id
  cidr_block                      = local.private_subnet_cidrs[count.index]
  ipv6_cidr_block                 = var.ipv6_enabled ? local.private_subnet_ipv6_cidrs[count.index] : null
  availability_zone               = local.azs[count.index]
  assign_ipv6_address_on_creation = var.ipv6_enabled

  tags = merge(
    local.common_tags,
    {
      Name                      = "${local.name_prefix}-private-${local.azs[count.index]}"
      "${var.networktags_name}" = "private"
    }
  )
}

# ----
# Database Subnets
# ----

resource "aws_subnet" "database" {
  count = local.create_resources ? length(local.database_subnet_cidrs) : 0

  vpc_id                          = aws_vpc.main[0].id
  cidr_block                      = local.database_subnet_cidrs[count.index]
  ipv6_cidr_block                 = var.ipv6_enabled ? local.database_subnet_ipv6_cidrs[count.index] : null
  availability_zone               = local.azs[count.index]
  assign_ipv6_address_on_creation = var.ipv6_enabled

  tags = merge(
    local.common_tags,
    {
      Name                      = "${local.name_prefix}-database-${local.azs[count.index]}"
      "${var.networktags_name}" = "database"
    }
  )
}

# ----
# Database Subnet Group
# ----

resource "aws_db_subnet_group" "database" {
  count = local.create_resources && length(local.database_subnet_cidrs) > 0 ? 1 : 0

  name       = "${local.name_prefix}-database"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    local.common_tags,
    {
      Name                      = "${local.name_prefix}-standard"
      "${var.networktags_name}" = "standard"
    }
  )
}

resource "aws_elasticache_subnet_group" "cache" {
  count = local.create_resources && length(var.enabled_caches) > 0 && length(local.database_subnet_cidrs) > 0 ? 1 : 0

  name       = "${local.name_prefix}-cache"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    local.common_tags,
    {
      Name                      = "${local.name_prefix}-standard"
      "${var.networktags_name}" = "standard"
    }
  )
}

# ----
# Non-routable Subnets
# ----

resource "aws_subnet" "nonroutable" {
  count = local.create_resources && local.effective_config.nonroutable_subnets_enabled ? length(local.nonroutable_subnet_cidrs) : 0

  vpc_id                          = aws_vpc.main[0].id
  cidr_block                      = local.nonroutable_subnet_cidrs[count.index]
  ipv6_cidr_block                 = var.ipv6_enabled ? local.nonroutable_subnet_ipv6_cidrs[count.index] : null
  availability_zone               = local.azs[count.index]
  assign_ipv6_address_on_creation = var.ipv6_enabled

  tags = merge(
    local.common_tags,
    {
      Name                      = "${local.name_prefix}-nonroutable-${local.azs[count.index]}"
      "${var.networktags_name}" = "nonroutable"
    }
  )

  depends_on = [aws_vpc_ipv4_cidr_block_association.nonroutable]
}

# ----
# Elastic IPs for NAT Gateways
# ----

resource "aws_eip" "nat" {
  count = local.create_resources && local.effective_config.nat_gateway_enabled ? local.nat_gateway_count : 0

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = local.nat_gateway_count == 1 ? "${local.name_prefix}-nat-eip" : "${local.name_prefix}-nat-eip-${local.azs[count.index]}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# ----
# NAT Gateways
# ----

resource "aws_nat_gateway" "main" {
  count = local.create_resources && local.effective_config.nat_gateway_enabled ? local.nat_gateway_count : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    local.common_tags,
    {
      Name = local.nat_gateway_count == 1 ? "${local.name_prefix}-nat" : "${local.name_prefix}-nat-${local.azs[count.index]}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# ----
# Public Route Table
# ----

resource "aws_route_table" "public" {
  count = local.create_resources && length(local.public_subnet_cidrs) > 0 && var.igw_enabled ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public"
    }
  )
}

resource "aws_route" "public_internet_gateway" {
  count = local.create_resources && length(local.public_subnet_cidrs) > 0 && var.igw_enabled ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main[0].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "public_internet_gateway_ipv6" {
  count = local.create_resources && var.ipv6_enabled && length(local.public_subnet_cidrs) > 0 && var.igw_enabled ? 1 : 0

  route_table_id              = aws_route_table.public[0].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.main[0].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  count = local.create_resources ? length(local.public_subnet_cidrs) : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# ----
# Private Route Tables
# ----

resource "aws_route_table" "private" {
  count = local.create_resources && length(local.private_subnet_cidrs) > 0 ? (local.nat_gateway_count == 1 ? 1 : length(local.private_subnet_cidrs)) : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(
    local.common_tags,
    {
      Name = local.nat_gateway_count == 1 ? "${local.name_prefix}-private" : "${local.name_prefix}-private-${local.azs[count.index]}"
    }
  )
}

resource "aws_route" "private_nat_gateway" {
  count = local.create_resources && local.effective_config.nat_gateway_enabled ? (local.nat_gateway_count == 1 ? 1 : length(local.private_subnet_cidrs)) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[local.nat_gateway_count == 1 ? 0 : count.index % local.nat_gateway_count].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "private_egress_only_internet_gateway_ipv6" {
  count = local.create_resources && var.ipv6_enabled ? (local.nat_gateway_count == 1 ? 1 : length(local.private_subnet_cidrs)) : 0

  route_table_id              = aws_route_table.private[count.index].id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.main[0].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "private" {
  count = local.create_resources ? length(local.private_subnet_cidrs) : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[local.nat_gateway_count == 1 ? 0 : count.index].id
}

resource "aws_route_table_association" "nonroutable" {
  count = local.create_resources && local.effective_config.nonroutable_subnets_enabled ? length(local.nonroutable_subnet_cidrs) : 0

  subnet_id      = aws_subnet.nonroutable[count.index].id
  route_table_id = aws_route_table.private[local.nat_gateway_count == 1 ? 0 : count.index].id
}

# ----
# Database Route Tables
# ----

resource "aws_route_table" "database" {
  count = local.create_resources && length(local.database_subnet_cidrs) > 0 && var.create_database_route_table ? (local.nat_gateway_count == 1 ? 1 : length(local.database_subnet_cidrs)) : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(
    local.common_tags,
    {
      Name = local.nat_gateway_count == 1 ? "${local.name_prefix}-database" : "${local.name_prefix}-database-${local.azs[count.index]}"
    }
  )
}



resource "aws_route_table_association" "database" {
  count = local.create_resources && length(local.database_subnet_cidrs) > 0 && var.create_database_route_table ? length(local.database_subnet_cidrs) : 0

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[local.nat_gateway_count == 1 ? 0 : count.index].id
}


# ----
# Default Route Table
# ----

resource "aws_default_route_table" "default" {
  count = local.create_resources ? 1 : 0

  default_route_table_id = aws_vpc.main[0].default_route_table_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-default-rt"
    }
  )
}

# ----
# Default Network ACL
# ----

resource "aws_default_network_acl" "default" {
  count = local.create_resources ? 1 : 0

  default_network_acl_id = aws_vpc.main[0].default_network_acl_id

  dynamic "ingress" {
    for_each = var.default_network_acl_ingress
    content {
      action          = ingress.value.action
      cidr_block      = lookup(ingress.value, "cidr_block", null)
      from_port       = lookup(ingress.value, "from_port", 0)
      icmp_code       = lookup(ingress.value, "icmp_code", null)
      icmp_type       = lookup(ingress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr_block", null)
      protocol        = ingress.value.protocol
      rule_no         = ingress.value.rule_no
      to_port         = lookup(ingress.value, "to_port", 0)
    }
  }

  dynamic "egress" {
    for_each = var.default_network_acl_egress
    content {
      action          = egress.value.action
      cidr_block      = lookup(egress.value, "cidr_block", null)
      from_port       = lookup(egress.value, "from_port", 0)
      icmp_code       = lookup(egress.value, "icmp_code", null)
      icmp_type       = lookup(egress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr_block", null)
      protocol        = egress.value.protocol
      rule_no         = egress.value.rule_no
      to_port         = lookup(egress.value, "to_port", 0)
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-default-nacl"
    }
  )

  # Ignore subnet associations to prevent conflicts with explicit subnets
  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

# ----
# Security Groups
# ----

resource "aws_default_security_group" "default" {
  count = local.create_resources ? 1 : 0

  vpc_id = aws_vpc.main[0].id
  tags = merge(
    local.common_tags,
    {
      Name                      = "${local.name_prefix}-default-sg"
      "${var.networktags_name}" = "default"
    }
  )
}

module "lb_security_group" {
  source = "./modules/security-group"

  enabled = local.create_resources

  name              = "${var.name_prefix}-lb-sg"
  description       = "Load balancer security group with VPC access and HTTPS ingress"
  vpc_id            = local.create_resources ? aws_vpc.main[0].id : null
  vpc_cidr_block    = local.create_resources ? aws_vpc.main[0].cidr_block : null
  networktags_name  = var.networktags_name
  networktags_value = "public"

  ingress_named_rules = [
    {
      named_rule  = "https"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      named_rule       = "https"
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  egress_named_rules = [
    {
      named_rule  = "https"
      cidr_blocks = concat(local.private_subnet_cidrs, local.nonroutable_subnet_cidrs)
    },
    {
      named_rule       = "https"
      ipv6_cidr_blocks = var.ipv6_enabled ? concat(local.private_subnet_ipv6_cidrs, local.nonroutable_subnet_ipv6_cidrs) : []
    },
    {
      named_rule  = "https-8443"
      cidr_blocks = concat(local.private_subnet_cidrs, local.nonroutable_subnet_cidrs)
    },
    {
      named_rule       = "https-8443"
      ipv6_cidr_blocks = var.ipv6_enabled ? concat(local.private_subnet_ipv6_cidrs, local.nonroutable_subnet_ipv6_cidrs) : []
    }
  ]

  tags = local.common_tags
}

module "db_security_group" {
  source = "./modules/security-group"

  enabled = local.create_resources && length(var.enabled_databases) > 0

  name              = "${var.name_prefix}-db-sg"
  description       = "Database security group with VPC non-public DB ingress"
  vpc_id            = local.create_resources ? aws_vpc.main[0].id : null
  vpc_cidr_block    = local.create_resources ? aws_vpc.main[0].cidr_block : null
  networktags_name  = var.networktags_name
  networktags_value = "database"

  ingress_named_rules = concat(
    [for db in var.enabled_databases : {
      named_rule  = db
      cidr_blocks = concat(local.private_subnet_cidrs, local.nonroutable_subnet_cidrs)
    }],
    var.ipv6_enabled ? [for db in var.enabled_databases : {
      named_rule       = db
      ipv6_cidr_blocks = concat(local.private_subnet_ipv6_cidrs, local.nonroutable_subnet_ipv6_cidrs)
    }] : []
  )

  tags = local.common_tags
}

module "cache_security_group" {
  source = "./modules/security-group"

  enabled = local.create_resources && length(var.enabled_caches) > 0

  name              = "${var.name_prefix}-cache-sg"
  description       = "Cache security group with VPC non-public cache ingress"
  vpc_id            = local.create_resources ? aws_vpc.main[0].id : null
  vpc_cidr_block    = local.create_resources ? aws_vpc.main[0].cidr_block : null
  networktags_name  = var.networktags_name
  networktags_value = "cache"

  ingress_named_rules = concat(
    [for cache in var.enabled_caches : {
      named_rule  = cache
      cidr_blocks = concat(local.private_subnet_cidrs, local.nonroutable_subnet_cidrs)
    }],
    var.ipv6_enabled ? [for cache in var.enabled_caches : {
      named_rule       = cache
      ipv6_cidr_blocks = concat(local.private_subnet_ipv6_cidrs, local.nonroutable_subnet_ipv6_cidrs)
    }] : []
  )

  tags = local.common_tags
}

module "vpc_security_group" {
  source = "./modules/security-group"

  enabled = local.create_resources

  name              = "${var.name_prefix}-vpc-sg"
  description       = "VPC-only security group with VPC traffic only"
  vpc_id            = local.create_resources ? aws_vpc.main[0].id : null
  vpc_cidr_block    = local.create_resources ? aws_vpc.main[0].cidr_block : null
  networktags_name  = var.networktags_name
  networktags_value = "vpconly"

  ingress_rules = [
    {
      description = "All traffic from VPC"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = local.create_resources ? concat([aws_vpc.main[0].cidr_block], local.nonroutable_subnet_cidrs) : []
    },
    {
      description      = "All traffic from VPC IPv6"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      ipv6_cidr_blocks = local.create_resources && var.ipv6_enabled ? [aws_vpc.main[0].ipv6_cidr_block] : []
    }
  ]

  egress_rules = [
    {
      description = "All traffic to VPC"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = local.create_resources ? concat([aws_vpc.main[0].cidr_block], local.nonroutable_subnet_cidrs) : []
    },
    {
      description      = "All traffic to VPC IPv6"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      ipv6_cidr_blocks = local.create_resources && var.ipv6_enabled ? [aws_vpc.main[0].ipv6_cidr_block] : []
    }
  ]

  tags = local.common_tags
}

module "endpoint_security_group" {
  source = "./modules/security-group"

  enabled = local.create_resources

  name              = "${var.name_prefix}-endpoint-sg"
  description       = "Endpoint security group with VPC non-public HTTPS ingress"
  vpc_id            = local.create_resources ? aws_vpc.main[0].id : null
  vpc_cidr_block    = local.create_resources ? aws_vpc.main[0].cidr_block : null
  networktags_name  = var.networktags_name
  networktags_value = "endpoint"

  ingress_named_rules = [
    {
      named_rule  = "https"
      cidr_blocks = concat(local.private_subnet_cidrs, local.nonroutable_subnet_cidrs)
    },
    {
      named_rule       = "https"
      ipv6_cidr_blocks = var.ipv6_enabled ? concat(local.private_subnet_ipv6_cidrs, local.nonroutable_subnet_ipv6_cidrs) : []
    }
  ]

  tags = local.common_tags
}

module "app_security_group" {
  source = "./modules/security-group"

  enabled = local.create_resources

  name              = "${var.name_prefix}-app-sg"
  description       = "Application security group with VPC access and HTTPS egress"
  vpc_id            = local.create_resources ? aws_vpc.main[0].id : null
  vpc_cidr_block    = local.create_resources ? aws_vpc.main[0].cidr_block : null
  networktags_name  = var.networktags_name
  networktags_value = "private"

  ingress_rules = [
    {
      description = "All traffic from VPC"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = local.create_resources ? concat([aws_vpc.main[0].cidr_block], local.nonroutable_subnet_cidrs) : []
    },
    {
      description      = "All traffic from VPC IPv6"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      ipv6_cidr_blocks = local.create_resources && var.ipv6_enabled ? [aws_vpc.main[0].ipv6_cidr_block] : []
    }
  ]

  egress_rules = [
    {
      description = "HTTPS egress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description      = "HTTPS egress IPv6"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      ipv6_cidr_blocks = ["::/0"]
    },
    {
      description = "All traffic to VPC"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = local.create_resources ? concat([aws_vpc.main[0].cidr_block], local.nonroutable_subnet_cidrs) : []
    },
    {
      description      = "All traffic to VPC IPv6"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      ipv6_cidr_blocks = local.create_resources && var.ipv6_enabled ? [aws_vpc.main[0].ipv6_cidr_block] : []
    }
  ]

  tags = local.common_tags
}
