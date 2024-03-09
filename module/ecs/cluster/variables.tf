variable "project_name" {
  description = "클러스터 이름"
  type        = string
}

variable "is_ec2_provider" {
  description = "클러스터 이름"
  type        = bool
}

variable "subnet_id" {
  description = "subnet_id"
  type        = list(string)
}

variable "max_size" {
  description = "인스턴스 최대 갯수"
  type        = number
}

variable "min_size" {
  description = "인스턴스 최소 갯수"
  type        = number
}

variable "desire_size" {
  description = "인스턴스 희망 값"
  type        = number
}

