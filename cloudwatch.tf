resource "aws_cloudwatch_log_group" "tendenci" {
  name              = "tendenci-${var.env}"
  retention_in_days = 14
}

resource "aws_cloudwatch_event_rule" "midnight" {
  name        = "tendenci-${var.env}-midnight"
  description = "triggers at midnight"
  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "midnight-thirty" {
  name        = "tendenci-${var.env}-midnight-thirty"
  description = "triggers at midnight thirty"
  schedule_expression = "cron(30 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "run_nightly_commands" {
  target_id = "run_nightly_commands_tendenci_${var.env}"
  arn       = var.fargate_cluster_arn
  rule      = aws_cloudwatch_event_rule.midnight.name
  role_arn  = aws_iam_role.ecs_events.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.tendenci.arn
    launch_type = "FARGATE"
    network_configuration {
      subnets          = var.private_subnet_ids
      assign_public_ip = false
      security_groups  = [aws_security_group.tendenci.id]
    }
  }

  input = <<DOC
{
  "containerOverrides": [
    {
      "name": "tendenci-${var.env}",
      "command": ["run_nightly_commands"]
    }
  ]
}
DOC
}

resource "aws_cloudwatch_event_target" "process_unindexed" {
  target_id = "process_unindexed_tendenci_${var.env}"
  arn       = var.fargate_cluster_arn
  rule      = aws_cloudwatch_event_rule.midnight-thirty.name
  role_arn  = aws_iam_role.ecs_events.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.tendenci.arn
    launch_type = "FARGATE"
    network_configuration {
      subnets          = var.private_subnet_ids
      assign_public_ip = false
      security_groups  = [aws_security_group.tendenci.id]
    }
  }

  input = <<DOC
{
  "containerOverrides": [
    {
      "name": "tendenci-${var.env}",
      "command": ["process_unindexed"]
    }
  ]
}
DOC
}