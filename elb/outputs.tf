output "elb_target_arn" {
    value = aws_lb_target_group.this.arn
}

output "elb_target_fargate_arn" {
    value = aws_lb_target_group.fargate.arn
}