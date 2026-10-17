locals {
  # Short name of the parent module (repository name without the "terraform-aws-" prefix),
  # used to make deployer policy names unique per module, e.g. "vpc" or "s3backend"
  module_short_name = "vpc"

  policy_name_prefix = "${var.name_prefix}-${local.module_short_name}-deployer"

  # Static keys so for_each is known at plan time; one entry per policy document.
  # EC2 networking permissions live in their own document because one document
  # would exceed the 6,144 character managed policy size limit.
  policy_documents = var.enabled ? {
    main    = data.aws_iam_policy_document.main[0].json
    network = data.aws_iam_policy_document.network[0].json
  } : {}

  attach_to_role = var.enabled && var.iam_role_name != ""

  # ARN prefix for EC2 resources in the target account and region
  ec2_arn = "arn:${var.partition}:ec2:${var.region}:${var.account_id}"

  # Every EC2 resource the parent module creates gets a Name tag starting with name_prefix
  name_tag_pattern = "${var.name_prefix}-*"

  # EC2 resource types the parent module creates or adopts and tags
  ec2_tagged_resources = [
    "${local.ec2_arn}:egress-only-internet-gateway/*",
    "${local.ec2_arn}:elastic-ip/*",
    "${local.ec2_arn}:internet-gateway/*",
    "${local.ec2_arn}:natgateway/*",
    "${local.ec2_arn}:network-acl/*",
    "${local.ec2_arn}:route-table/*",
    "${local.ec2_arn}:security-group/*",
    "${local.ec2_arn}:subnet/*",
    "${local.ec2_arn}:transit-gateway-attachment/*",
    "${local.ec2_arn}:vpc-endpoint/*",
    "${local.ec2_arn}:vpc-flow-log/*",
    "${local.ec2_arn}:vpc/*",
  ]

  # Fixed names set by the parent module's vpc-flow-logs.tf
  flow_logs_log_group = "arn:${var.partition}:logs:${var.region}:${var.account_id}:log-group:/aws/vpc/flowlogs/${var.name_prefix}"
  flow_logs_role      = "arn:${var.partition}:iam::${var.account_id}:role/${var.name_prefix}-vpc-flow-logs-role"
}
