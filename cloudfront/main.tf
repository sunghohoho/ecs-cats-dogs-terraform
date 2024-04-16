data "terraform_remote_state" "alb" {
   backend = "s3"
  config = {
    bucket = "sh-terraform-backend-apn2"
    key = "elb/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

data "terraform_remote_state" "acm" {
   backend = "s3"
  config = {
    bucket = "sh-terraform-backend-apn2"
    key = "acm/terraform.tfstate"
    region = "ap-northeast-2"
  }
}