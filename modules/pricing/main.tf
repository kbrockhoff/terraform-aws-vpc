# ----
# AWS VPC Pricing Calculator using AWS Pricing API
# ----


# NAT Gateway pricing
data "aws_pricing_product" "nat_gateway" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonEC2"

  filters {
    field = "productFamily"
    value = "NAT Gateway"
  }

  filters {
    field = "usagetype"
    value = "NatGateway-Hours"
  }
}

# NAT Gateway data processing pricing
data "aws_pricing_product" "nat_gateway_data" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonEC2"

  filters {
    field = "productFamily"
    value = "NAT Gateway"
  }

  filters {
    field = "usagetype"
    value = "NatGateway-Bytes"
  }
}

# VPC Interface Endpoints pricing
data "aws_pricing_product" "vpc_endpoint" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonVPC"

  filters {
    field = "productFamily"
    value = "VpcEndpoint"
  }

  filters {
    field = "usagetype"
    value = "${local.usagetype_region}-VpcEndpoint-Hours"
  }
}

# VPC Endpoint data processing pricing
data "aws_pricing_product" "vpc_endpoint_data" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonVPC"

  filters {
    field = "productFamily"
    value = "VpcEndpoint"
  }

  filters {
    field = "usagetype"
    value = "${local.usagetype_region}-VpcEndpoint-Bytes"
  }
}

# CloudWatch Logs pricing for VPC Flow Logs
data "aws_pricing_product" "cloudwatch_logs" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonCloudWatch"

  filters {
    field = "productFamily"
    value = "Data Payload"
  }

  filters {
    field = "usagetype"
    value = "${local.usagetype_region}-DataProcessing-Bytes"
  }
}

# CloudWatch Logs storage pricing
data "aws_pricing_product" "cloudwatch_storage" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonCloudWatch"

  filters {
    field = "productFamily"
    value = "Storage Snapshot"
  }

  filters {
    field = "usagetype"
    value = "${local.usagetype_region}-TimedStorage-ByteHrs"
  }
}

# KMS pricing
data "aws_pricing_product" "kms" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AWSKMS"

  filters {
    field = "productFamily"
    value = "Encryption Key"
  }

  filters {
    field = "usagetype"
    value = "${var.region}-KMS-Keys"
  }
}
