output "cluster_name" {
    value = aws_ecs_cluster.this.name
}

output "ec2_asg_arn" {
    value = aws_autoscaling_group.this[0].name
}