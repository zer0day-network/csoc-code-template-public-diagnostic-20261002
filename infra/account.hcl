locals {
  appzone_name               = get_env("FACTORY_APPZONE_NAME")
  tenant_id                  = get_env("ARM_TENANT_ID")
  resources_subscription_id  = get_env("ARM_SUBSCRIPTION_ID")
  location                   = get_env("FACTORY_LOCATION", "westeurope")
  state_storage_account_name = get_env("FACTORY_STATE_STORAGE_ACCOUNT")
}