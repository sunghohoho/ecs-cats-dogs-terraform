# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket = "sh-terraform-backend-apn2"
    key    = "cloudfront/terraform.tfstate"
    region = "ap-northeast-2"
  }
}