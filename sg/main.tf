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

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.vote_service_sg.security_group_id
    }
  ]
}

# module "ecs-instance-sg" {
#   source = "terraform-aws-modules/security-group/aws"

#   name        = "ecs-instance-sg"
#   description = "ecs capacity provider ec2 instance security group"
# #   vpc_id      = data.terraform_remote_state.vpc.vpc_id
#   vpc_id = "vpc-2332ab48"

#   ingress_cidr_blocks      = ["0.0.0.0/0"]
#   ingress_rules            = ["https-443-tcp"]
#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 0
#       to_port     = 65535
#       protocol    = "tcp"
#       description = "@@@@@@@@@@User-service ports@@@@@@"
#       cidr_blocks = "10.10.0.0/16"
#     },
#   ]
# }

module "vote_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "user-service"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id = "vpc-2332ab48"

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
}


