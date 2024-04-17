output "elb_target_arn" {
    value = aws_lb_target_group.webs.arn
}

output "elb_target_web_arn" {
    value = aws_lb_target_group.cats.arn
}

output "elb_target_fargate_arn" {
    value = aws_lb_target_group.fargate.arn
}

output "elb-dns" {
    value = aws_lb.this.dns_name
}
