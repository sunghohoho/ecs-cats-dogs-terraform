data "aws_caller_identity" "current" {}

data "aws_region" "currnet" {}

resource "aws_ecs_task_definition" "this" {
  family = var.family
  # is_fargate 값이 true 면 faragate, false면 EC2
  requires_compatibilities = var.is_fargate ? ["FARGATE"] : ["EC2"]
  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"
  task_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"

  cpu = var.cpu
  #faragte면 awsvpc, 아닌 경우 입력 값
  network_mode = var.is_fargate ? "awsvpc" : var.network_mode
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
            hostPort      = "${var.is_fargate}" ? "${var.containerport}" : "${var.hostport}"
            }
        ]
        # 로깅을 위한 awslogs 드라이버 구성, create 옵션이 없으면 task 안뜸
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "${var.container_name}/task/log"
            awslogs-region        = "ap-northeast-2"
            awslogs-create-group  = "true"
            awslogs-stream-prefix = "abc-ecs"
          }
        }
    }
    ])
}