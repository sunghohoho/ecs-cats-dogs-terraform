# Default Region
provider "aws" {
    region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "sh-terraform-backend-apn2"
    key = "iam/terraform.tfstate"
    region = "ap-northeast-2"
  }
}