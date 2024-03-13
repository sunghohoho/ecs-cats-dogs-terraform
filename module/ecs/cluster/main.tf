
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
resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
  depends_on = [ aws_ecs_cluster.this ]
}

# ec2 유형, ec2 asg provider 추가
resource "aws_ecs_capacity_provider" "this" {
  count = var.is_ec2_provider ? 1 : 0
  name = "${var.project_name}-ECS_CapacityProvider"

  auto_scaling_group_provider {
    # fargate 유형인 경우에는 null 값을 사용하여 실행되지 않게함, ec2 유형의 경우에는 아래에서 생성될 asg를 사용, count가 들어가 cound.index로 실행 인덱스 사용
    auto_scaling_group_arn         = var.is_ec2_provider ? aws_autoscaling_group.this[count.index].arn : null
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
  count = var.is_ec2_provider ? 1 : 0
  cluster_name       = aws_ecs_cluster.this.name
  # ec2 유형일 경우에는 ec2의 capacity provider를 사용합니다. count 변수 사용
  capacity_providers = var.is_ec2_provider ? [aws_ecs_capacity_provider.this[count.index].name] : null
}

# ec2 유형 ecs asg 정의

resource "aws_launch_configuration" "this" {
  name_prefix   = "${var.project_name}-ecs-lt"
  image_id      = "ami-0f69a3951250c72a4"
  instance_type = "t3.micro"
}

resource "aws_autoscaling_group" "this" {
  count = var.is_ec2_provider ? 1 : 0
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
    id      = aws_autoscaling_group.this.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    propagate_at_launch = true
    key                 = "AmazonECSManaged"
    value               = true
  }
}