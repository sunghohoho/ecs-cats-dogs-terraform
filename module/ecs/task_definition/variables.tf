variable "family" {
  description = "태스크 정의 패밀리 유형"
  type        = string
}

variable "cpu" {
  description = "태스크 cpu"
  type        = number
}

variable "mem" {
  description = "태스크 mem"
  type        = number
}

variable "container_cpu" {
  description = "컨테이너 cpu"
  type        = number
}

variable "network_mode" {
  description = "태스크의 네트워크 모드"
  type        = string
}

variable "container_mem" {
  description = "컨테이너 메모리 할당, 숫자형식의 값 필요"
  type        = number
}

variable "container_name" {
  description = "컨테이너 이름"
  type        = string
}

variable "container_url" {
  description = "컨테이너 url"
  type        = string
}

variable "containerport" {
  description = "컨테이너 포트, 숫자형식의 값 필요"
  type        = number
  default = "80"
}

variable "hostport" {
  description = "컨테이너 인스턴스의 호스트 포트, 숫자형식의 값 필요"
  type        = number
  default = "0"
}