# AWS VPC Terraform Module Guide for AI Agents

Terraform module which creates VPC resources on AWS. It takes an opinionated approach on dividing up
and configuring subnets. Resources have standardized tags which enable deployment of resources
into the VPC across multiple environments without having to specify VPC, subnet, or security group ids.

## Components

### VPC
- Support both IPv4 and IPv6
- Include non-routable IPv4 CIDR block (100.64.0.0/10) for EKS pods
- Include non-routable IPv6 CIDR block (fd00::/8) for EKS pods
- Tag with `NetworkTags=standard`

### Subnets
- Be economical with the use if IPv4 private addresses
- Support both IPv4 and IPv6
- Provide the following subnet types:
| ID     | AZs | IP Types        | NetworkTags    |
|--------|-----|-----------------|----------------|
| lb     | 2   | private, public | public         |
| wrkr   | 3   | private         | private        |
| db     | 3   | private         | database       |
| cache  | 2   | private         | cache          |
| pod    | 3   | non-routable    | nonroutable    |

### ACLs
- Always manage the default network ACL and configure to allow all traffic.

### Gateways
- Provide reliability flag for single or multi-zone configurations
- Provide the following gateways:
| ID        | Type     | Optional |
|-----------|----------|----------|
| igw       | internet | true     |
| ngw       | nat

### Endpoints
- Provide the following endpoints:
| ID        | Service Name     | Type     | Optional |
|-----------|------------------|-----------|--------- |
| s3        | s3               | Gateway   | true     |
| dynamodb  | dynamodb         | Gateway   | true     |
| <list>    | <aws-id>         | Interface | N/A      |

### Security Groups

Always managed the default security group and configure it to deny all ingress and egress except for HTTPS egress to the VPC.
- Provide the following security groups:
| ID        | NetworkTags    | Ingress       | Egress       |
|-----------|----------------|----------------------|--------------|
| lb        | public         | HTTPS Internet   | HTTPS private, non-routable |
| db        | database       | DB private, non-routable | N/A |
| cache     | cache          | Cache private, non-routable | N/A            |
| vpc       | vpconly        | VPC                  | VPC |
| ep        | endpoint       | HTTPS private, non-routable   | VPC |

### Flow Logs
- Enable flow logs with input variable flag
