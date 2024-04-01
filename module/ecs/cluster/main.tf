data "terraform_remote_state" "sg" {
   backend = "s3"
  config = {
    bucket = "sh-terraform-backend-apn2"
    key = "sg/terraform.tfstate"
    region = "ap-northeast-2"
  }
}
# ecs 로깅을 위한 cloudwatch 로그 그룹 생성 (0)
resource "aws_cloudwatch_log_group" "this" {
  name = "${var.project_name}"
}

#ecs 클러스터 생성 (1)
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

#######################################
# Fargate 유형 
#######################################

# fargate provider 추가 (1), fargate의 경우 aws_ecs_cluster_capacity_provider - Fargate 를 사용
resource "aws_ecs_cluster_capacity_providers" "fargate" {
  count = var.is_ec2_provider ? 0 : 1
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
  depends_on = [ aws_ecs_cluster.this ]
}

#######################################
# EC2 유형 
#######################################

# ec2 유형, ec2 asg provider 추가 (1), ec2 유형의 경우 ecs_capacity_provider를 사용
resource "aws_ecs_capacity_provider" "this" {
  count = var.is_ec2_provider ? 1 : 0
  name = "${var.project_name}-ECS_CapacityProvider"

  auto_scaling_group_provider {
    # fargate 유형인 경우에는 null 값을 사용하여 실행되지 않게함, ec2 유형의 경우에는 아래에서 생성될 asg를 사용, count가 들어가 cound.index로 실행 인덱스 사용
    auto_scaling_group_arn         = aws_autoscaling_group.this[count.index].arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = var.max_size
      minimum_scaling_step_size = var.min_size
      status                    = "ENABLED"
      target_capacity           = var.desire_size
    }
  }
}

# ec2 유형의 경우 asg의 capacity provider 추가 필요
resource "aws_ecs_cluster_capacity_providers" "cas" {
  count = var.is_ec2_provider ? 1 : 0
  cluster_name       = aws_ecs_cluster.this.name
  # ec2 유형일 경우에는 ec2의 capacity provider를 사용합니다. count 변수 사용
  # capacity_providers = var.is_ec2_provider ? [aws_ecs_capacity_provider.this[count.index].name] : null
  capacity_providers = [aws_ecs_capacity_provider.this[count.index].name]

   default_capacity_provider_strategy {
   base              = 1
   weight            = 100
   capacity_provider = aws_ecs_capacity_provider.this[count.index].name
 }
 depends_on = [ aws_ecs_cluster.this ]
}

# EC2 인스턴스, 클러스터에 귀속하는 스크립트
locals {
    ecs_ec2provider_script = <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.this.name} >> /etc/ecs/ecs.config
  EOF
}

# ec2 유형 ecs asg launch template 정의
# public ecs instance ami 사용
resource "aws_launch_template" "this" {
  count = var.is_ec2_provider ? 1 : 0
  name   = "${var.project_name}-ecs-lt"
  image_id      = "ami-0f69a3951250c72a4"
  instance_type = "t3.medium"
  key_name = "test"
  vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.ecs-ec2-instance-sg]
  iam_instance_profile {
    arn = "arn:aws:iam::866477832211:instance-profile/ecsInstanceRole"
  }
  # launch template에 userdata 사용
  user_data = base64encode(local.ecs_ec2provider_script)

  # asg로 생성되는 인스턴스에 name 태그 지정
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-ec2-provider"
    }
  }
}

# ec2 유형의 asg 구성
resource "aws_autoscaling_group" "this" {
  count = var.is_ec2_provider ? 1 : 0
  name                  = "${var.project_name}-ASG"
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
    id      = aws_launch_template.this[count.index].id
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