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

# service alb 생성
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

# web 페이지로 향할 타겟그룹 생성
resource "aws_lb_target_group" "webs" {
  name        = "${var.project_name}-svc-webs-tg"
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

resource "aws_lb_target_group" "cats" {
  name        = "${var.project_name}-svc-cats-tg"
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

# 파게이트 유형의 경우, 타겟타입이 ip로 지정 필요
resource "aws_lb_target_group" "fargate" {
  name        = "${var.project_name}-svc-tg-fargate"
  target_type = "ip"
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

# 80 리스너 생성
resource "aws_lb_listener" "this"{
  load_balancer_arn = aws_lb.this.arn
  port = 80
  protocol = "HTTP"
  default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.webs.arn
  }
  tags = {
    Environment = "dev"
    Terraform = "true"
    Terragrunt = "true"
  }
}

# cats로 향할 라우팅 규칙 추가
resource "aws_lb_listener_rule" "web-rule" {
  listener_arn = aws_lb_listener.this.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cats.arn
  }

  condition {
    path_pattern {
      values = ["/cats*"]
    }
  }
}

# dogs 경로로 포워딩 되는 경우 수정 fargate 타겟그룹으로 가도록 구성
resource "aws_lb_listener_rule" "fargate" {
  listener_arn = aws_lb_listener.this.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fargate.arn
  }

  condition {
    path_pattern {
      values = ["/dogs*"]
    }
  }
}
