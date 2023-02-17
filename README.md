# Key Protect module
[![Stable (Adopted)](https://img.shields.io/badge/Status-Stable%20(Adopted)-yellowgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![Build Status](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect/actions/workflows/ci.yml)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-key-protect?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-key-protect/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

This module supports:
- Creating a [Key Protect instance](https://cloud.ibm.com/docs/key-protect?topic=key-protect-about)
- Enabling a [rotation policy](https://cloud.ibm.com/docs/key-protect?topic=key-protect-set-rotation-policy) for the instance
- Enabling a [dual authorization policy](https://cloud.ibm.com/docs/key-protect?topic=key-protect-manage-dual-auth) for the instance
- Enabling a [metrics policy](https://cloud.ibm.com/docs/key-protect?topic=key-protect-manage-monitor-metrics) for the instance
- Enabling a [key create and import access policy](https://cloud.ibm.com/docs/key-protect?topic=key-protect-manage-keyCreateImportAccess) for the instance

## Usage

```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX"
  region           = "us-south"
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
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.49.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ibm_kms_instance_policies.key_protect_instance_policies](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/kms_instance_policies) | resource |
| [ibm_resource_instance.key_protect_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dual_auth_delete_enabled"></a> [dual\_auth\_delete\_enabled](#input\_dual\_auth\_delete\_enabled) | If set to true, Key Protect enables a dual authorization policy on the instance. Note: Once the dual authorization policy is set on the instance, it cannot be reverted. An instance with dual authorization policy enabled cannot be destroyed using Terraform. | `bool` | `false` | no |
| <a name="input_key_create_import_access_enabled"></a> [key\_create\_import\_access\_enabled](#input\_key\_create\_import\_access\_enabled) | If set to true, Key Protect enables a key create import access policy on the instance | `bool` | `true` | no |
| <a name="input_key_create_import_access_settings"></a> [key\_create\_import\_access\_settings](#input\_key\_create\_import\_access\_settings) | Key create import access policy settings to configure if var.enable\_key\_create\_import\_access\_policy is true. For more info see https://cloud.ibm.com/docs/key-protect?topic=key-protect-manage-keyCreateImportAccess | <pre>object({<br>    create_root_key     = optional(bool, true)<br>    create_standard_key = optional(bool, true)<br>    import_root_key     = optional(bool, true)<br>    import_standard_key = optional(bool, true)<br>    enforce_token       = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_key_protect_name"></a> [key\_protect\_name](#input\_key\_protect\_name) | The name to give the Key Protect instance that will be provisioned | `string` | n/a | yes |
| <a name="input_metrics_enabled"></a> [metrics\_enabled](#input\_metrics\_enabled) | If set to true, Key Protect enables metrics on the Key Protect instance. In order to view metrics, you will need a Monitoring (Sysdig) instance that is located in the same region as the Key Protect instance. Once you provision the Monitoring instance, you will need to enable platform metrics. | `bool` | `true` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | Plan for the Key Protect instance. Currently only 'tiered-pricing' is supported | `string` | `"tiered-pricing"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the Key Protect instance will be provisioned | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Resource Group ID where the Key Protect instance will be provisioned | `string` | n/a | yes |
| <a name="input_rotation_enabled"></a> [rotation\_enabled](#input\_rotation\_enabled) | If set to true, Key Protect enables a rotation policy on the Key Protect instance. | `bool` | `true` | no |
| <a name="input_rotation_interval_month"></a> [rotation\_interval\_month](#input\_rotation\_interval\_month) | Specifies the key rotation time interval in months. Must be between 1 and 12 inclusive. | `number` | `1` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | Types of the service endpoints to be set for the Key Protect instance. Possible values are 'public', 'private', or 'public-and-private' | `string` | `"public-and-private"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to associate with the Key Protect instance | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_protect_guid"></a> [key\_protect\_guid](#output\_key\_protect\_guid) | GUID of the Key Protect instance |
| <a name="output_key_protect_id"></a> [key\_protect\_id](#output\_key\_protect\_id) | ID of the Key Protect instance |
| <a name="output_key_protect_instance_policies"></a> [key\_protect\_instance\_policies](#output\_key\_protect\_instance\_policies) | Instance Polices of the Key Protect instance |
| <a name="output_key_protect_name"></a> [key\_protect\_name](#output\_key\_protect\_name) | Name of the Key Protect instance |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- BEGIN CONTRIBUTING HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- Source for this readme file: https://github.com/terraform-ibm-modules/common-dev-assets/tree/main/module-assets/ci/module-template-automation -->
<!-- END CONTRIBUTING HOOK -->
