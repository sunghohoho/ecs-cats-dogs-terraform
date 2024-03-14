data "terraform_remote_state" "vpc" {
   backend = "s3"
  config = {
    bucket = "sh-terraform-backend-apn2"
    key = "network/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

module "ecs-svc-alb-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ecs-svc-alb-sg"
  description = "ecs service alb securirty group, 80 access"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  
  # inbound 그룹 추가
  ingress_with_cidr_blocks = [
    # http anywhere 추가
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    # 1111 - 3333 anywhere 추가
    {
      from_port   = 1111
      to_port     = 3333
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  # outbound 0 - 65535 anywhere 추가
  egress_with_cidr_blocks = [
      {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  # outbound anywhere 추가
  egress_rules = ["all-all"]
}


module "vote_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "user-service"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks      = ["10.10.0.0/16"]
  ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.10.0.0/16"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
   egress_cidr_blocks = ["0.0.0.0/0"]
}


