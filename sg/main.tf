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
#   vpc_id      = data.terraform_remote_state.vpc.vpc_id
  vpc_id = "vpc-2332ab48"

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["http"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "@@@@@@@@@@User-service ports@@@@@@"
      cidr_blocks = "0.0.0.0/16"
    },
  ]
}

module "ecs-instance-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ecs-instance-sg"
  description = "ecs capacity provider ec2 instance security group"
#   vpc_id      = data.terraform_remote_state.vpc.vpc_id
  vpc_id = "vpc-2332ab48"

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "@@@@@@@@@@User-service ports@@@@@@"
      cidr_blocks = "10.10.0.0/16"
    },
  ]
}


