output "ecs-svc-alb-sg" {
    description = "ecs svc alb sg"
    value = module.ecs-svc-alb-sg.security_group_id
}

output "ecs-ec2-instance-sg" {
    value = module.ecs-ec2-instance-sg.security_group_id
}

output "ecs-fargate-sg" {
    value = module.ecs-ec2-instance-sg.security_group_id
}