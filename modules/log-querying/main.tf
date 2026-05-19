locals {
  athena_results_bucket = var.athena_results_bucket_name != "" ? var.athena_results_bucket_name : aws_s3_bucket.results[0].bucket
}

resource "aws_s3_bucket" "results" {
  count  = var.athena_results_bucket_name == "" ? 1 : 0
  bucket = "${var.org_name}-athena-results"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "results" {
  count  = var.athena_results_bucket_name == "" ? 1 : 0
  bucket = aws_s3_bucket.results[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "results" {
  count         = var.athena_results_bucket_name == "" ? 1 : 0
  bucket        = aws_s3_bucket.results[0].id
  target_bucket = var.log_archive_bucket_name
  target_prefix = "s3-access-logs/${var.org_name}-athena-results/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "results" {
  count  = var.athena_results_bucket_name == "" ? 1 : 0
  bucket = aws_s3_bucket.results[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "results" {
  count                   = var.athena_results_bucket_name == "" ? 1 : 0
  bucket                  = aws_s3_bucket.results[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "results" {
  count  = var.athena_results_bucket_name == "" ? 1 : 0
  bucket = aws_s3_bucket.results[0].id

  rule {
    id     = "expire-old-results"
    status = "Enabled"
    filter {}
    expiration {
      days = var.query_result_retention_days
    }
  }

  rule {
    id     = "abort-incomplete-multipart"
    status = "Enabled"
    filter {}
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_athena_workgroup" "logs" {
  name = "${var.org_name}-log-querying"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${local.athena_results_bucket}/output/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = var.kms_key_arn
      }
    }
  }

  tags = var.tags
}

resource "aws_glue_catalog_database" "logs" {
  name        = "${var.org_name}_logs"
  description = "Glue database for querying centralized logs via Athena"
}

# CloudTrail table - assumes logs delivered to s3://<log-archive>/cloudtrail/
resource "aws_glue_catalog_table" "cloudtrail" {
  name          = "cloudtrail"
  database_name = aws_glue_catalog_database.logs.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "EXTERNAL"                  = "TRUE"
    "classification"            = "cloudtrail"
    "compressionType"           = "gzip"
    "projection.enabled"        = "true"
    "projection.region.type"    = "enum"
    "projection.region.values"  = "us-east-1,us-east-2,us-west-1,us-west-2,eu-west-1,eu-west-2,eu-central-1"
    "projection.year.type"      = "integer"
    "projection.year.range"     = "2024,2030"
    "projection.month.type"     = "integer"
    "projection.month.range"    = "1,12"
    "projection.month.digits"   = "2"
    "projection.day.type"       = "integer"
    "projection.day.range"      = "1,31"
    "projection.day.digits"     = "2"
    "storage.location.template" = "s3://${var.log_archive_bucket_name}/cloudtrail/AWSLogs/$${region}/CloudTrail/$${region}/$${year}/$${month}/$${day}/"
  }

  partition_keys {
    name = "region"
    type = "string"
  }
  partition_keys {
    name = "year"
    type = "int"
  }
  partition_keys {
    name = "month"
    type = "int"
  }
  partition_keys {
    name = "day"
    type = "int"
  }

  storage_descriptor {
    location      = "s3://${var.log_archive_bucket_name}/cloudtrail/"
    input_format  = "com.amazon.emr.cloudtrail.CloudTrailInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "com.amazon.emr.hive.serde.CloudTrailSerde"
    }

    columns {
      name = "eventversion"
      type = "string"
    }
    columns {
      name = "useridentity"
      type = "struct<type:string,principalid:string,arn:string,accountid:string,invokedby:string,accesskeyid:string,username:string>"
    }
    columns {
      name = "eventtime"
      type = "string"
    }
    columns {
      name = "eventsource"
      type = "string"
    }
    columns {
      name = "eventname"
      type = "string"
    }
    columns {
      name = "awsregion"
      type = "string"
    }
    columns {
      name = "sourceipaddress"
      type = "string"
    }
    columns {
      name = "useragent"
      type = "string"
    }
    columns {
      name = "errorcode"
      type = "string"
    }
    columns {
      name = "errormessage"
      type = "string"
    }
    columns {
      name = "requestparameters"
      type = "string"
    }
    columns {
      name = "responseelements"
      type = "string"
    }
    columns {
      name = "resources"
      type = "array<struct<arn:string,accountid:string,type:string>>"
    }
  }
}

# VPC Flow Logs table - parquet format (per modules/vpc settings)
resource "aws_glue_catalog_table" "vpc_flow_logs" {
  name          = "vpc_flow_logs"
  database_name = aws_glue_catalog_database.logs.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "EXTERNAL"                     = "TRUE"
    "classification"               = "parquet"
    "projection.enabled"           = "true"
    "projection.account_name.type" = "injected"
    "storage.location.template"    = "s3://${var.log_archive_bucket_name}/vpc-flow-logs/$${account_name}/"
  }

  partition_keys {
    name = "account_name"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${var.log_archive_bucket_name}/vpc-flow-logs/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "version"
      type = "int"
    }
    columns {
      name = "account_id"
      type = "string"
    }
    columns {
      name = "interface_id"
      type = "string"
    }
    columns {
      name = "srcaddr"
      type = "string"
    }
    columns {
      name = "dstaddr"
      type = "string"
    }
    columns {
      name = "srcport"
      type = "int"
    }
    columns {
      name = "dstport"
      type = "int"
    }
    columns {
      name = "protocol"
      type = "int"
    }
    columns {
      name = "packets"
      type = "bigint"
    }
    columns {
      name = "bytes"
      type = "bigint"
    }
    columns {
      name = "start"
      type = "bigint"
    }
    columns {
      name = "end"
      type = "bigint"
    }
    columns {
      name = "action"
      type = "string"
    }
    columns {
      name = "log_status"
      type = "string"
    }
  }
}

# ============================================================
# Saved Athena queries - CIS canonical investigations
# Run via: aws athena start-query-execution --query-string ... --work-group <wg>
# Or open the Athena console -> Saved queries -> select by name
# ============================================================

resource "aws_athena_named_query" "root_account_usage" {
  name        = "${var.org_name}-cis-3.3-root-account-usage"
  workgroup   = aws_athena_workgroup.logs.id
  database    = aws_glue_catalog_database.logs.name
  description = "CIS 3.3 - All API calls made by the root user in the last 7 days"
  query       = <<-SQL
    SELECT eventtime, eventname, sourceipaddress, useragent, awsregion, useridentity.accountid
    FROM ${aws_glue_catalog_database.logs.name}.cloudtrail
    WHERE useridentity.type = 'Root'
      AND year = year(current_date)
      AND month = month(current_date)
      AND day >= day(current_date - INTERVAL '7' DAY)
    ORDER BY eventtime DESC
    LIMIT 100;
  SQL
}

resource "aws_athena_named_query" "unauthorized_api_calls" {
  name        = "${var.org_name}-cis-3.1-unauthorized-api-calls"
  workgroup   = aws_athena_workgroup.logs.id
  database    = aws_glue_catalog_database.logs.name
  description = "CIS 3.1 - AccessDenied / UnauthorizedOperation in the last 24h"
  query       = <<-SQL
    SELECT eventtime, eventname, errorcode, errormessage, useridentity.arn, sourceipaddress
    FROM ${aws_glue_catalog_database.logs.name}.cloudtrail
    WHERE (errorcode LIKE '%UnauthorizedOperation' OR errorcode LIKE 'AccessDenied%')
      AND year = year(current_date)
      AND month = month(current_date)
      AND day >= day(current_date - INTERVAL '1' DAY)
    ORDER BY eventtime DESC
    LIMIT 500;
  SQL
}

resource "aws_athena_named_query" "console_logins_no_mfa" {
  name        = "${var.org_name}-cis-3.2-console-logins-without-mfa"
  workgroup   = aws_athena_workgroup.logs.id
  database    = aws_glue_catalog_database.logs.name
  description = "CIS 3.2 - Successful IAM-user console sign-ins without MFA"
  query       = <<-SQL
    SELECT eventtime, useridentity.username, sourceipaddress, useragent
    FROM ${aws_glue_catalog_database.logs.name}.cloudtrail
    WHERE eventname = 'ConsoleLogin'
      AND useridentity.type = 'IAMUser'
      AND json_extract_scalar(responseelements, '$.ConsoleLogin') = 'Success'
      AND (json_extract_scalar(requestparameters, '$.MFAUsed') = 'No'
           OR json_extract_scalar(requestparameters, '$.MFAUsed') IS NULL)
      AND year = year(current_date)
      AND month = month(current_date)
    ORDER BY eventtime DESC
    LIMIT 200;
  SQL
}

resource "aws_athena_named_query" "iam_user_creation" {
  name        = "${var.org_name}-iam-user-creation"
  workgroup   = aws_athena_workgroup.logs.id
  database    = aws_glue_catalog_database.logs.name
  description = "All IAM users created across the org (workloads should never create these)"
  query       = <<-SQL
    SELECT eventtime, awsregion, useridentity.arn AS created_by,
           json_extract_scalar(requestparameters, '$.userName') AS new_user
    FROM ${aws_glue_catalog_database.logs.name}.cloudtrail
    WHERE eventname = 'CreateUser'
      AND errorcode IS NULL
    ORDER BY eventtime DESC
    LIMIT 200;
  SQL
}

resource "aws_athena_named_query" "vpc_flow_top_talkers" {
  name        = "${var.org_name}-vpc-flow-top-talkers"
  workgroup   = aws_athena_workgroup.logs.id
  database    = aws_glue_catalog_database.logs.name
  description = "Top egress destinations by byte volume in the last hour - useful for anomaly hunting"
  query       = <<-SQL
    SELECT dstaddr, sum(bytes) AS total_bytes, sum(packets) AS total_packets, count(*) AS flows
    FROM ${aws_glue_catalog_database.logs.name}.vpc_flow_logs
    WHERE "start" > to_unixtime(current_timestamp - INTERVAL '1' HOUR)
      AND action = 'ACCEPT'
    GROUP BY dstaddr
    ORDER BY total_bytes DESC
    LIMIT 50;
  SQL
}

resource "aws_athena_named_query" "vpc_flow_rejected" {
  name        = "${var.org_name}-vpc-flow-rejected"
  workgroup   = aws_athena_workgroup.logs.id
  database    = aws_glue_catalog_database.logs.name
  description = "Top REJECT sources in the last hour - port-scan / firewall probe detection"
  query       = <<-SQL
    SELECT srcaddr, dstport, count(*) AS reject_count
    FROM ${aws_glue_catalog_database.logs.name}.vpc_flow_logs
    WHERE "start" > to_unixtime(current_timestamp - INTERVAL '1' HOUR)
      AND action = 'REJECT'
    GROUP BY srcaddr, dstport
    ORDER BY reject_count DESC
    LIMIT 50;
  SQL
}

resource "aws_athena_named_query" "kms_key_disable_or_delete" {
  name        = "${var.org_name}-cis-3.7-kms-disable-or-delete"
  workgroup   = aws_athena_workgroup.logs.id
  database    = aws_glue_catalog_database.logs.name
  description = "CIS 3.7 - Customer-managed KMS keys disabled or scheduled for deletion"
  query       = <<-SQL
    SELECT eventtime, eventname, useridentity.arn,
           json_extract_scalar(requestparameters, '$.keyId') AS key_id,
           json_extract_scalar(requestparameters, '$.pendingWindowInDays') AS pending_days
    FROM ${aws_glue_catalog_database.logs.name}.cloudtrail
    WHERE eventsource = 'kms.amazonaws.com'
      AND eventname IN ('DisableKey', 'ScheduleKeyDeletion')
    ORDER BY eventtime DESC
    LIMIT 100;
  SQL
}
