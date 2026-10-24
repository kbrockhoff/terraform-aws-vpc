data "aws_availability_zones" "available" {
  # Callers pin zones with allowed_availability_zone_ids; an identity filter here would hardcode region-specific zones
  #checkov:skip=CKV_AWS_394:Zone selection is pinned by var.allowed_availability_zone_ids, not by this data source
  state = "available"
}

# AWS account, partition, and region data sources
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
