include "root" {
  path = find_in_parent_folders()
}

# network 폴더의 terragrunt가 실행된 후 sg 폴더의 terragrunt 실행
dependency "vpc" {
  config_path = "../network"

  mock_outputs = {
    vpc_id = "temporary-dummy"
  }
}
