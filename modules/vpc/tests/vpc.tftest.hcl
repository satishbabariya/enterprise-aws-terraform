mock_provider "aws" {}

variables {
  org_name               = "testorg"
  account_name           = "prod"
  region                 = "us-east-1"
  cidr_block             = "10.1.0.0/16"
  availability_zones     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs    = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs   = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
  isolated_subnet_cidrs  = ["10.1.20.0/24", "10.1.21.0/24", "10.1.22.0/24"]
  log_archive_bucket_arn = "arn:aws:s3:::testorg-us-east-1-log-archive"
  flow_log_kms_key_arn   = "arn:aws:kms:us-east-1:111111111111:key/abc"
}

run "three_subnets_per_tier" {
  command = plan

  assert {
    condition     = length(aws_subnet.public) == 3
    error_message = "3 public subnets required"
  }
  assert {
    condition     = length(aws_subnet.private) == 3
    error_message = "3 private subnets required"
  }
  assert {
    condition     = length(aws_subnet.isolated) == 3
    error_message = "3 isolated subnets required"
  }
}

run "public_subnets_no_auto_public_ip" {
  command = plan

  assert {
    condition     = alltrue([for s in aws_subnet.public : s.map_public_ip_on_launch == false])
    error_message = "Public subnets must NOT auto-assign public IPs (CIS / least privilege)"
  }
}

run "eks_tags_added_by_default" {
  command = plan

  assert {
    condition     = contains(keys(aws_subnet.public[0].tags), "kubernetes.io/role/elb")
    error_message = "Public subnets must carry kubernetes.io/role/elb tag for ALB Controller"
  }

  assert {
    condition     = contains(keys(aws_subnet.private[0].tags), "kubernetes.io/role/internal-elb")
    error_message = "Private subnets must carry kubernetes.io/role/internal-elb tag"
  }
}

run "eks_tags_off_when_disabled" {
  command = plan

  variables {
    eks_subnet_tags_enabled = false
  }

  assert {
    condition     = !contains(keys(aws_subnet.public[0].tags), "kubernetes.io/role/elb")
    error_message = "EKS tags must NOT be present when eks_subnet_tags_enabled = false"
  }
}

run "cluster_specific_tags_added" {
  command = plan

  variables {
    eks_cluster_names = ["prod-cluster"]
  }

  assert {
    condition     = contains(keys(aws_subnet.public[0].tags), "kubernetes.io/cluster/prod-cluster")
    error_message = "kubernetes.io/cluster/<name> tag must be added when cluster names supplied"
  }
}

run "flow_logs_enabled" {
  command = plan

  assert {
    condition     = aws_flow_log.this.traffic_type == "ALL"
    error_message = "Flow logs must capture ALL traffic"
  }

  assert {
    condition     = aws_flow_log.this.log_destination_type == "s3"
    error_message = "Flow logs must deliver to S3"
  }
}

run "gateway_endpoints_default_on" {
  command = plan

  assert {
    condition     = length(aws_vpc_endpoint.s3) == 1
    error_message = "S3 gateway endpoint must exist by default"
  }
  assert {
    condition     = length(aws_vpc_endpoint.dynamodb) == 1
    error_message = "DynamoDB gateway endpoint must exist by default"
  }
}

run "interface_endpoints_created" {
  command = plan

  assert {
    condition     = length(aws_vpc_endpoint.interface) >= 5
    error_message = "Default interface endpoints (ssm, kms, logs, secretsmanager, ecr.api, ...) must exist"
  }
}
