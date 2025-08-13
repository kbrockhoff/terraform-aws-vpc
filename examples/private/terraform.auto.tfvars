name_prefix = "private-example"

cidr_primary = "10.30.0.0/20"

environment_type = "None"

gateway_endpoints = ["s3", "dynamodb"]

interface_endpoints = ["ec2", "ssm", "ssmmessages", "ec2messages", "logs", "kms"]

tags = {
  Environment = "dev"
  Project     = "private-vpc-example"
  Type        = "private-only"
}