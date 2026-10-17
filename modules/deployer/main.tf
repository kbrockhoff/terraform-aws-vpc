# ----
# Least privilege permissions to provision and deprovision the parent VPC module's resources.
# Terraform state backend access is granted by terraform-aws-cicdrole, not here.
# ----

# ----
# Supporting services (STS, pricing, KMS, CloudWatch Logs, IAM, RDS, ElastiCache, Route 53)
# plus EC2 read-only, account-level and transit gateway permissions
# ----

data "aws_iam_policy_document" "main" {
  count = var.enabled ? 1 : 0

  # Caller identity lookups used by the parent module's data sources
  statement {
    sid    = "CallerIdentity"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }

  # Pricing API access (modules/cost-estimation)
  statement {
    sid    = "PricingRead"
    effect = "Allow"
    actions = [
      "freetier:GetAccountPlanState",
      "pricing:GetAttributeValues",
      "pricing:GetProducts",
    ]
    resources = ["*"]
  }

  # Flow logs CMK creation; the key does not exist yet, so restrict by its Name tag
  statement {
    sid    = "KmsCreateKey"
    effect = "Allow"
    actions = [
      "kms:CreateKey",
    ]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/Name"
      values   = [local.name_tag_pattern]
    }
  }

  # KMS actions which do not support resource-level permissions
  statement {
    sid    = "KmsGlobal"
    effect = "Allow"
    actions = [
      "kms:ListAliases",
    ]
    resources = ["*"]
  }

  # Read and create-time calls; tags may not be visible to authorization right after CreateKey
  statement {
    sid    = "KmsKeyManagement"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:EnableKeyRotation",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListResourceTags",
      "kms:TagResource",
    ]
    resources = [
      "arn:${var.partition}:kms:${var.region}:${var.account_id}:key/*",
    ]
  }

  # Policy changes and deletion only on keys created by the parent module
  statement {
    sid    = "KmsKeyModifyTagged"
    effect = "Allow"
    actions = [
      "kms:PutKeyPolicy",
      "kms:ScheduleKeyDeletion",
      "kms:UntagResource",
      "kms:UpdateKeyDescription",
    ]
    resources = [
      "arn:${var.partition}:kms:${var.region}:${var.account_id}:key/*",
    ]

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/Name"
      values   = [local.name_tag_pattern]
    }
  }

  # Alias management requires permission on both the alias and the target key
  statement {
    sid    = "KmsAliasManagement"
    effect = "Allow"
    actions = [
      "kms:CreateAlias",
      "kms:DeleteAlias",
      "kms:UpdateAlias",
    ]
    resources = [
      "arn:${var.partition}:kms:${var.region}:${var.account_id}:alias/${var.name_prefix}-vpc-flow-logs",
      "arn:${var.partition}:kms:${var.region}:${var.account_id}:key/*",
    ]
  }

  # DescribeLogGroups is authorized against the account-wide log group ARN
  statement {
    sid    = "LogsDescribe"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
    ]
    resources = [
      "arn:${var.partition}:logs:${var.region}:${var.account_id}:log-group:*",
    ]
  }

  statement {
    sid    = "LogsFlowLogGroup"
    effect = "Allow"
    actions = [
      "logs:AssociateKmsKey",
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DeleteRetentionPolicy",
      "logs:DisassociateKmsKey",
      "logs:ListTagsForResource",
      "logs:PutRetentionPolicy",
      "logs:TagResource",
      "logs:UntagResource",
    ]
    resources = [
      local.flow_logs_log_group,
      "${local.flow_logs_log_group}:*",
    ]
  }

  # Flow logs delivery role and its inline policy
  statement {
    sid    = "IamFlowLogsRole"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:ListRoleTags",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
    ]
    resources = [
      local.flow_logs_role,
    ]
  }

  # aws_flow_log hands the delivery role to the VPC Flow Logs service
  statement {
    sid    = "IamPassFlowLogsRole"
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      local.flow_logs_role,
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["vpc-flow-logs.amazonaws.com"]
    }
  }

  statement {
    sid    = "RdsSubnetGroup"
    effect = "Allow"
    actions = [
      "rds:AddTagsToResource",
      "rds:CreateDBSubnetGroup",
      "rds:DeleteDBSubnetGroup",
      "rds:DescribeDBSubnetGroups",
      "rds:ListTagsForResource",
      "rds:ModifyDBSubnetGroup",
      "rds:RemoveTagsFromResource",
    ]
    resources = [
      "arn:${var.partition}:rds:${var.region}:${var.account_id}:subgrp:${var.name_prefix}-database",
    ]
  }

  statement {
    sid    = "ElastiCacheSubnetGroup"
    effect = "Allow"
    actions = [
      "elasticache:AddTagsToResource",
      "elasticache:CreateCacheSubnetGroup",
      "elasticache:DeleteCacheSubnetGroup",
      "elasticache:DescribeCacheSubnetGroups",
      "elasticache:ListTagsForResource",
      "elasticache:ModifyCacheSubnetGroup",
      "elasticache:RemoveTagsFromResource",
    ]
    resources = [
      "arn:${var.partition}:elasticache:${var.region}:${var.account_id}:subnetgroup:${var.name_prefix}-cache",
    ]
  }

  # ElastiCache creates its service-linked role on first use in an account
  statement {
    sid    = "ElastiCacheServiceLinkedRole"
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole",
    ]
    resources = [
      "arn:${var.partition}:iam::${var.account_id}:role/aws-service-role/elasticache.amazonaws.com/AWSServiceRoleForElastiCache",
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["elasticache.amazonaws.com"]
    }
  }

  # Interface endpoints with private DNS associate the VPC with a service-managed hosted zone
  statement {
    sid    = "Route53EndpointPrivateDns"
    effect = "Allow"
    actions = [
      "route53:AssociateVPCWithHostedZone",
    ]
    resources = [
      "arn:${var.partition}:route53:::hostedzone/*",
    ]
  }

  # EC2 describe actions without resource-level permissions
  statement {
    sid    = "Ec2Describe"
    effect = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAddressesAttribute",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeEgressOnlyInternetGateways",
      "ec2:DescribeFlowLogs",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNatGateways",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribePrefixLists",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroupRules",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTransitGatewayAttachments",
      "ec2:DescribeTransitGatewayRouteTables",
      "ec2:DescribeTransitGatewayVpcAttachments",
      "ec2:DescribeTransitGateways",
      "ec2:DescribeVpcBlockPublicAccessOptions",
      "ec2:DescribeVpcEndpointServices",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeVpcs",
    ]
    resources = ["*"]
  }

  # Account-level VPC Block Public Access setting (no resource-level permissions)
  statement {
    sid    = "Ec2BlockPublicAccess"
    effect = "Allow"
    actions = [
      "ec2:ModifyVpcBlockPublicAccessOptions",
    ]
    resources = ["*"]
  }

  # The transit gateway is often owned by a network account and shared through RAM
  statement {
    sid    = "Ec2TransitGatewayAttachment"
    effect = "Allow"
    actions = [
      "ec2:CreateTransitGatewayVpcAttachment",
      "ec2:ModifyTransitGatewayVpcAttachment",
    ]
    resources = [
      "${local.ec2_arn}:subnet/*",
      "${local.ec2_arn}:transit-gateway-attachment/*",
      "${local.ec2_arn}:vpc/*",
      "arn:${var.partition}:ec2:${var.region}:*:transit-gateway/*",
    ]
  }

  # Custom route table association/propagation (same-account transit gateway only)
  statement {
    sid    = "Ec2TransitGatewayRouting"
    effect = "Allow"
    actions = [
      "ec2:AssociateTransitGatewayRouteTable",
      "ec2:DisableTransitGatewayRouteTablePropagation",
      "ec2:DisassociateTransitGatewayRouteTable",
      "ec2:EnableTransitGatewayRouteTablePropagation",
      "ec2:GetTransitGatewayRouteTableAssociations",
      "ec2:GetTransitGatewayRouteTablePropagations",
    ]
    resources = [
      "${local.ec2_arn}:transit-gateway-attachment/*",
      "${local.ec2_arn}:transit-gateway-route-table/*",
    ]
  }
}

# ----
# EC2 resources inside the VPC: VPC, IPAM, subnets, gateways, routing, NACL, security groups,
# endpoints, flow logs and tagging. Split from main only because of the policy size limit.
# ----

data "aws_iam_policy_document" "network" {
  count = var.enabled ? 1 : 0

  statement {
    sid    = "Ec2Vpc"
    effect = "Allow"
    actions = [
      "ec2:AssociateVpcCidrBlock",
      "ec2:CreateVpc",
      "ec2:DescribeVpcAttribute",
      "ec2:DisassociateVpcCidrBlock",
      "ec2:ModifyVpcAttribute",
      "ec2:ModifyVpcTenancy",
    ]
    resources = [
      "${local.ec2_arn}:vpc/*",
    ]
  }

  # IPAM pools are often owned by a delegated IPAM account and shared through RAM
  statement {
    sid    = "Ec2IpamPool"
    effect = "Allow"
    actions = [
      "ec2:AssociateVpcCidrBlock",
      "ec2:CreateVpc",
      "ec2:GetIpamPoolAllocations",
    ]
    resources = [
      "arn:${var.partition}:ec2::*:ipam-pool/*",
    ]
  }

  statement {
    sid    = "Ec2Subnet"
    effect = "Allow"
    actions = [
      "ec2:AssociateSubnetCidrBlock",
      "ec2:CreateSubnet",
      "ec2:DisassociateSubnetCidrBlock",
      "ec2:ModifySubnetAttribute",
    ]
    resources = [
      "${local.ec2_arn}:subnet/*",
      "${local.ec2_arn}:vpc/*",
    ]
  }

  # Internet, egress-only and NAT gateways plus NAT Elastic IPs
  statement {
    sid    = "Ec2Gateway"
    effect = "Allow"
    actions = [
      "ec2:AllocateAddress",
      "ec2:AttachInternetGateway",
      "ec2:CreateEgressOnlyInternetGateway",
      "ec2:CreateInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:DetachInternetGateway",
      "ec2:DisassociateAddress",
    ]
    resources = [
      "${local.ec2_arn}:egress-only-internet-gateway/*",
      "${local.ec2_arn}:elastic-ip/*",
      "${local.ec2_arn}:internet-gateway/*",
      "${local.ec2_arn}:natgateway/*",
      "${local.ec2_arn}:subnet/*",
      "${local.ec2_arn}:vpc/*",
    ]
  }

  # Route tables, routes, subnet associations and the adopted default route table
  statement {
    sid    = "Ec2Route"
    effect = "Allow"
    actions = [
      "ec2:AssociateRouteTable",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:DeleteRoute",
      "ec2:DisassociateRouteTable",
      "ec2:ReplaceRoute",
      "ec2:ReplaceRouteTableAssociation",
    ]
    resources = [
      "${local.ec2_arn}:egress-only-internet-gateway/*",
      "${local.ec2_arn}:internet-gateway/*",
      "${local.ec2_arn}:natgateway/*",
      "${local.ec2_arn}:route-table/*",
      "${local.ec2_arn}:subnet/*",
      "${local.ec2_arn}:vpc/*",
    ]
  }

  # Entries on the adopted default network ACL
  statement {
    sid    = "Ec2NetworkAcl"
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkAclEntry",
      "ec2:DeleteNetworkAclEntry",
      "ec2:ReplaceNetworkAclEntry",
    ]
    resources = [
      "${local.ec2_arn}:network-acl/*",
    ]
  }

  # modules/security-group groups and the adopted default security group
  statement {
    sid    = "Ec2SecurityGroup"
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
      "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
    ]
    resources = [
      "${local.ec2_arn}:security-group-rule/*",
      "${local.ec2_arn}:security-group/*",
      "${local.ec2_arn}:vpc/*",
    ]
  }

  # modules/vpc-endpoints gateway and interface endpoints
  statement {
    sid    = "Ec2VpcEndpoint"
    effect = "Allow"
    actions = [
      "ec2:CreateVpcEndpoint",
      "ec2:ModifyVpcEndpoint",
    ]
    resources = [
      "${local.ec2_arn}:route-table/*",
      "${local.ec2_arn}:security-group/*",
      "${local.ec2_arn}:subnet/*",
      "${local.ec2_arn}:vpc-endpoint/*",
      "${local.ec2_arn}:vpc/*",
    ]
  }

  statement {
    sid    = "Ec2FlowLog"
    effect = "Allow"
    actions = [
      "ec2:CreateFlowLogs",
    ]
    resources = [
      "${local.ec2_arn}:vpc-flow-log/*",
      "${local.ec2_arn}:vpc/*",
    ]
  }

  # Deletes and tag updates only on resources carrying the parent module's Name tag
  statement {
    sid    = "Ec2ManageTagged"
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteEgressOnlyInternetGateway",
      "ec2:DeleteFlowLogs",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteNatGateway",
      "ec2:DeleteRouteTable",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSubnet",
      "ec2:DeleteTags",
      "ec2:DeleteTransitGatewayVpcAttachment",
      "ec2:DeleteVpc",
      "ec2:DeleteVpcEndpoints",
      "ec2:ReleaseAddress",
    ]
    resources = local.ec2_tagged_resources

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/Name"
      values   = [local.name_tag_pattern]
    }
  }

  # Tag-on-create for every EC2 resource the parent module creates
  statement {
    sid    = "Ec2TagOnCreate"
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
    ]
    resources = local.ec2_tagged_resources

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values = [
        "AllocateAddress",
        "CreateEgressOnlyInternetGateway",
        "CreateFlowLogs",
        "CreateInternetGateway",
        "CreateNatGateway",
        "CreateRouteTable",
        "CreateSecurityGroup",
        "CreateSubnet",
        "CreateTransitGatewayVpcAttachment",
        "CreateVpc",
        "CreateVpcEndpoint",
      ]
    }
  }

  # First tagging of the adopted default route table, network ACL and security group
  statement {
    sid    = "Ec2TagAdoptDefaults"
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
    ]
    resources = [
      "${local.ec2_arn}:network-acl/*",
      "${local.ec2_arn}:route-table/*",
      "${local.ec2_arn}:security-group/*",
    ]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/Name"
      values   = [local.name_tag_pattern]
    }
  }
}

resource "aws_iam_policy" "this" {
  for_each = local.policy_documents

  name        = "${local.policy_name_prefix}-${each.key}"
  description = "Least privilege permissions for CI/CD to deploy the ${local.module_short_name} module (${each.key})"
  policy      = each.value

  tags = merge(var.tags, {
    Name = "${local.policy_name_prefix}-${each.key}"
  })
}

# Optional attachment, e.g. to the role created by terraform-aws-cicdrole
resource "aws_iam_role_policy_attachment" "this" {
  for_each = local.attach_to_role ? aws_iam_policy.this : {}

  role       = var.iam_role_name
  policy_arn = each.value.arn
}
