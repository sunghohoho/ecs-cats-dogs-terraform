data "terraform_remote_state" "cats-ecr" {
   backend = "s3"
  config = {
    bucket = "sh-terraform-backend-apn2"
    key = "ecr/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

module "cats_task_def" {
  source = "../module/ecs/task_definition"

  family = "cats"
  cpu = "1"
  mem = "2"
  container_cpu = "1"
  container_mem = "1"
  network_mode = "bridge"
  container_name = "cats"
  container_url = "${data.terraform_remote_state.cats-ecr.outputs.cats-ecr}"
  containerport = "80"
}