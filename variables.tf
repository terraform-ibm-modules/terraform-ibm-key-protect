##############################################################################
# Input Variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "Resource Group ID where the Key Protect instance will be provisioned"
}

variable "region" {
  type        = string
  description = "Region where the Key Protect instance will be provisioned"
}

variable "key_protect_name" {
  type        = string
  description = "The name to give the Key Protect instance that will be provisioned"
}

variable "tags" {
  type        = list(string)
  description = "List of tags to associate with the Key Protect instance"
  default     = []
}

variable "allowed_network" {
  type        = string
  description = "Types of the allowed networks to be set for the Key Protect instance. Possible values are 'private-only' or 'public-and-private'"
  default     = "public-and-private"

  validation {
    condition     = can(regex("public-and-private|private-only", var.allowed_network))
    error_message = "Valid values for allowed_network are 'public-and-private', and 'private-only'."
  }
}

variable "plan" {
  type        = string
  description = "Plan for the Key Protect instance. Currently only 'tiered-pricing' is supported"
  default     = "tiered-pricing"

  validation {
    condition     = can(regex("^tiered-pricing$", var.plan))
    error_message = "Currently the only supported value for plan is 'tiered-pricing'."
  }
}

variable "rotation_enabled" {
  type        = bool
  description = "If set to true, Key Protect enables a rotation policy on the Key Protect instance."
  default     = true
}

variable "rotation_interval_month" {
  type        = number
  description = "Specifies the key rotation time interval in months. Must be between 1 and 12 inclusive."
  default     = 1

  validation {
    condition     = (var.rotation_interval_month >= 1) && (var.rotation_interval_month <= 12)
    error_message = "The rotation_interval_month must be between 1 and 12 inclusive."
  }
}

variable "dual_auth_delete_enabled" {
  type        = bool
  description = "If set to true, Key Protect enables a dual authorization policy on the instance. Note: Once the dual authorization policy is set on the instance, it cannot be reverted. An instance with dual authorization policy enabled cannot be destroyed using Terraform."
  default     = false
}

variable "metrics_enabled" {
  type        = bool
  description = "If set to true, Key Protect enables metrics on the Key Protect instance. In order to view metrics, you will need a Monitoring (Sysdig) instance that is located in the same region as the Key Protect instance. Once you provision the Monitoring instance, you will need to enable platform metrics."
  default     = true
}

variable "key_create_import_access_enabled" {
  type        = bool
  description = "If set to true, Key Protect enables a key create import access policy on the instance"
  default     = true
}

variable "key_create_import_access_settings" {
  type = object({
    create_root_key     = optional(bool, true)
    create_standard_key = optional(bool, true)
    import_root_key     = optional(bool, true)
    import_standard_key = optional(bool, true)
    enforce_token       = optional(bool, false)
  })
  description = "Key create import access policy settings to configure if var.enable_key_create_import_access_policy is true. For more info see https://cloud.ibm.com/docs/key-protect?topic=key-protect-manage-keyCreateImportAccess"
  default     = {}
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Key Protect instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\", see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits for more details"
  }
}

##############################################################
# Context-based restriction (CBR)
##############################################################

variable "cbr_rules" {
  type = list(object({
    description = string
    account_id  = string
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
    # operations = optional(list(object({
    #   api_types = list(object({
    #     api_type_id = string
    #   }))
    # })))
  }))
  description = "(Optional, list) List of context-based restrictions rules to create"
  default     = []
  # Validation happens in the rule module
}
