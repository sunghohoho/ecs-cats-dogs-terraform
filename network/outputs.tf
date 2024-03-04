output "vpc_id" {
    description = "vpc_id"
    value = module.vpc.default_vpc_id
}

output "private_subnet_id" {
    description = "private subnet id"
    value = module.vpc.private_subnets
}