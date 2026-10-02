# Workload Units

The factory adds reviewed workload units here for each service and registers them
in the corresponding `infra/dev/terragrunt.stack.hcl` and
`infra/prd/terragrunt.stack.hcl` files. No units are active in the base template.

Use pinned releases from the organization's Terragrunt catalog. Do not copy
service-specific resource names, application settings, principal IDs or state
containers from another service. Each unit includes the shared `infra/root.hcl`.

Before deployment, the reviewed AppZone outputs must supply:

| Variable | Value |
| --- | --- |
| `FACTORY_APPZONE_NAME` | Service AppZone name |
| `ARM_TENANT_ID` | Deployment tenant |
| `ARM_SUBSCRIPTION_ID` | Workload subscription |
| `ARM_CLIENT_ID` | Environment deployment UAMI client ID |
| `FACTORY_LOCATION` | Azure location; defaults to westeurope |
| `FACTORY_STATE_STORAGE_ACCOUNT` | Platform state storage account |
| `FACTORY_STATE_CONTAINER` | Environment-specific state container |
| `FACTORY_RESOURCE_GROUP_NAME` | Environment-specific resource group |

Deployment workflows must use reviewed GitHub Environments and OIDC. The default
mapping is GitHub `staging` to AppZone `dev`, and `production` to `prd`. Use the
repository's actual OIDC subject, including immutable owner/repository IDs where
enabled. Never infer federation solely from repository names. Authentication and
state access must be provisioned before activating any deployment workflow.