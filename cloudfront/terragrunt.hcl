include "root" {
  path = find_in_parent_folders()
}

# network, sg, elb 생성 후 ecs 생성
dependencies {
  paths = ["../network", "../sg", "../elb", "../ecs"]
}


