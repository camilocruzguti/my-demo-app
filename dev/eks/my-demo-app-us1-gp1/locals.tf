locals {
  environment_name = "staging"
  tags = {
    ops_env        = "${local.environment_name}",
    ops_managed_by = "terraform",
    ops_owners     = "cacruz",
  }
}