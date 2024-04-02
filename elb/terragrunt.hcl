include "root" {
  path = find_in_parent_folders()
}

# network, sg 이후 terragrunt 실행
dependencies {
  paths = ["../network", "../sg"]
}

