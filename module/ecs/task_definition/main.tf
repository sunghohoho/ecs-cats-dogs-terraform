data "aws_region" "currnet" {}

resource "aws_ecs_task_definition" "this" {
  family = var.family

  requires_compatibilities = ["FARGATE", "EC2"]

  cpu = var.cpu
  network_mode = var.network_mode
  memory = var.mem

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
        name = "${var.container_name}",
        image = "${var.container_url}:latest",
        cpu = "${var.container_cpu}",
        memory = "${var.container_mem}",
        essential = true
        portMappings = [
            {
            containerPort = "${var.containerport}"
            hostPort      = "${var.hostport}"
            }
        ]
    }
    ])
}