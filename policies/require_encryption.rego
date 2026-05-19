package terraform

# Deny S3 buckets without SSE-KMS configuration in the plan.
deny[msg] {
    bucket := input.resource_changes[_]
    bucket.type == "aws_s3_bucket"
    bucket.change.actions[_] != "delete"

    bucket_addr := bucket.address
    sse := [r |
        r := input.resource_changes[_]
        r.type == "aws_s3_bucket_server_side_encryption_configuration"
        r.change.after.bucket == bucket_addr
    ]
    count(sse) == 0

    msg := sprintf("S3 bucket %s has no SSE configuration", [bucket_addr])
}

# Deny EBS volumes without encryption.
deny[msg] {
    volume := input.resource_changes[_]
    volume.type == "aws_ebs_volume"
    volume.change.actions[_] != "delete"
    volume.change.after.encrypted != true
    msg := sprintf("EBS volume %s is not encrypted", [volume.address])
}

# Deny RDS instances without storage encryption.
deny[msg] {
    rds := input.resource_changes[_]
    rds.type == "aws_db_instance"
    rds.change.actions[_] != "delete"
    rds.change.after.storage_encrypted != true
    msg := sprintf("RDS instance %s is not encrypted at rest", [rds.address])
}

# Deny DynamoDB tables without server_side_encryption.
deny[msg] {
    table := input.resource_changes[_]
    table.type == "aws_dynamodb_table"
    table.change.actions[_] != "delete"

    sse := table.change.after.server_side_encryption
    not sse[0].enabled

    msg := sprintf("DynamoDB table %s has SSE disabled", [table.address])
}
