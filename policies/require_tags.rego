package terraform

required_tags := {"Organization", "Account", "Environment", "ManagedBy", "ComplianceScope", "DataClass"}

# Resource types where tags are required.
taggable_types := {
    "aws_s3_bucket",
    "aws_dynamodb_table",
    "aws_db_instance",
    "aws_rds_cluster",
    "aws_lambda_function",
    "aws_ecs_cluster",
    "aws_eks_cluster",
    "aws_kms_key",
    "aws_sns_topic",
    "aws_sqs_queue",
    "aws_secretsmanager_secret",
}

deny[msg] {
    resource := input.resource_changes[_]
    taggable_types[resource.type]
    resource.change.actions[_] != "delete"

    tags := resource.change.after.tags_all
    missing := required_tags - {k | tags[k]}
    count(missing) > 0

    msg := sprintf("Resource %s missing required tags: %v", [resource.address, missing])
}
