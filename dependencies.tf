data "aws_availability_zones" "available" {
  state = "available"
}

# AWS account, partition, and region data sources
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

# AWS region information for pricing
data "aws_regions" "current" {
  filter {
    name   = "region-name"
    values = [data.aws_region.current.id]
  }
}
