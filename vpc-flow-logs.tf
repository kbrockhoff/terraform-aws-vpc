# ----
# VPC Flow Logs
# ----

locals {
  create_vpc_flow_logs_kms_key = local.create_resources && local.effective_config.vpc_flow_logs_enabled && local.effective_config.create_vpc_flow_logs_kms_key
  # Use supplied KMS key or created key for VPC Flow Logs
  vpc_flow_logs_kms_key_id = var.vpc_flow_logs_kms_key_id != null ? var.vpc_flow_logs_kms_key_id : (
    local.create_vpc_flow_logs_kms_key ? aws_kms_key.flow_logs[0].arn : null
  )
}

# KMS Key for CloudWatch Log Group encryption
resource "aws_kms_key" "flow_logs" {
  count = local.create_vpc_flow_logs_kms_key ? 1 : 0

  description             = "KMS key for ${var.name_prefix} VPC Flow Logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${local.partition}:iam::${local.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${local.region}.${local.dns_suffix}"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:${local.partition}:logs:${local.region}:${local.account_id}:log-group:/aws/vpc/flowlogs/${var.name_prefix}"
          }
        }
      }
    ]
  })

  tags = merge(
    local.common_data_tags,
    {
      Name = "${var.name_prefix}-vpc-flow-logs-key"
    }
  )
}

resource "aws_kms_alias" "flow_logs" {
  count = local.create_resources && local.effective_config.vpc_flow_logs_enabled && local.effective_config.create_vpc_flow_logs_kms_key ? 1 : 0

  name          = "alias/${var.name_prefix}-vpc-flow-logs"
  target_key_id = aws_kms_key.flow_logs[0].key_id
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = local.create_resources && local.effective_config.vpc_flow_logs_enabled ? 1 : 0

  name              = "/aws/vpc/flowlogs/${var.name_prefix}"
  retention_in_days = local.effective_config.vpc_flow_logs_retention_days
  kms_key_id        = local.vpc_flow_logs_kms_key_id

  tags = merge(
    local.common_data_tags,
    {
      Name = "${var.name_prefix}-vpc-flow-logs"
    }
  )

  depends_on = [aws_kms_key.flow_logs]
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "flow_logs" {
  count = local.create_resources && local.effective_config.vpc_flow_logs_enabled ? 1 : 0

  name = "${var.name_prefix}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.${local.dns_suffix}"
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-vpc-flow-logs-role"
    }
  )
}

# IAM Policy for VPC Flow Logs
resource "aws_iam_role_policy" "flow_logs" {
  count = local.create_resources && local.effective_config.vpc_flow_logs_enabled ? 1 : 0

  name = "${var.name_prefix}-vpc-flow-logs-policy"
  role = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:${local.partition}:logs:${local.region}:${local.account_id}:*"
      }
      ], local.vpc_flow_logs_kms_key_id != null ? [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = local.vpc_flow_logs_kms_key_id
      }
    ] : [])
  })
}

# VPC Flow Log
resource "aws_flow_log" "vpc" {
  count = local.create_resources && local.effective_config.vpc_flow_logs_enabled ? 1 : 0

  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  traffic_type    = var.vpc_flow_logs_traffic_type
  vpc_id          = aws_vpc.main[0].id

  log_format = var.vpc_flow_logs_custom_format != null ? var.vpc_flow_logs_custom_format : "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-vpc-flow-log"
    }
  )

  depends_on = [
    aws_iam_role_policy.flow_logs,
    aws_cloudwatch_log_group.vpc_flow_logs
  ]
}