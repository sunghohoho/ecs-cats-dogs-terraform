data "terraform_remote_state" "private_subnet_id" {
  backend = "s3"
  config = {
    bucket = "sh-terraform-backend-apn2"
    key = "network/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

module "ecs-cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  cluster_name = "${var.project_name}-cluster"

  # 서브넷 지정
  #subnet_ids = "${data.terraform_remote_state.private_subnet_id.outputs.private_subnet_id}"

  # 로깅 구성
  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  #Fargate 용량 공급자 추가
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

# ec2 유형 용량 공급자 추가
  autoscaling_capacity_providers = {
    asg = {
      auto_scaling_group_arn         = "arn:aws:iam::866477832211:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 5
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 60
      }

      default_capacity_provider_strategy = {
        weight = 60
        base   = 20
      }
    }
  }
}