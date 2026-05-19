package terraform

# Deny any S3 bucket that doesn't have Block Public Access configured.
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    resource.change.actions[_] != "delete"

    # Look for a matching aws_s3_bucket_public_access_block in the plan
    bucket_addr := resource.address
    pab := input.resource_changes[_]
    pab.type == "aws_s3_bucket_public_access_block"
    pab.change.after.bucket == bucket_addr
    not all_blocks_set(pab.change.after)

    msg := sprintf("S3 bucket %s has incomplete public access block (block_public_acls/block_public_policy/ignore_public_acls/restrict_public_buckets must all be true)", [bucket_addr])
}

all_blocks_set(pab) {
    pab.block_public_acls == true
    pab.block_public_policy == true
    pab.ignore_public_acls == true
    pab.restrict_public_buckets == true
}
