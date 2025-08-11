name_prefix = "complete-example"

cidr_primary = "10.28.0.0/20"

environment_type = "Production"

allowed_availability_zone_ids = ["us-east-1c", "us-east-1d", "us-east-1f"]

create_database_route_table = true

cost_estimation_config = {
  enabled                   = true
  data_transfer_mb_per_hour = 10
}

gateway_endpoints = ["s3", "dynamodb"]

interface_endpoints = ["kms", "ec2", "ec2messages", "ssmmessages", "ssm", "logs"]

tags = {
  Environment = "production"
  Project     = "complete-vpc-example"
  Owner       = "devops-team"
}
