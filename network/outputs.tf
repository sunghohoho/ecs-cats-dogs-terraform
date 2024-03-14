output "vpc_id" {
    description = "vpc_id"
    value = module.vpc.vpc_id
}

output "private_subnet_id" {
    description = "private subnet id"
    value = module.vpc.private_subnets
}

output "public_subnet_id" {
    description = "public subnet id"
    value = module.vpc.public_subnets
}