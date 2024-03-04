#public ecr 생성
module "public_ecr_cats" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "${var.project_name}-cats"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = "${var.project_name}"
    Repo = "cats"
  }
}

module "public_ecr_dogs" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "${var.project_name}-dogs"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = "${var.project_name}"
    Repo = "dogs"
  }
}

