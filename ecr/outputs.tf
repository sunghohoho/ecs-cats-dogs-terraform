output "cats-ecr" {
    description = "cats-ecr"
    value = module.public_ecr_cats.repository_url
}

output "dogs-ecr" {
    description = "dogs-ecr"
    value = module.public_ecr_dogs.repository_url
}

output "webs-ecr" {
    description = "webs-ecr"
    value = module.public_ecr_webs.repository_url
}