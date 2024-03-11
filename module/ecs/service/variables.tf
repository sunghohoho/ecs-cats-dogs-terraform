variable "name" {
  description = "svc Name"
  type        = string
}

variable "cluster" {
  description = "cluster Name"
  type        = string
}

variable "task_definition" {
  description = "task_definition"
  type        = string
}

variable "desired_count" {
  description = "Project Name"
  type        = number
}

variable "target_group" {
  description = "task 수"
  type        = string
}

variable "container_name" {
  description = "컨테이너 Name"
  type        = string
}

variable "container_port" {
  description = "Project Name"
  type        = string
}

variable "subnet" {
  description = "Project Name"
  type        = list(string)
}

# variable "svcsg" {
#   description = "Project Name"
#   type        = string
# }