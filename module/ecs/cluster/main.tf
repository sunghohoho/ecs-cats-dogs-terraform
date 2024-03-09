# ecs 로깅을 위한 cloudwatch 로그 그룹 생성
resource "aws_cloudwatch_log_group" "this" {
  name = "${var.project_name}"
}

#ecs 클러스터 생성
resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"

  configuration {
    execute_command_configuration {
      logging    = "OVERRIDE"
      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = "${aws_cloudwatch_log_group.this.name}-cw-loggroup"
      }
    }
  }
}

# fargate provider 추가
resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
  depends_on = [ aws_ecs_cluster.this ]
}