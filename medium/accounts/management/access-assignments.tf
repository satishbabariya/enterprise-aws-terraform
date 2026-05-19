################################################################################
# Persona model for enterprise access management.
#
# Personas are SSO groups in Identity Center. Each persona gets a permission set
# (AWS-managed or custom inline-policy) in a specific set of accounts.
#
# Edit `local.account_assignments` to add or remove access. Add human users to
# groups via your IdP (Okta/Azure AD/Google) or directly in Identity Center.
################################################################################

locals {
  # ----- SSO groups (personas) -----
  sso_groups = {
    PlatformAdmins       = "Platform/SRE team - manages org-wide infrastructure"
    AppDevelopersProd    = "Application developers - read-only on prod"
    AppDevelopersNonProd = "Application developers - power user on dev/staging/sandbox"
    SecurityEngineers    = "Security team - full access in security accounts, audit elsewhere"
    Auditors             = "Internal/external auditors - read-only across all accounts"
    FinanceTeam          = "Finance team - billing and cost data only"
    ExternalContractors  = "External contractors - limited write on dev/sandbox only, IP-restricted"
    BreakGlass           = "Emergency admin access - use triggers CloudTrail alert"
  }

  # ----- Custom permission sets (least-privilege personas) -----
  custom_permission_sets = {
    # App developers in prod: read everything, no IAM/Org/network mutations
    WorkloadDeveloperProd = {
      description         = "Read-only app developer access in prod"
      session_duration    = "PT4H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      inline_policy_json = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Sid    = "DenyMutations"
          Effect = "Deny"
          Action = [
            "iam:*", "organizations:*", "sso:*", "sso-directory:*",
            "ec2:*Vpc*", "ec2:*Subnet*", "ec2:*Gateway*", "ec2:*Peering*",
            "kms:ScheduleKeyDeletion", "kms:Disable*",
            "s3:DeleteBucket*", "s3:PutBucketPolicy",
            "guardduty:Disable*", "guardduty:Delete*",
            "config:Delete*", "config:Stop*",
            "cloudtrail:Delete*", "cloudtrail:Stop*",
            "securityhub:Disable*"
          ]
          Resource = "*"
        }]
      })
    }

    # App developers in non-prod: PowerUser + deny IAM/Org changes
    WorkloadDeveloperNonProd = {
      description         = "Power user for dev/staging/sandbox - no IAM or Org"
      session_duration    = "PT8H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]
      inline_policy_json = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Sid    = "DenyPrivilegedMutations"
          Effect = "Deny"
          Action = [
            "iam:CreateUser", "iam:CreateAccessKey", "iam:CreatePolicy",
            "organizations:*", "sso:*", "sso-directory:*",
            "cloudtrail:Delete*", "cloudtrail:Stop*",
            "guardduty:Disable*", "config:Delete*"
          ]
          Resource = "*"
        }]
      })
    }

    # Security incident responder - admin in security accounts, audit elsewhere
    SecurityResponder = {
      description      = "Incident response - full access in security/log accounts, read elsewhere"
      session_duration = "PT4H"
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
      ]
    }

    # Break-glass: full admin but short session, monitored via CloudTrail+EventBridge
    BreakGlassAdmin = {
      description         = "Emergency admin access - assumption alerted via CloudTrail"
      session_duration    = "PT1H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }

    # External contractor: limited write on dev/sandbox, MFA + IP allowlist enforced inline
    ExternalContractor = {
      description         = "External contractor - dev/sandbox only, MFA + IP restricted"
      session_duration    = "PT2H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]
      inline_policy_json = jsonencode({
        Version = "2012-10-17"
        Statement = concat(
          [
            {
              Sid       = "RequireMFA"
              Effect    = "Deny"
              NotAction = ["iam:ChangePassword", "iam:GetUser", "sts:GetSessionToken"]
              Resource  = "*"
              Condition = {
                BoolIfExists = { "aws:MultiFactorAuthPresent" = "false" }
              }
            },
            {
              Sid    = "DenyPrivilegedMutations"
              Effect = "Deny"
              Action = [
                "iam:*", "organizations:*", "sso:*",
                "cloudtrail:*", "guardduty:*", "config:*",
                "securityhub:*", "macie2:*", "kms:ScheduleKeyDeletion"
              ]
              Resource = "*"
            }
          ],
          length(var.external_contractor_allowed_ips) > 0 ? [{
            Sid      = "RestrictByIP"
            Effect   = "Deny"
            Action   = "*"
            Resource = "*"
            Condition = {
              NotIpAddress = { "aws:SourceIp" = var.external_contractor_allowed_ips }
              Bool         = { "aws:ViaAWSService" = "false" }
            }
          }] : []
        )
      })
    }
  }

  # ----- Persona -> account/permission-set assignments -----
  # Format: { account_id, permission_set_name, principal_type, principal_id }
  # principal_id is the group key from local.sso_groups (the module resolves it)
  account_assignments = concat(
    # PlatformAdmins: full admin in every foundation account
    [
      for acct in ["security", "log_archive", "network", "shared_services"] : {
        account_id          = local.effective_account_ids[acct]
        permission_set_name = "AdministratorAccess"
        principal_type      = "GROUP"
        principal_id        = "PlatformAdmins"
      }
    ],
    [{
      account_id          = var.management_account_id
      permission_set_name = "AdministratorAccess"
      principal_type      = "GROUP"
      principal_id        = "PlatformAdmins"
    }],

    # AppDevelopersProd: read-only in prod + staging
    [
      for acct in ["prod", "staging"] : {
        account_id          = local.effective_account_ids[acct]
        permission_set_name = "WorkloadDeveloperProd"
        principal_type      = "GROUP"
        principal_id        = "AppDevelopersProd"
      }
    ],

    # AppDevelopersNonProd: power user in dev + sandbox + staging
    [
      for acct in ["dev", "sandbox", "staging"] : {
        account_id          = local.effective_account_ids[acct]
        permission_set_name = "WorkloadDeveloperNonProd"
        principal_type      = "GROUP"
        principal_id        = "AppDevelopersNonProd"
      }
    ],

    # SecurityEngineers: SecurityResponder in security + log-archive, SecurityAudit everywhere else
    [
      for acct in ["security", "log_archive"] : {
        account_id          = local.effective_account_ids[acct]
        permission_set_name = "SecurityResponder"
        principal_type      = "GROUP"
        principal_id        = "SecurityEngineers"
      }
    ],
    [
      for acct in ["network", "shared_services", "prod", "staging", "dev", "sandbox"] : {
        account_id          = local.effective_account_ids[acct]
        permission_set_name = "SecurityAudit"
        principal_type      = "GROUP"
        principal_id        = "SecurityEngineers"
      }
    ],
    [{
      account_id          = var.management_account_id
      permission_set_name = "SecurityAudit"
      principal_type      = "GROUP"
      principal_id        = "SecurityEngineers"
    }],

    # Auditors: read-only across every account
    [
      for acct in ["security", "log_archive", "network", "shared_services", "prod", "staging", "dev", "sandbox"] : {
        account_id          = local.effective_account_ids[acct]
        permission_set_name = "ReadOnlyAccess"
        principal_type      = "GROUP"
        principal_id        = "Auditors"
      }
    ],
    [{
      account_id          = var.management_account_id
      permission_set_name = "ReadOnlyAccess"
      principal_type      = "GROUP"
      principal_id        = "Auditors"
    }],

    # FinanceTeam: billing read-only in management only
    [{
      account_id          = var.management_account_id
      permission_set_name = "BillingReadOnly"
      principal_type      = "GROUP"
      principal_id        = "FinanceTeam"
    }],

    # ExternalContractors: ExternalContractor permission set in dev + sandbox only
    [
      for acct in ["dev", "sandbox"] : {
        account_id          = local.effective_account_ids[acct]
        permission_set_name = "ExternalContractor"
        principal_type      = "GROUP"
        principal_id        = "ExternalContractors"
      }
    ],

    # BreakGlass: short-session admin in every account
    [
      for acct in ["security", "log_archive", "network", "shared_services", "prod", "staging", "dev", "sandbox"] : {
        account_id          = local.effective_account_ids[acct]
        permission_set_name = "BreakGlassAdmin"
        principal_type      = "GROUP"
        principal_id        = "BreakGlass"
      }
    ],
    [{
      account_id          = var.management_account_id
      permission_set_name = "BreakGlassAdmin"
      principal_type      = "GROUP"
      principal_id        = "BreakGlass"
    }],
  )
}

################################################################################
# Break-glass detection: CloudWatch metric filter + SNS alarm on BreakGlassAdmin
# permission set assumption. Subscribe ops on-call to the SNS topic externally.
################################################################################

resource "aws_sns_topic" "break_glass_alerts" {
  name              = "${var.org_name}-break-glass-alerts"
  kms_master_key_id = module.kms.key_id
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_metric_filter" "break_glass" {
  name           = "${var.org_name}-break-glass-assumption"
  log_group_name = "/aws/cloudtrail/${var.org_name}-org-trail"
  pattern        = "{ ($.eventName = AssumeRoleWithSAML || $.eventName = AssumeRole) && $.requestParameters.roleArn = \"*BreakGlassAdmin*\" }"

  metric_transformation {
    name      = "BreakGlassAssumptions"
    namespace = "${var.org_name}/Security"
    value     = "1"
  }

  depends_on = [module.cloudtrail]
}

resource "aws_cloudwatch_metric_alarm" "break_glass" {
  alarm_name          = "${var.org_name}-break-glass-used"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.break_glass.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.break_glass.metric_transformation[0].namespace
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "BreakGlassAdmin role was assumed - investigate immediately"
  alarm_actions       = [aws_sns_topic.break_glass_alerts.arn]
  treat_missing_data  = "notBreaching"
  tags                = local.common_tags
}
