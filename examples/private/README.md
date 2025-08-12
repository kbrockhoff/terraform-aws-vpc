# Private VPC Example

This example demonstrates creating a completely private VPC with no internet access. It's designed for workloads that require strict network isolation and communication only through AWS services via VPC endpoints.

## Key Features

- **No Public Subnets**: Only private and database subnets are created
- **No Internet Gateway**: Internet gateway is disabled (`igw_enabled = false`)
- **No NAT Gateway**: NAT gateway is disabled (`nat_gateway_enabled = false`)
- **Block Public Access**: VPC block public access is enabled to prevent accidental public subnet creation
- **VPC Flow Logs**: Enabled for monitoring network traffic
- **Gateway Endpoints**: S3 and DynamoDB endpoints for AWS service access without internet
- **Interface Endpoints**: EC2, SSM, and CloudWatch Logs endpoints for AWS service management

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Private VPC (10.30.0.0/20)                                 │
│                                                             │
│ ┌─────────────────────┐    ┌─────────────────────────────┐ │
│ │ Private Subnets     │    │ Database Subnets            │ │
│ │ (worker tier)       │    │ (data tier)                 │ │
│ │ - 10.30.0.0/24      │    │ - 10.30.8.0/24              │ │
│ │ - 10.30.1.0/24      │    │ - 10.30.9.0/24              │ │
│ │ - 10.30.2.0/24      │    │ - 10.30.10.0/24             │ │
│ └─────────────────────┘    └─────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ VPC Endpoints                                           │ │
│ │ - S3 (Gateway)                                          │ │
│ │ - DynamoDB (Gateway)                                    │ │
│ │ - EC2, SSM, Logs (Interface)                            │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Use Cases

- Highly secure environments requiring air-gapped networking
- Compliance workloads with strict network isolation requirements
- Database workloads that should never have internet access
- Development environments for testing private-only architectures

## Configuration

The example uses these key configuration options:

```hcl
igw_enabled                 = false  # No internet gateway
nat_gateway_enabled         = false  # No NAT gateway
block_public_access_enabled = true   # Prevent public subnets
vpc_flow_logs_enabled       = true   # Monitor traffic
```

## Usage

1. Customize `terraform.auto.tfvars` with your values
2. Run `terraform init`
3. Run `terraform plan` to review the configuration
4. Run `terraform apply` to create the VPC

## Accessing Resources

Since this VPC has no internet access, you'll need to:

- Use AWS Systems Manager Session Manager to connect to EC2 instances
- Access AWS services through the configured VPC endpoints
- Use AWS PrivateLink for third-party service integrations
- Consider AWS Transit Gateway for connectivity to other VPCs

## Security Considerations

- All network traffic stays within AWS backbone
- No accidental internet exposure possible
- VPC Flow Logs provide complete network visibility
- Security groups restrict traffic to necessary services only