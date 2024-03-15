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

data "terraform_remote_state" "sg" {
   backend = "s3"
  config = {
    bucket = "sh-terraform-backend-apn2"
    key = "sg/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

# # 모듈 안됨 ㅠㅠ
# module "ecs-svc-alb" {
#   source = "terraform-aws-modules/alb/aws"

#   name    = "${var.project_name}-svc-alb"
#   vpc_id  = data.terraform_remote_state.vpc.outputs.vpc_id
#   subnets = data.terraform_remote_state.vpc.outputs.public_subnet_id

#   # Security Group
#   security_group_ingress_rules = {
#     all_http = {
#       from_port   = 80
#       to_port     = 80
#       ip_protocol = "tcp"
#       description = "HTTP web traffic"
#       cidr_ipv4   = "0.0.0.0/0"
#     }
#     all_https = {
#       from_port   = 443
#       to_port     = 443
#       ip_protocol = "tcp"
#       description = "HTTPS web traffic"
#       cidr_ipv4   = "0.0.0.0/0"
#     }
#   }
#   security_group_egress_rules = {
#     all = {
#       ip_protocol = "-1"
#       cidr_ipv4   = "0.0.0.0/0"
#     }
#   }

#   #리스너
#   listeners = {
#     ex-http-https-redirect = {
#       port     = 80
#       protocol = "HTTP"
#       redirect = {
#         port        = "443"
#         protocol    = "HTTPS"
#         status_code = "HTTP_301"
#       }
#     }
#     ex-https = {
#       port            = 443
#       protocol        = "HTTPS"
#       certificate_arn = "arn:aws:acm:ap-northeast-2:866477832211:certificate/91db58e2-f929-44d2-b194-f6fa6be7f9cb"
#       forward = {
#         target_group_key = "ex-instance"
#       }
#     }
#   }

#   target_groups = {
#     ex-instance = {
#       name_prefix      = "h1"
#       protocol         = "HTTP"
#       port             = 80
#       target_type      = "instance"
#     }
#   }

#   tags = {
#     Environment = "dev"
#     Terraform = "true"
#     Terragrunt = "true"
#   }
# }

resource "aws_lb" "this"{
  name = "${var.project_name}-svc-alb"
  internal = false	 
  load_balancer_type = "application"
  security_groups = [data.terraform_remote_state.sg.outputs.ecs-svc-alb-sg]
  subnets = data.terraform_remote_state.vpc.outputs.public_subnet_id
  lifecycle { 
    create_before_destroy = true   
  }
  tags = {
    Environment = "dev"
    Terraform = "true"
    Terragrunt = "true"
  }
}

resource "aws_lb_target_group" "this" {
  name        = "${var.project_name}-svc-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    interval            = 30
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = {
    Environment = "dev"
    Terraform = "true"
    Terragrunt = "true"
  }
}

resource "aws_lb_listener" "this"{
  load_balancer_arn = aws_lb.this.arn
  port = 80
  protocol = "HTTP"
  default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.this.arn
  }
  tags = {
    Environment = "dev"
    Terraform = "true"
    Terragrunt = "true"
  }
}

