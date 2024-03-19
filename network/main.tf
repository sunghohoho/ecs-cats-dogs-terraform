# VPC 생성 모듈
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-vpc"
  cidr = "10.100.0.0/16"

  azs = ["ap-northeast-2a","ap-northeast-2c"]
  private_subnets = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24", "10.100.4.0/24"]
  public_subnets  = ["10.100.101.0/24", "10.100.102.0/24"]

  enable_nat_gateway  = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "${var.project_name}"
  }

}
