resource "aws_organizations_policy" "deny_root_actions" {
  name        = "DenyRootActions"
  description = "Deny all actions by the root user"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DenyRootActions"
      Effect   = "Deny"
      Action   = "*"
      Resource = "*"
      Condition = {
        StringLike = {
          "aws:PrincipalArn" = ["arn:aws:iam::*:root"]
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "deny_leave_org" {
  name        = "DenyLeaveOrganization"
  description = "Prevent accounts from leaving the organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DenyLeaveOrg"
      Effect   = "Deny"
      Action   = ["organizations:LeaveOrganization"]
      Resource = "*"
    }]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "deny_regions" {
  name        = "DenyNonApprovedRegions"
  description = "Deny all actions outside approved regions (except global services)"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyNonApprovedRegions"
      Effect = "Deny"
      NotAction = [
        "a4b:*", "acm:*", "aws-marketplace-management:*", "aws-marketplace:*",
        "aws-portal:*", "budgets:*", "ce:*", "chime:*", "cloudfront:*",
        "config:*", "cur:*", "directconnect:*", "ec2:DescribeRegions",
        "ec2:DescribeTransitGateways", "ecr-public:*", "globalaccelerator:*",
        "health:*", "iam:*", "importexport:*", "kms:*", "mobileanalytics:*",
        "networkmanager:*", "organizations:*", "pricing:*", "route53:*",
        "route53domains:*", "s3:GetAccountPublic*", "s3:ListAllMyBuckets",
        "s3:PutAccountPublic*", "shield:*", "sts:*", "support:*",
        "trustedadvisor:*", "waf-regional:*", "waf:*", "wafv2:*",
        "wellarchitected:*"
      ]
      Resource = "*"
      Condition = {
        StringNotEquals = {
          "aws:RequestedRegion" = var.allowed_regions
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "require_imdsv2" {
  name        = "RequireIMDSv2"
  description = "Deny EC2 RunInstances if IMDSv2 is not required"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "RequireIMDSv2"
      Effect   = "Deny"
      Action   = ["ec2:RunInstances"]
      Resource = "arn:aws:ec2:*:*:instance/*"
      Condition = {
        StringNotEquals = {
          "ec2:MetadataHttpTokens" = "required"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "deny_s3_public" {
  name        = "DenyS3PublicAccess"
  description = "Deny disabling S3 Block Public Access at account or bucket level"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyS3PublicAccess"
      Effect = "Deny"
      Action = [
        "s3:PutBucketPublicAccessBlock",
        "s3:PutAccountPublicAccessBlock"
      ]
      Resource = "*"
      Condition = {
        StringEquals = {
          "s3:PublicAccessBlockConfiguration/BlockPublicAcls"       = "false"
          "s3:PublicAccessBlockConfiguration/BlockPublicPolicy"     = "false"
          "s3:PublicAccessBlockConfiguration/IgnorePublicAcls"      = "false"
          "s3:PublicAccessBlockConfiguration/RestrictPublicBuckets" = "false"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "deny_iam_user_creation" {
  name        = "DenyIAMUserCreation"
  description = "Deny creation of IAM users - force use of Identity Center"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DenyIAMUserCreation"
      Effect   = "Deny"
      Action   = ["iam:CreateUser", "iam:CreateAccessKey"]
      Resource = "*"
    }]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "deny_unencrypted_storage" {
  name        = "DenyUnencryptedStorage"
  description = "Deny creation of unencrypted EBS volumes and RDS instances"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyUnencryptedEBS"
        Effect   = "Deny"
        Action   = ["ec2:CreateVolume"]
        Resource = "*"
        Condition = {
          Bool = { "ec2:Encrypted" = "false" }
        }
      },
      {
        Sid      = "DenyUnencryptedRDS"
        Effect   = "Deny"
        Action   = ["rds:CreateDBInstance"]
        Resource = "*"
        Condition = {
          Bool = { "rds:StorageEncrypted" = "false" }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "deny_vpc_changes" {
  name        = "DenyVPCChanges"
  description = "Deny modification of VPC infrastructure in workload accounts"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyVPCChanges"
      Effect = "Deny"
      Action = [
        "ec2:CreateVpc", "ec2:DeleteVpc",
        "ec2:CreateInternetGateway", "ec2:DeleteInternetGateway",
        "ec2:AttachInternetGateway", "ec2:DetachInternetGateway",
        "ec2:CreateSubnet", "ec2:DeleteSubnet",
        "ec2:ModifyVpcAttribute"
      ]
      Resource = "*"
    }]
  })

  tags = var.tags
}
