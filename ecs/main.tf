data "terraform_remote_state" "ecr" {
   backend = "s3"
  config = {
    bucket = "sh-terraform-backend-apn2"
    key = "ecr/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

locals {
  env = "terraform"
}

module "webs_task_def" {
  source = "../module/ecs/task_definition"
  is_fargate = false
  family = "${var.project_name}-webs"
  cpu = "1024"
  mem = "2048"
  container_cpu = "512"
  container_mem = "1024"
  network_mode = "bridge"
  container_name = "cats"
  container_url = "${data.terraform_remote_state.ecr.outputs.webs-ecr}"
  containerport = "80"
  hostport = "80"
}

module "cats_task_def" {
  source = "../module/ecs/task_definition"
  is_fargate = false
  family = "${var.project_name}-cats"
  cpu = "1024"
  mem = "2048"
  container_cpu = "512"
  container_mem = "1024"
  network_mode = "bridge"
  container_name = "cats"
  container_url = "${data.terraform_remote_state.ecr.outputs.cats-ecr}"
  containerport = "80"
  hostport = "0"
}