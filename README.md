# Key Protect module
[![Stable (Adopted)](https://img.shields.io/badge/Status-Stable%20(Adopted)-yellowgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![Build Status](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect/actions/workflows/ci.yml)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-key-protect?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

This module supports:
- Creating a [Key Protect instance](https://cloud.ibm.com/docs/key-protect?topic=key-protect-about)
- Enabling [monitoring metrics](https://cloud.ibm.com/docs/key-protect?topic=key-protect-manage-monitor-metrics) for the instance

There is currently an [enhancement request](https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4256) open with the IBM terraform provider to support enabling metrics. Until then, this module uses the restapi provider to enable metrics.

## Usage

```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX"
  region           = "us-south"
}

# Retrieve IAM access token (required for restapi provider)
data "ibm_iam_auth_token" "token_data" {
}

provider "restapi" {
  uri                   = "https:"
  write_returns_object  = false
  create_returns_object = false
  debug                 = false
  headers = {
    Authorization    = data.ibm_iam_auth_token.token_data.iam_access_token
    Bluemix-Instance = module.key_protect_module.key_protect_guid
    Content-Type     = "application/vnd.ibm.kms.policy+json"
  }
}

module "key_protect_module" {
  # Replace "main" with a GIT release version to lock into a specific release
  source            = "git::https://github.com:terraform-ibm-modules/terraform-ibm-key-protect.git?ref=main"
  key_protect_name  = "my-key-protect-instance"
  resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  region            = "us-south"
}
```
## Required IAM access policies

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **Key Protect** service
        - `Editor` platform access
        - `Manager` platform access (required to enable metrics)

<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [ Default example](examples/default)
<!-- END EXAMPLES HOOK -->

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.48.0 |
| <a name="requirement_restapi"></a> [restapi](#requirement\_restapi) | >= 1.18.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ibm_resource_instance.key_protect_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [restapi_object.enable_metrics](https://registry.terraform.io/providers/Mastercard/restapi/latest/docs/resources/object) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key_protect_name"></a> [key\_protect\_name](#input\_key\_protect\_name) | The name to give the Key Protect instance that will be provisioned | `string` | n/a | yes |
| <a name="input_metrics_enabled"></a> [metrics\_enabled](#input\_metrics\_enabled) | Set to true to enable metrics on the Key Protect instance. In order to view metrics, you will need a Monitoring (Sysdig) instance that is located in the same region as the Key Protect instance. Once you provision the Monitoring instance, you will need to enable platform metrics. | `bool` | `true` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | Plan for the Key Protect instance. Currently only 'tiered-pricing' is supported | `string` | `"tiered-pricing"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the Key Protect instance will be provisioned | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Resource Group ID where the Key Protect instance will be provisioned | `string` | n/a | yes |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | Types of the service endpoints to be set for the Key Protect instance. Possible values are 'public', 'private', or 'public-and-private' | `string` | `"public-and-private"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to associate with the Key Protect instance | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_protect_guid"></a> [key\_protect\_guid](#output\_key\_protect\_guid) | GUID of the Key Protect instance |
| <a name="output_key_protect_id"></a> [key\_protect\_id](#output\_key\_protect\_id) | ID of the Key Protect instance |
| <a name="output_key_protect_name"></a> [key\_protect\_name](#output\_key\_protect\_name) | Name of the Key Protect instance |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- BEGIN CONTRIBUTING HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- Source for this readme file: https://github.com/terraform-ibm-modules/common-dev-assets/tree/main/module-assets/ci/module-template-automation -->
<!-- END CONTRIBUTING HOOK -->
