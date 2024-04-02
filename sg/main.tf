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


module "ecs-ec2-instance-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ecs-ec2-instance-sg"
  description = "ecs ec2 provider ec2 securirty group, 80 access, 1111 access"
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
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  # outbound anywhere 추가
  egress_rules = ["all-all"]
}

module "ecs-fargate-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ecs-fargate-sg"
  description = "ecs fargate-sg, 0 - 65535"
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
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  # outbound anywhere 추가
  egress_rules = ["all-all"]
}

module "bastion-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "bastion-sg"
  description = "ecs bastion-sg, 22"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  
  # inbound 그룹 추가
  ingress_with_cidr_blocks = [
    # http anywhere 추가
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  # outbound anywhere 추가
  egress_rules = ["all-all"]
}




