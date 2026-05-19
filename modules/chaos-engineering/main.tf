resource "aws_iam_role" "fis" {
  name = "${var.org_name}-fis-experiment-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "fis.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

# Permissions for the experiment actions we expose below.
# Add more managed policies (FISServiceRolePolicyFor*) when you add new actions.
resource "aws_iam_role_policy_attachment" "fis_ec2" {
  role       = aws_iam_role.fis.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorEC2Access"
}

resource "aws_iam_role_policy_attachment" "fis_network" {
  role       = aws_iam_role.fis.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorNetworkAccess"
}

resource "aws_iam_role_policy_attachment" "fis_rds" {
  role       = aws_iam_role.fis.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorRDSAccess"
}

resource "aws_iam_role_policy_attachment" "fis_eks" {
  role       = aws_iam_role.fis.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorEKSAccess"
}

# ============================================================
# Experiment 1: EC2 instance stop (resilience to instance loss)
# ============================================================
resource "aws_fis_experiment_template" "ec2_stop" {
  description = "Stop 1 ChaosEligible-tagged EC2 instance for 5 minutes"
  role_arn    = aws_iam_role.fis.arn

  action {
    name      = "stopInstance"
    action_id = "aws:ec2:stop-instances"

    parameter {
      key   = "startInstancesAfterDuration"
      value = "PT5M"
    }

    target {
      key   = "Instances"
      value = "ec2-targets"
    }
  }

  target {
    name           = "ec2-targets"
    resource_type  = "aws:ec2:instance"
    selection_mode = "COUNT(1)"

    resource_tag {
      key   = var.experiment_target_tag_key
      value = var.experiment_target_tag_value
    }
  }

  dynamic "stop_condition" {
    for_each = length(var.stop_condition_alarm_arns) > 0 ? var.stop_condition_alarm_arns : ["none"]
    content {
      source = length(var.stop_condition_alarm_arns) > 0 ? "aws:cloudwatch:alarm" : "none"
      value  = length(var.stop_condition_alarm_arns) > 0 ? stop_condition.value : null
    }
  }

  log_configuration {
    log_schema_version = 2

    cloudwatch_logs_configuration {
      log_group_arn = "${var.log_group_arn}:*"
    }
  }

  tags = merge(var.tags, { Name = "${var.org_name}-fis-ec2-stop" })
}

# ============================================================
# Experiment 2: AZ failure simulation via network blackhole
# ============================================================
resource "aws_fis_experiment_template" "az_failure" {
  description = "Simulate AZ failure - blackhole all traffic to subnets in one AZ for 10 min"
  role_arn    = aws_iam_role.fis.arn

  action {
    name      = "blackholeSubnet"
    action_id = "aws:network:disrupt-connectivity"

    parameter {
      key   = "duration"
      value = "PT10M"
    }
    parameter {
      key   = "scope"
      value = "all"
    }

    target {
      key   = "Subnets"
      value = "subnet-targets"
    }
  }

  target {
    name           = "subnet-targets"
    resource_type  = "aws:ec2:subnet"
    selection_mode = "ALL"

    resource_tag {
      key   = var.experiment_target_tag_key
      value = var.experiment_target_tag_value
    }
  }

  dynamic "stop_condition" {
    for_each = length(var.stop_condition_alarm_arns) > 0 ? var.stop_condition_alarm_arns : ["none"]
    content {
      source = length(var.stop_condition_alarm_arns) > 0 ? "aws:cloudwatch:alarm" : "none"
      value  = length(var.stop_condition_alarm_arns) > 0 ? stop_condition.value : null
    }
  }

  log_configuration {
    log_schema_version = 2

    cloudwatch_logs_configuration {
      log_group_arn = "${var.log_group_arn}:*"
    }
  }

  tags = merge(var.tags, { Name = "${var.org_name}-fis-az-failure" })
}

# ============================================================
# Experiment 3: RDS failover (writer to reader)
# ============================================================
resource "aws_fis_experiment_template" "rds_failover" {
  description = "Force Aurora cluster failover - tests app reconnect logic"
  role_arn    = aws_iam_role.fis.arn

  action {
    name      = "rebootDbCluster"
    action_id = "aws:rds:failover-db-cluster"

    target {
      key   = "Clusters"
      value = "rds-targets"
    }
  }

  target {
    name           = "rds-targets"
    resource_type  = "aws:rds:cluster"
    selection_mode = "COUNT(1)"

    resource_tag {
      key   = var.experiment_target_tag_key
      value = var.experiment_target_tag_value
    }
  }

  dynamic "stop_condition" {
    for_each = length(var.stop_condition_alarm_arns) > 0 ? var.stop_condition_alarm_arns : ["none"]
    content {
      source = length(var.stop_condition_alarm_arns) > 0 ? "aws:cloudwatch:alarm" : "none"
      value  = length(var.stop_condition_alarm_arns) > 0 ? stop_condition.value : null
    }
  }

  log_configuration {
    log_schema_version = 2

    cloudwatch_logs_configuration {
      log_group_arn = "${var.log_group_arn}:*"
    }
  }

  tags = merge(var.tags, { Name = "${var.org_name}-fis-rds-failover" })
}
