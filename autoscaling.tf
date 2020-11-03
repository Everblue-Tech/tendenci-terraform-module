resource "aws_appautoscaling_target" "_" {
  max_capacity       = var.maximum_count
  min_capacity       = var.minimum_count
  resource_id        = "service/${var.fargate_cluster_name}/${aws_ecs_service.tendenci.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "cpu"
  service_namespace  = aws_appautoscaling_target._.service_namespace
  scalable_dimension = aws_appautoscaling_target._.scalable_dimension
  resource_id        = aws_appautoscaling_target._.resource_id
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.target_cpu
    scale_in_cooldown  = 180
    scale_out_cooldown = 180
  }
}

resource "aws_appautoscaling_policy" "memory" {
  name               = "memory"
  service_namespace  = aws_appautoscaling_target._.service_namespace
  scalable_dimension = aws_appautoscaling_target._.scalable_dimension
  resource_id        = aws_appautoscaling_target._.resource_id
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.target_memory
    scale_in_cooldown  = 180
    scale_out_cooldown = 180
  }
}