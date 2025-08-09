# GitHub Actions OIDC Provider
data "aws_iam_openid_connect_provider" "github_actions" {
  count = var.enabled ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  count = var.enabled ? 1 : 0
  name  = "${var.name_prefix}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github_actions[0].arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:environment:${var.environment}"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-github-actions"
  })
}

# IAM Policy for EC2 Discovery and Describe operations
resource "aws_iam_policy" "ec2_describe" {
  count       = var.enabled ? 1 : 0
  name        = "${var.name_prefix}-ec2-describe-policy"
  description = "Policy for EC2 discovery and describe operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeRegions",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeAddresses",
          "ec2:DescribeAddressesAttribute",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcClassicLink",
          "ec2:DescribeVpcClassicLinkDnsSupport",
          "ec2:DescribeVpcEndpointServices",
          "ec2:DescribeVpcEndpointConnections",
          "ec2:DescribeVpcEndpointConnectionNotifications",
          "ec2:DescribeVpcEndpointServiceConfigurations",
          "ec2:DescribeVpcEndpointServicePermissions",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeCustomerGateways",
          "ec2:DescribeVpnGateways",
          "ec2:DescribeVpnConnections",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeSecurityGroupReferences",
          "ec2:DescribeStaleSecurityGroups",
          "ec2:DescribeManagedPrefixLists",
          "ec2:GetManagedPrefixListEntries",
          "ec2:DescribeCarrierGateways",
          "ec2:DescribeLocalGatewayRouteTableVpcAssociations",
          "ec2:DescribeLocalGatewayRouteTables",
          "ec2:DescribeLocalGateways",
          "ec2:DescribeLocalGatewayVirtualInterfaces",
          "ec2:DescribeLocalGatewayVirtualInterfaceGroups",
          "ec2:DescribeLocalGatewayRouteTableVirtualInterfaceGroupAssociations",
          "ec2:DescribeTransitGatewayAttachments",
          "ec2:DescribeTransitGatewayVpcAttachments",
          "ec2:DescribeTransitGateways",
          "ec2:DescribeTransitGatewayRouteTables",
          "ec2:DescribeClientVpnEndpoints",
          "ec2:DescribeClientVpnTargetNetworks",
          "ec2:DescribeClientVpnAuthorizationRules",
          "ec2:DescribeClientVpnRoutes",
          "ec2:DescribeClientVpnConnections",
          "ec2:DescribeNetworkInsightsAnalyses",
          "ec2:DescribeNetworkInsightsPaths",
          "ec2:DescribeNetworkInsightsAccessScopes",
          "ec2:DescribeNetworkInsightsAccessScopeAnalyses",
          "ec2:DescribePublicIpv4Pools",
          "ec2:DescribeCoipPools",
          "ec2:DescribeByoipCidrs",
          "ec2:DescribeIpv6Pools",
          "ec2:DescribeIpamPools",
          "ec2:DescribeIpamScopes",
          "ec2:DescribeIpams",
          "ec2:GetIpamPoolAllocations",
          "ec2:GetIpamPoolCidrs",
          "ec2:GetIpamResourceCidrs",
          "ec2:SearchLocalGatewayRoutes",
          "ec2:SearchTransitGatewayRoutes",
          "ec2:DescribePrefixLists",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSecurityGroupRules",
          "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "ec2:DescribeEgressOnlyInternetGateways",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeFlowLogs"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ec2-describe-policy"
  })
}

# IAM Policy for EC2 VPC Core Management
resource "aws_iam_policy" "vpc_core" {
  count       = var.enabled ? 1 : 0
  name        = "${var.name_prefix}-vpc-core-policy"
  description = "Policy for managing VPC core resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:ModifyVpcAttribute",
          "ec2:AssociateVpcCidrBlock",
          "ec2:DisassociateVpcCidrBlock",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:ModifySubnetAttribute"
        ]
        Resource = [
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:vpc/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:subnet/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress"
        ]
        Resource = [
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:vpc/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:security-group/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:security-group-rule/*"
        ]
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-core-policy"
  })
}

# IAM Policy for EC2 Networking (Gateways, Routes, etc.)
resource "aws_iam_policy" "vpc_networking" {
  count       = var.enabled ? 1 : 0
  name        = "${var.name_prefix}-vpc-networking-policy"
  description = "Policy for managing VPC networking resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable"
        ]
        Resource = [
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:vpc/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:route-table/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:subnet/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:internet-gateway/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:natgateway/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:egress-only-internet-gateway/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:CreateNatGateway",
          "ec2:DeleteNatGateway",
          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",
          "ec2:DisassociateAddress"
        ]
        Resource = [
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:vpc/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:internet-gateway/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:subnet/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:natgateway/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:elastic-ip/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateEgressOnlyInternetGateway",
          "ec2:DeleteEgressOnlyInternetGateway"
        ]
        Resource = [
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:vpc/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:egress-only-internet-gateway/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkAclEntry",
          "ec2:DeleteNetworkAclEntry",
          "ec2:ReplaceNetworkAclEntry"
        ]
        Resource = [
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:vpc/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:network-acl/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateVpcEndpoint",
          "ec2:DeleteVpcEndpoints"
        ]
        Resource = [
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:vpc/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:vpc-endpoint/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:route-table/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:subnet/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateFlowLogs",
          "ec2:DeleteFlowLogs"
        ]
        Resource = [
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:vpc/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:subnet/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:network-interface/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:vpc-flow-log/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTransitGatewayVpcAttachment",
          "ec2:DeleteTransitGatewayVpcAttachment",
          "ec2:ModifyTransitGatewayVpcAttachment",
          "ec2:AcceptTransitGatewayVpcAttachment",
          "ec2:RejectTransitGatewayVpcAttachment"
        ]
        Resource = [
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:vpc/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:subnet/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:transit-gateway/*",
          "arn:${var.partition}:ec2:${var.region}:${var.account_id}:transit-gateway-attachment/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "ec2:CreateAction" = [
              "CreateVpc",
              "CreateSubnet",
              "CreateSecurityGroup",
              "CreateRouteTable",
              "CreateInternetGateway",
              "CreateNatGateway",
              "CreateEgressOnlyInternetGateway",
              "CreateVpcEndpoint",
              "CreateFlowLogs",
              "CreateTransitGatewayVpcAttachment",
              "AllocateAddress"
            ]
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-networking-policy"
  })
}

# IAM Policy for AWS Services (RDS, ElastiCache, etc.)
resource "aws_iam_policy" "aws_services" {
  count       = var.enabled ? 1 : 0
  name        = "${var.name_prefix}-aws-services-policy"
  description = "Policy for managing AWS services related to VPC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticache:CreateCacheSubnetGroup",
          "elasticache:DeleteCacheSubnetGroup",
          "elasticache:ListTagsForResource",
          "elasticache:DescribeCacheSubnetGroups"
        ]
        Resource = [
          "arn:${var.partition}:elasticache:${var.region}:${var.account_id}:subnetgroup:${var.name_prefix}-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBSubnetGroups",
          "rds:DeleteDBSubnetGroup",
          "rds:CreateDBSubnetGroup",
          "rds:ListTagsForResource",
          "rds:AddTagsToResource",
          "rds:RemoveTagsFromResource"
        ]
        Resource = [
          "arn:${var.partition}:rds:${var.region}:${var.account_id}:subgrp:${var.name_prefix}-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutRetentionPolicy",
          "logs:DeleteLogGroup",
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
          "logs:ListTagsForResource",
          "logs:TagResource",
          "logs:UntagResource",
          "logs:TagLogGroup",
          "logs:UntagLogGroup"
        ]
        Resource = [
          "arn:${var.partition}:logs:${var.region}:${var.account_id}:log-group:${var.name_prefix}-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "elasticache:CreateCacheSubnetGroup",
          "elasticache:DeleteCacheSubnetGroup",
          "elasticache:ListTagsForResource",
          "elasticache:DescribeCacheSubnetGroups"
        ]
        Resource = [
          "arn:${var.partition}:elasticache:${var.region}:${var.account_id}:subnetgroup:${var.name_prefix}-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "freetier:GetAccountPlanState",
          "pricing:GetAttributeValues",
          "pricing:GetProducts",
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-aws-services-policy"
  })
}

# IAM Policy for IAM and KMS Management
resource "aws_iam_policy" "iam_kms" {
  count       = var.enabled ? 1 : 0
  name        = "${var.name_prefix}-iam-kms-policy"
  description = "Policy for managing IAM and KMS resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:GetAccountSummary",
          "iam:ListAccountAliases",
          "iam:ListAccessKeys"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:ListAttachedRolePolicies",
          "iam:DeleteRolePolicy",
          "iam:GetRole",
          "iam:PutRolePolicy",
          "iam:GetRolePolicy",
          "iam:ListInstanceProfilesForRole"
        ]
        Resource = [
          "arn:${var.partition}:iam::${var.account_id}:role/${var.name_prefix}-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:ListAliases",
          "kms:ListKeys"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:EnableKeyRotation",
          "kms:DescribeKey",
          "kms:ListResourceTags",
          "kms:ScheduleKeyDeletion",
          "kms:Decrypt",
          "kms:CreateKey",
          "kms:GetKeyRotationStatus",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:GetKeyPolicy",
          "kms:PutKeyPolicy",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:DisableKey",
          "kms:EnableKey",
          "kms:CancelKeyDeletion",
          "kms:DisableKeyRotation",
          "kms:ListGrants",
          "kms:CreateGrant",
          "kms:RevokeGrant",
          "kms:RetireGrant"
        ]
        Resource = [
          "arn:${var.partition}:kms:${var.region}:${var.account_id}:key/*"
        ]
        Condition = {
          StringLike = {
            "kms:ViaService" = [
              "ec2.${var.region}.amazonaws.com",
              "logs.${var.region}.amazonaws.com"
            ]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "kms:CreateAlias",
          "kms:DeleteAlias"
        ]
        Resource = [
          "arn:${var.partition}:kms:${var.region}:${var.account_id}:alias/${var.name_prefix}-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutRetentionPolicy",
          "logs:DeleteLogGroup",
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
          "logs:ListTagsForResource",
          "logs:TagResource",
          "logs:UntagResource",
          "logs:TagLogGroup",
          "logs:UntagLogGroup"
        ]
        Resource = [
          "arn:${var.partition}:logs:${var.region}:${var.account_id}:log-group:${var.name_prefix}-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBSubnetGroups",
          "rds:DeleteDBSubnetGroup",
          "rds:CreateDBSubnetGroup",
          "rds:ListTagsForResource",
          "rds:AddTagsToResource",
          "rds:RemoveTagsFromResource"
        ]
        Resource = [
          "arn:${var.partition}:rds:${var.region}:${var.account_id}:subgrp:${var.name_prefix}-*"
        ]
      },
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-management-policy"
  })
}

# Attach policies to role
resource "aws_iam_role_policy_attachment" "ec2_describe" {
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.github_actions[0].name
  policy_arn = aws_iam_policy.ec2_describe[0].arn
}

resource "aws_iam_role_policy_attachment" "vpc_core" {
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.github_actions[0].name
  policy_arn = aws_iam_policy.vpc_core[0].arn
}

resource "aws_iam_role_policy_attachment" "vpc_networking" {
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.github_actions[0].name
  policy_arn = aws_iam_policy.vpc_networking[0].arn
}

resource "aws_iam_role_policy_attachment" "aws_services" {
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.github_actions[0].name
  policy_arn = aws_iam_policy.aws_services[0].arn
}

resource "aws_iam_role_policy_attachment" "iam_kms" {
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.github_actions[0].name
  policy_arn = aws_iam_policy.iam_kms[0].arn
}