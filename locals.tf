locals {
  # Environment type configuration maps
  environment_defaults = {
    None = {
      rpo_hours                    = null
      rto_hours                    = null
      data_transfer_mb_per_hour    = var.cost_estimation_config.data_transfer_mb_per_hour
      nat_gateway_enabled          = var.nat_gateway_enabled
      resilient_natgateway_enabled = var.resilient_natgateway_enabled
      vpc_flow_logs_enabled        = var.vpc_flow_logs_enabled
      vpc_flow_logs_retention_days = var.vpc_flow_logs_retention_days
      create_vpc_flow_logs_kms_key = var.create_vpc_flow_logs_kms_key
      db_az_count                  = var.desired_database_subnet_count
      az_count                     = var.availability_zone_count
      instance_tenancy             = var.instance_tenancy
      nonroutable_subnets_enabled  = var.nonroutable_subnets_enabled
    }
    Ephemeral = {
      rpo_hours                    = null
      rto_hours                    = 48
      data_transfer_mb_per_hour    = 1 # 1 MB/hour - very low usage
      nat_gateway_enabled          = true
      resilient_natgateway_enabled = false
      vpc_flow_logs_enabled        = false
      vpc_flow_logs_retention_days = 7
      create_vpc_flow_logs_kms_key = false
      db_az_count                  = 2
      az_count                     = 2
      instance_tenancy             = "default"
      nonroutable_subnets_enabled  = true
    }
    Development = {
      rpo_hours                    = 24
      rto_hours                    = 48
      data_transfer_mb_per_hour    = 10 # 10 MB/hour - moderate development usage
      nat_gateway_enabled          = true
      resilient_natgateway_enabled = false
      vpc_flow_logs_enabled        = false
      vpc_flow_logs_retention_days = 14
      create_vpc_flow_logs_kms_key = true
      db_az_count                  = 2
      az_count                     = 2
      instance_tenancy             = "default"
      nonroutable_subnets_enabled  = true
    }
    Testing = {
      rpo_hours                    = 24
      rto_hours                    = 48
      data_transfer_mb_per_hour    = 50 # 50 MB/hour - regular testing workloads
      nat_gateway_enabled          = true
      resilient_natgateway_enabled = false
      vpc_flow_logs_enabled        = true
      vpc_flow_logs_retention_days = 30
      create_vpc_flow_logs_kms_key = true
      db_az_count                  = 2
      az_count                     = 2
      instance_tenancy             = "default"
      nonroutable_subnets_enabled  = true
    }
    UAT = {
      rpo_hours                    = 12
      rto_hours                    = 24
      data_transfer_mb_per_hour    = 100 # 100 MB/hour - pre-production workloads
      nat_gateway_enabled          = true
      resilient_natgateway_enabled = true
      vpc_flow_logs_enabled        = true
      vpc_flow_logs_retention_days = 90
      create_vpc_flow_logs_kms_key = true
      db_az_count                  = 2
      az_count                     = 3
      instance_tenancy             = "default"
      nonroutable_subnets_enabled  = true
    }
    Production = {
      rpo_hours                    = 1
      rto_hours                    = 4
      data_transfer_mb_per_hour    = 500 # 500 MB/hour - production workloads
      nat_gateway_enabled          = true
      resilient_natgateway_enabled = true
      vpc_flow_logs_enabled        = true
      vpc_flow_logs_retention_days = 365
      create_vpc_flow_logs_kms_key = true
      consensus_private_enabled    = true
      db_az_count                  = 3
      az_count                     = 3
      instance_tenancy             = "default"
      nonroutable_subnets_enabled  = true
    }
    MissionCritical = {
      rpo_hours                    = 0.083 # 5 minutes
      rto_hours                    = 1
      data_transfer_mb_per_hour    = 2000 # 2 GB/hour - high-volume mission critical
      nat_gateway_enabled          = true
      resilient_natgateway_enabled = true
      vpc_flow_logs_enabled        = true
      vpc_flow_logs_retention_days = 3653 # 10 years
      create_vpc_flow_logs_kms_key = true
      consensus_private_enabled    = true
      db_az_count                  = 3
      az_count                     = 3
      instance_tenancy             = "dedicated"
      nonroutable_subnets_enabled  = true
    }
  }

  # Apply environment defaults when environment_type is not "None"
  effective_config = var.environment_type == "None" ? (
    local.environment_defaults.None
    ) : (
    local.environment_defaults[var.environment_type]
  )

  # AWS account, partition, and region info
  account_id         = data.aws_caller_identity.current.account_id
  partition          = data.aws_partition.current.partition
  region             = data.aws_region.current.region
  dns_suffix         = data.aws_partition.current.dns_suffix
  reverse_dns_prefix = data.aws_partition.current.reverse_dns_prefix

  # Common tags for all resources including module metadata
  common_tags = merge(var.tags, {
    ModuleName    = "kbrockhoff/vpc/aws"
    ModuleVersion = local.module_version
    ModuleEnvType = var.environment_type
  })
  # Data tags take precedence over common tags
  common_data_tags = merge(local.common_tags, var.data_tags)

  # Get availability zones from data source
  availability_zones = data.aws_availability_zones.available.names

  # Select AZs based on allowed list or randomly from all available
  available_azs = length(var.allowed_availability_zone_ids) > 0 ? (
    var.allowed_availability_zone_ids
    ) : (
    local.availability_zones
  )
  azs = local.available_azs

  ipv4_cidr_block = var.enabled ? aws_vpc.main[0].cidr_block : (var.ipam_pool_enabled ? "10.0.0.0/24" : var.cidr_primary)
  ipv6_cidr_block = var.enabled && var.ipv6_enabled ? aws_vpc.main[0].ipv6_cidr_block : (var.ipv6_enabled ? "2001:db8::/56" : null)

  # Calculate subnet counts based on consensus protocol requirements
  private_subnet_count     = min(local.effective_config.az_count, length(local.availability_zones))
  public_subnet_count      = var.block_public_access_enabled ? 0 : min(2, local.private_subnet_count)
  database_subnet_count    = min(local.effective_config.db_az_count, length(local.availability_zones))
  nonroutable_subnet_count = local.private_subnet_count

  # Calculate NAT Gateway count based on configuration
  nat_gateway_count = local.effective_config.nat_gateway_enabled ? (
    local.effective_config.resilient_natgateway_enabled ? local.public_subnet_count : 1
  ) : 0

  # VPC Endpoints configuration
  gateway_endpoints_enabled   = var.enabled && length(var.gateway_endpoints) > 0
  interface_endpoints_enabled = var.enabled && length(var.interface_endpoints) > 0

  # Calculate Interface Endpoints count for pricing
  interface_endpoints_count = length(var.interface_endpoints)
  interface_endpoints_az_count = local.effective_config.nonroutable_subnets_enabled ? (
    local.nonroutable_subnet_count
    ) : (
    local.private_subnet_count
  )

  ################################################################################
  # WARNING: CORE ALGORITHM - MODIFICATIONS REQUIRE ARCHITECTURE REVIEW
  # This section performs complex calculations for subnet CIDRs that optimize IP
  # space usage while maintaining AWS subnet requirements (minimum /28).
  # Changes here have previously caused incorrect CIDR block allocations
  # because of incorrect calculations on intended unequal subnet sizes.
  ################################################################################

  # Calculate new_bits to fit all required subnets
  # Public subnets need at least /28 (16 IPs, 11 usable after AWS reserves 5)
  # Database subnets need at least /28 (16 IPs, 11 usable after AWS reserves 5)
  vpc_prefix_length      = var.ipam_pool_enabled ? var.ipv4_netmask_length : tonumber(split("/", var.cidr_primary)[1])
  vpc_ips_count          = pow(2, 32 - local.vpc_prefix_length)
  public_prefix_length   = 28
  database_prefix_length = 28
  public_new_bits        = local.public_prefix_length - local.vpc_prefix_length
  database_new_bits      = local.database_prefix_length - local.vpc_prefix_length
  private_ips_count = local.vpc_ips_count - (
    pow(2, 32 - local.public_prefix_length) * local.public_subnet_count
    ) - (
    pow(2, 32 - local.database_prefix_length) * local.database_subnet_count
  )
  ips_per_subnet        = floor(local.private_ips_count / local.private_subnet_count)
  private_prefix_length = 32 - floor(log(local.ips_per_subnet, 2))
  private_new_bits      = local.private_prefix_length - local.vpc_prefix_length
  # Non-routable subnet calculations
  all_nonroutable_cidrs = [
    "100.64.0.0/16",
    "100.65.0.0/16",
    "100.66.0.0/16",
    "100.67.0.0/16",
    "100.68.0.0/16",
    "100.69.0.0/16",
  ]

  # Calculate subnet CIDRs based on requirements
  # Public subnets: extract from individual subnet definitions
  public_subnet_cidrs = [for i in range(local.public_subnet_count) : module.subnets.network_cidr_blocks["public-${i}"]]

  # Private subnets: extract from individual subnet definitions
  private_subnet_cidrs = [for i in range(local.private_subnet_count) : module.subnets.network_cidr_blocks["private-${i}"]]

  # Database subnets: extract from individual subnet definitions
  database_subnet_cidrs = [for i in range(local.database_subnet_count) : module.subnets.network_cidr_blocks["database-${i}"]]

  # Non-routable subnets: extract from all non-routable CIDRs
  nonroutable_subnet_cidrs = local.effective_config.nonroutable_subnets_enabled ? (
    slice(local.all_nonroutable_cidrs, 0, local.nonroutable_subnet_count)
  ) : []

  # IPv6 subnet CIDRs - calculate /64 subnets from VPC /56
  # AWS assigns /56 to VPC, we create /64 subnets (8 additional bits)
  public_subnet_ipv6_cidrs = var.ipv6_enabled ? [
    for i in range(local.public_subnet_count) :
    cidrsubnet(local.ipv6_cidr_block, 8, i)
  ] : []

  private_subnet_ipv6_cidrs = var.ipv6_enabled ? [
    for i in range(local.private_subnet_count) :
    cidrsubnet(local.ipv6_cidr_block, 8, i + local.public_subnet_count)
  ] : []

  database_subnet_ipv6_cidrs = var.ipv6_enabled ? [
    for i in range(local.database_subnet_count) :
    cidrsubnet(local.ipv6_cidr_block, 8, i + local.public_subnet_count + local.private_subnet_count)
  ] : []

  nonroutable_subnet_ipv6_cidrs = var.ipv6_enabled && local.effective_config.nonroutable_subnets_enabled ? [
    for i in range(local.nonroutable_subnet_count) :
    cidrsubnet(local.ipv6_cidr_block, 8, i + local.public_subnet_count + local.private_subnet_count + local.database_subnet_count)
  ] : []

  ################################################################################
  # END: CORE ALGORITHM
  ################################################################################


}
