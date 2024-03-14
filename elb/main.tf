data "terraform_remote_state" "vpc" {
   backend = "s3"
  config = {
    bucket = "sh-terraform-backend-apn2"
    key = "network/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

data "terraform_remote_state" "ecs" {
   backend = "s3"
  config = {
    bucket = "sh-terraform-backend-apn2"
    key = "ecs/terraform.tfstate"
    region = "ap-northeast-2"
  }
}


module "ecs-svc-alb" {
  source  = "terraform-aws-modules/elb/aws"

  name = "${var.project_name}-svc-alb"

  subnets         = data.terraform_remote_state.vpc.outputs.public_subnet_id
  security_groups = ["sg-040cad4414ebaa895"]
  internal        = false

  listener = [
    {
      instance_port     = 80
      instance_protocol = "HTTP"
      lb_port           = 80
      lb_protocol       = "HTTP"
    }
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  // ELB attachments
  number_of_instances = 0

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "this" {
  name        = "${var.project_name}-svc-tg"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
}