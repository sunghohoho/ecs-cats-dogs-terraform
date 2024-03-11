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

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
#   vpc_id      = data.terraform_remote_state.vpc.vpc_id
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



