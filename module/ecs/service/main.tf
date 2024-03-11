resource "aws_ecs_service" "this" {
  name = var.name
  cluster = var.cluster
  task_definition = var.task_definition
  desired_count = var.desired_count

  iam_role = "arn:aws:iam::866477832211:role/ecsTaskExecutionRole"

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  deployment_circuit_breaker {
    enable = "true"
    rollback = "true"
  }

  load_balancer {
    target_group_arn = var.target_group
    container_name = var.container_name
    container_port = var.container_port
  }

  network_configuration {
    subnets = var.subnet
    # security_groups = var.svcsg
  }
}