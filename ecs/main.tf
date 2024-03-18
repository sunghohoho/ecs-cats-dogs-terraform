# ecr 값 가져오기
data "terraform_remote_state" "ecr" {
   backend = "s3"
  config = {
    bucket = "sh-terraform-backend-apn2"
    key = "ecr/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

data "terraform_remote_state" "vpc" {
   backend = "s3"
  config = {
    bucket = "sh-terraform-backend-apn2"
    key = "network/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

data "terraform_remote_state" "elb" {
   backend = "s3"
  config = {
    bucket = "sh-terraform-backend-apn2"
    key = "elb/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

data "terraform_remote_state" "sg" {
   backend = "s3"
  config = {
    bucket = "sh-terraform-backend-apn2"
    key = "sg/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

# cluster 생성
module "cluster" {
  source = "../module/ecs/cluster"

  project_name = var.project_name
  is_ec2_provider = true

  max_size = 4
  min_size = 2
  desire_size = 2
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_id
}

# module "cluster2" {
#   source = "../module/ecs/cluster"

#   project_name = "${var.project_name}-fargate"
#   is_ec2_provider = false

#   # max_size = 4
#   # min_size = 2
#   # desire_size = 2
#   # subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_id
# }

# web 컨테이너 definition
# module "webs_task_def" {
#   source = "../module/ecs/task_definition"
#   is_fargate = false
#   family = "${var.project_name}-webs"
#   cpu = "1024"
#   mem = "2048"
#   container_cpu = "512"
#   container_mem = "1024"
#   network_mode = "bridge"
#   container_name = "webs_container"
#   container_url = "${data.terraform_remote_state.ecr.outputs.webs-ecr}"
#   containerport = "80"
#   hostport = "80"
# }

# # cats 컨테이니ㅓ defnition
# module "cats_task_def" {
#   source = "../module/ecs/task_definition"
#   is_fargate = false
#   family = "${var.project_name}-cats"
#   cpu = "1024"
#   mem = "2048"
#   container_cpu = "512"
#   container_mem = "1024"
#   network_mode = "bridge"
#   container_name = "cats_container"
#   container_url = "${data.terraform_remote_state.ecr.outputs.cats-ecr}"
#   containerport = "80"
#   hostport = "0"
# }

# # dogs 컨테이너 defnition
# module "dogs_task_def" {
#   source = "../module/ecs/task_definition"
#   is_fargate = true
#   family = "${var.project_name}-dogs"
#   cpu = "1024"
#   mem = "2048"
#   container_cpu = "512"
#   container_mem = "1024"
#   network_mode = "awsvpc"
#   container_name = "dogs_container"
#   container_url = "${data.terraform_remote_state.ecr.outputs.dogs-ecr}"
#   containerport = "80"
#   hostport = "0"
# }

# module "webs-svc" {
#   source = "../module/ecs/service"
#   name = "${var.project_name}-web-svc"
#   cluster = module.cluster.cluster_name 
#   task_definition = module.webs_task_def.task_def_arn 
#   launch_type = "EC2"
#   is_fargate = false

#   desired_count = 2

#   target_group = data.terraform_remote_state.elb.outputs.elb_target_arn

#   container_name = "webs_container"
#   container_port = 80

#   subnet = data.terraform_remote_state.vpc.outputs.private_subnet_id
# }
