package terraform

# Deny aws_iam_user resources in workload contexts.
# Service accounts use IAM roles. Humans use Identity Center.
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_iam_user"
    resource.change.actions[_] != "delete"
    msg := sprintf("aws_iam_user is forbidden (%s) - use IAM Identity Center for humans, IAM roles for services", [resource.address])
}

# Deny aws_iam_access_key resources (long-lived credentials).
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_iam_access_key"
    resource.change.actions[_] != "delete"
    msg := sprintf("aws_iam_access_key is forbidden (%s) - use sts:AssumeRole or OIDC instead", [resource.address])
}

# Deny inline IAM policies with NotAction or wildcards on resource.
deny[msg] {
    policy := input.resource_changes[_]
    policy.type == "aws_iam_policy"
    policy.change.actions[_] != "delete"

    doc := json.unmarshal(policy.change.after.policy)
    stmt := doc.Statement[_]
    stmt.Effect == "Allow"
    stmt.Action == "*"
    stmt.Resource == "*"

    msg := sprintf("Policy %s grants Action=* on Resource=* (overly permissive)", [policy.address])
}
