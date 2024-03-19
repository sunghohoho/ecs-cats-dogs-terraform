resource "aws_ecs_service" "this" {
  name = var.name
  cluster = var.cluster
  task_definition = var.task_definition
  desired_count =  var.desired_count
  launch_type = var.launch_type

  iam_role = var.is_fargate ?  null : "arn:aws:iam::866477832211:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"

  # ordered_placement_strategy {
  #   type  = "binpack"
  #   field = "cpu"
  # }

  deployment_circuit_breaker {
    enable = "true"
    rollback = "true"
  }

  load_balancer {
    target_group_arn = var.target_group
    container_name = var.container_name
    container_port = var.container_port
  }

### dynamic 및 for_each 사용법 확인하기
dynamic "network_configuration" {
    for_each = var.is_fargate ? [1] : []
    content {
      subnets = var.subnet
    }
  }
}