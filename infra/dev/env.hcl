locals {
  environment          = "dev"
  github_environment   = "staging"
  resource_group_name  = get_env("FACTORY_RESOURCE_GROUP_NAME")
  state_container_name = get_env("FACTORY_STATE_CONTAINER")
}