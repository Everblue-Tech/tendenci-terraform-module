resource "aws_ecs_task_definition" "tendenci" {
  family                   = "tendenci-${var.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.tendenci-execution.arn
  cpu                      = 1024
  memory                   = 2048
  task_role_arn            = aws_iam_role.tendenci-execution.arn
  volume {
    name = "efs-tendenci"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs.id
      root_directory = "/"
    }
  }
  container_definitions = <<EOF
[
  {
    "name": "tendenci-${var.env}",
    "image": "${var.tendenci_image}",
    "command": ["prod"],
    "cpu": 1024,
    "memory": 2048,
    "essential": true,
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 8000,
        "hostPort": 8000
      }
    ],
    "environment": [
      {"name": "secret_id", "value": "${aws_secretsmanager_secret.tendenci.name}"}
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "tendenci-${var.env}",
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-stream-prefix": "tendenci-"
      }
    },
    "mountPoints": [
      {
        "readOnly": false,
        "containerPath": "/tendenci",
        "sourceVolume": "efs-tendenci"
      }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "tendenci" {
  name             = "tendenci-${var.env}"
  cluster          = var.fargate_cluster_id
  task_definition  = aws_ecs_task_definition.tendenci.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"
  health_check_grace_period_seconds = 480
  network_configuration {
    subnets          = var.private_subnet_ids
    assign_public_ip = false
    security_groups  = [aws_security_group.tendenci.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group._.arn
    container_name   = "tendenci-${var.env}"
    container_port   = 8000
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
}
