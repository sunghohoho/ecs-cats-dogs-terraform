generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "ap-northeast-2"
}
EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "sh-terraform-backend-apn2"

    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-northeast-2"
  }
}