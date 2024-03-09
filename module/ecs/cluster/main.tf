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


# EC2 유형의 경우 ASG 생성
# resource "aws_autoscaling_group" "this" {
#   count = var.is_ec2_provider ? 1 : 0
#   tag {
#     key                 = "AmazonECSManaged"
#     value               = true
#     propagate_at_launch = true
#   }
# }

# ec2 유형, ec2 asg provider 추가
resource "aws_ecs_capacity_provider" "this" {
#   count = var.is_ec2_provider ? 1 : 0
  name = "${var.project_name}-ECS_CapacityProvider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.this.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = var.max_size
      minimum_scaling_step_size = var.min_size
      status                    = "ENABLED"
      target_capacity           = var.desire_size
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cas" {
#   count = var.is_ec2_provider ? 1 : 0
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.this.name]
}

# ec2 유형 ecs asg 정의

resource "aws_autoscaling_group" "this" {
#   count = var.is_ec2_provider ? 1 : 0
  name                  = "${var.project_name}_ASG_cas"
  max_size              = var.max_size
  min_size              = var.min_size
  vpc_zone_identifier   = var.subnet_id
  health_check_type     = "EC2"
  protect_from_scale_in = true

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  launch_template {
    id      = "lt-0c31ff941618673e2"
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    # key                 = "Name"
    # value               = "${var.project_name}_ASG_cas"
    propagate_at_launch = true
    key                 = "AmazonECSManaged"
    value               = true
  }
}