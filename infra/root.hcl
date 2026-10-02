locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

remote_state {
  backend = "azurerm"
  config = {
    container_name       = local.environment_vars.locals.state_container_name
    storage_account_name = local.account_vars.locals.state_storage_account_name
    key                  = "${path_relative_to_include()}/tf.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
    snapshot             = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71, < 5.0.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.4"
    }
  }
}

provider "azurerm" {
  subscription_id     = "${local.account_vars.locals.resources_subscription_id}"
  tenant_id           = "${local.account_vars.locals.tenant_id}"
  storage_use_azuread  = true
  use_oidc            = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

provider "azuread" {
  tenant_id = "${local.account_vars.locals.tenant_id}"
  use_oidc  = true
}

provider "azapi" {
  subscription_id = "${local.account_vars.locals.resources_subscription_id}"
  tenant_id       = "${local.account_vars.locals.tenant_id}"
  use_oidc        = true
}
EOF
}

inputs = merge(
  local.account_vars.locals,
  local.environment_vars.locals,
  {
    tags = {
      appzone     = local.account_vars.locals.appzone_name
      environment = local.environment_vars.locals.environment
    }
  }
)