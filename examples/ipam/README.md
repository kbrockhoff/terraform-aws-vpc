# VPC with AWS IPAM Example

This example demonstrates how to create a VPC using AWS IP Address Manager (IPAM) instead of providing static CIDR blocks. IPAM automatically allocates IP address ranges from a managed pool, providing better IP address management and avoiding conflicts in large organizations.

## Features Demonstrated

- **IPAM Integration**: Uses AWS IPAM pool for automatic IPv4 CIDR allocation
- **Optional IPv6 IPAM**: Support for IPv6 CIDR allocation through IPAM
- **Automatic Subnet Creation**: Creates optimally-sized subnets from IPAM-allocated CIDR
- **Complete VPC Setup**: Includes NAT gateways, route tables, and VPC endpoints
- **Cost Estimation**: Provides estimated monthly costs for the infrastructure

## Prerequisites

Before using this example, you must have:

1. **AWS IPAM Setup**: An AWS IPAM instance configured in your organization
2. **IPAM Pool**: An IPAM pool with available IPv4 address space
3. **Pool ID**: The IPAM pool ID to use for CIDR allocation
4. **Permissions**: IAM permissions to allocate CIDRs from the IPAM pool

## IPAM Pool Requirements

Your IPAM pool should have:
- Sufficient available address space for the requested netmask length
- Proper allocation rules configured
- Access permissions for your AWS account/role

## Configuration

### Required Variables

Update the following variables in `terraform.auto.tfvars`:

```hcl
# Replace with your actual IPAM pool ID
ipv4_ipam_pool_id = "ipam-pool-xxxxxxxxxxxxxxxxx"

# Adjust netmask length based on your needs
ipv4_netmask_length = 20  # Results in /20 network (4096 addresses)
```

### IPv6 Configuration with IPAM

This example now enables IPv6 with IPAM by default. The configuration includes:

```hcl
ipv6_enabled           = true
ipv6_ipam_pool_enabled = true
ipv6_ipam_pool_id      = "ipam-pool-xxxxxxxxxxxxxxxxx"  # Replace with your IPv6 IPAM pool ID
ipv6_netmask_length    = 56
```

To find your IPv6 IPAM pool ID:
1. Go to the AWS VPC Console
2. Navigate to **IPAM** → **Pools**
3. Find your IPv6 pool and copy the Pool ID
4. Update the `ipv6_ipam_pool_id` value in `terraform.auto.tfvars`

## Finding Your IPAM Pool ID

1. Go to the AWS VPC Console
2. Navigate to **IPAM** → **Pools**
3. Find your IPv4 pool and copy the Pool ID
4. The ID format is: `ipam-pool-xxxxxxxxxxxxxxxxx`

## Usage

1. **Update Configuration**: Edit `terraform.auto.tfvars` with your IPAM pool ID
2. **Initialize**: Run `terraform init`
3. **Plan**: Run `terraform plan` to review the resources
4. **Apply**: Run `terraform apply` to create the infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## Key Differences from Static CIDR

| Aspect | Static CIDR | IPAM |
|--------|-------------|------|
| **CIDR Definition** | Manual specification | Automatic allocation |
| **Conflict Prevention** | Manual coordination | Automatic management |
| **IP Space Utilization** | Fixed allocation | Efficient allocation |
| **Scalability** | Manual planning | Automated scaling |
| **Compliance** | Manual tracking | Automatic tracking |

## Subnet Allocation

With IPAM, the module automatically:
1. Receives a CIDR block from the IPAM pool
2. Calculates optimal subnet sizes
3. Creates subnets in multiple AZs
4. Ensures efficient IP space utilization

Example allocation for `/20` network:
- **Public subnets**: 2 × `/28` (16 IPs each)
- **Private subnets**: 2 × `/26` (64 IPs each) 
- **Database subnets**: 2 × `/28` (16 IPs each)
- **Non-routable subnets**: From `100.64.0.0/16` range

## Outputs

Key outputs include:

- `vpc_cidr_block`: The CIDR block allocated by IPAM
- `ipam_pool_id`: The IPAM pool ID used
- `vpc_id`: The created VPC ID
- `estimated_monthly_cost_usd`: Estimated infrastructure costs

## Cost Considerations

This example includes cost estimation for:
- NAT Gateway usage
- VPC Flow Logs storage
- VPC Endpoint usage
- Data transfer costs

Adjust the `cost_estimation_config` in `terraform.auto.tfvars` to match your expected usage patterns.

## Best Practices

1. **Pool Selection**: Choose IPAM pools with adequate address space
2. **Netmask Sizing**: Select appropriate netmask length for your needs
3. **Monitoring**: Monitor IPAM pool utilization
4. **Tagging**: Use consistent tagging for IPAM tracking
5. **Documentation**: Document IPAM pool assignments

## Troubleshooting

### Common Issues

**IPAM Pool Not Found**
- Verify the pool ID is correct
- Ensure you have access to the IPAM pool
- Check the pool is in the correct AWS region

**Insufficient Address Space**
- Verify available space in the IPAM pool
- Consider using a smaller netmask length
- Check for conflicting allocations

**Permission Errors**
- Ensure IAM permissions for IPAM operations
- Verify cross-account access if using shared pools
- Check resource-based policies on IPAM pools

For more information, see the [AWS IPAM documentation](https://docs.aws.amazon.com/vpc/latest/ipam/).