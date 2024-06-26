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

# bastion
resource "aws_instance" "this" {
  ami = "ami-0ac9b8202b45eeb08"

  key_name = "test"
  instance_type = "t3.micro"
  subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_id[0]
  associate_public_ip_address = true
  security_groups = [data.terraform_remote_state.sg.outputs.bastion-sg]
  tags = {
    Name = "${var.project_name}-bastion"
    Terraform = true
  }
}

# cluster 생성
module "cluster" {
  source = "../module/ecs/cluster"

  project_name = var.project_name
  is_ec2_provider = true

  max_size = 2
  min_size = 2
  desire_size = 2
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_id
}

# web 컨테이너 definition
module "webs_task_def" {
  source = "../module/ecs/task_definition"
  is_fargate = false
  family = "${var.project_name}-webs"
  cpu = "1024"
  mem = "512"
  container_cpu = "512"
  container_mem = "512"
  network_mode = "bridge"
  container_name = "webs_container"
  container_url = "${data.terraform_remote_state.ecr.outputs.webs-ecr}"
  containerport = "80"
  hostport = "80"
}

# cats 컨테이니ㅓ defnition
module "cats_task_def" {
  source = "../module/ecs/task_definition"
  is_fargate = false
  family = "${var.project_name}-cats"
  cpu = "1024"
  mem = "512"
  container_cpu = "512"
  container_mem = "512"
  network_mode = "bridge"
  container_name = "cats_container"
  container_url = "${data.terraform_remote_state.ecr.outputs.cats-ecr}"
  containerport = "80"
  hostport = "0"
}

# dogs 컨테이너 defnition
module "dogs_task_def" {
  source = "../module/ecs/task_definition"
  is_fargate = true
  family = "${var.project_name}-dogs"
  cpu = "1024"
  mem = "2048"
  container_cpu = "512"
  container_mem = "1024"
  network_mode = "awsvpc"
  container_name = "dogs_container"
  container_url = "${data.terraform_remote_state.ecr.outputs.dogs-ecr}"
  containerport = "80"
  hostport = "0"
}

resource "aws_autoscaling_attachment" "ecs-svc-alb-ec2" {
  autoscaling_group_name = module.cluster.ec2_asg_arn
  lb_target_group_arn    = data.terraform_remote_state.elb.outputs.elb_target_arn

  depends_on = [ module.cluster ]
}

module "webs-svc" {
  source = "../module/ecs/service"
  name = "${var.project_name}-web-svc"
  cluster = module.cluster.cluster_name 
  task_definition = module.webs_task_def.task_def_arn 
  launch_type = "EC2"
  is_fargate = false

  desired_count = 2

  target_group = data.terraform_remote_state.elb.outputs.elb_target_arn

  container_name = "webs_container"
  container_port = 80

  depends_on = [ aws_autoscaling_attachment.ecs-svc-alb-ec2 ]
}

module "cats-svc" {
  source = "../module/ecs/service"
  name = "${var.project_name}-cat-svc"
  cluster = module.cluster.cluster_name 
  task_definition = module.cats_task_def.task_def_arn 
  launch_type = "EC2"
  is_fargate = false

  desired_count = 2

  target_group = data.terraform_remote_state.elb.outputs.elb_target_web_arn

  container_name = "cats_container"
  container_port = 80

  depends_on = [ aws_autoscaling_attachment.ecs-svc-alb-ec2 ]
}

module "dogs-svc" {
  source = "../module/ecs/service"
  name = "${var.project_name}-dog-svc"
  cluster = module.cluster.cluster_name 
  task_definition = module.dogs_task_def.task_def_arn 
  launch_type = "FARGATE"
  is_fargate = true

  desired_count = 2

  target_group = data.terraform_remote_state.elb.outputs.elb_target_fargate_arn

  container_name = "dogs_container"
  container_port = 80
  subnet = data.terraform_remote_state.vpc.outputs.private_subnet_id
  sg = [data.terraform_remote_state.sg.outputs.ecs-fargate-sg]
}

output "elb_dns" {
  value = data.terraform_remote_state.elb.outputs.elb-dns
}