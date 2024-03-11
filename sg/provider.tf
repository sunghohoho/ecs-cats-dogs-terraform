# Default Region
provider "aws" {
  region = var.default_region
}

terraform {
  backend "s3" {
    bucket = "sh-terraform-backend-apn2"
    key = "sg/terraform.tfstate"
    region = "ap-northeast-2"
  }
}