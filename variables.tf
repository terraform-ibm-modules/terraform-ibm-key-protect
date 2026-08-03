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

variable "resource_tags" {
  type        = list(string)
  description = "Add user resource tags to the Key Protect instance to organize, track, and manage costs. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#tag-types)."
  default     = []
  validation {
    condition     = alltrue([for tag in var.resource_tags : can(regex("^[A-Za-z0-9 _\\-.:]{1,128}$", tag))])
    error_message = "Each resource tag must be 128 characters or less and may contain only A-Z, a-z, 0-9, spaces, underscore (_), hyphen (-), period (.), and colon (:)."
  }
}

variable "allowed_network" {
  type        = string
  description = "Types of the allowed networks to be set for the Key Protect instance. Possible values are 'private-only' or 'public-and-private'. This can be set for only 'tiered-pricing' and 'cross-region-resiliency' plans."
  default     = "public-and-private"

  validation {
    condition     = can(regex("public-and-private|private-only", var.allowed_network))
    error_message = "Valid values for allowed_network are 'public-and-private', and 'private-only'."
  }
}

variable "plan" {
  type        = string
  description = "Plan for the Key Protect instance. Valid plans are 'tiered-pricing' and 'cross-region-resiliency', for more information on these plans see [Key Protect pricing plan](https://cloud.ibm.com/docs/key-protect?topic=key-protect-pricing-plan)."
  default     = "tiered-pricing"

  validation {
    condition     = contains(["tiered-pricing", "cross-region-resiliency", "dedicated"], var.plan)
    error_message = "`plan` must be one of: 'tiered-pricing', 'cross-region-resiliency' and 'dedicated'."
  }

  validation {
    condition = (
      var.plan == "tiered-pricing" ||

      (var.plan == "cross-region-resiliency" &&
        contains(["us-south", "eu-de", "jp-tok"], var.region)
      ) ||

      (var.plan == "dedicated" &&
        contains(["us-south", "eu-de", "us-east"], var.region)
      )
    )
    error_message = "Invalid plan/region combination. 'cross-region-resiliency' supports: us-south, eu-de, jp-tok. 'dedicated' supports: us-south, eu-de, us-east."
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
  description = "Add access management tags to the Key Protect instance to control access. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create-access-console)."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\", see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits for more details"
  }
}

##############################################################################
# Dedicated Key Protect Initialization
##############################################################################

variable "dedicated_crypto_units" {
  type        = number
  description = "The number of crypto units to allocate for the dedicated Key Protect instance. Only used when `plan` is `dedicated`."
  default     = 2

  validation {
    condition     = var.dedicated_crypto_units >= 2 && var.dedicated_crypto_units <= 3
    error_message = "The `dedicated_crypto_units` value must be 2 or 3."
  }
}

variable "dedicated_use_private_endpoint" {
  type        = bool
  description = "If set to true, the private endpoint is used to initialize the dedicated Key Protect instance. Only used when `plan` is `dedicated`."
  default     = false
}

variable "dedicated_signature_key" {
  type = object({
    filepath   = string
    passphrase = string
    owner      = optional(string, "")
  })
  sensitive   = true
  description = "Signature key configuration used to initialize the dedicated Key Protect instance. `filepath` is the path to the signature key file (created if it does not exist), `passphrase` secures the key, and `owner` optionally identifies the administrator. Only used when `plan` is `dedicated`."
  default = {
    filepath   = "kp-dedicated-signature.key"
    passphrase = ""
    owner      = "ADMIN"
  }
}

variable "dedicated_master_key_keyname" {
  type        = string
  sensitive   = true
  description = "The name of the master key used to initialize the dedicated Key Protect instance. Must be 8 characters or less. Only used when `plan` is `dedicated`."
  default     = "mbkkey"
}

variable "dedicated_master_key_share_1_filepath" {
  type        = string
  sensitive   = true
  description = "Filepath for key share 1 of the master key used to initialize the dedicated Key Protect instance. Only used when `plan` is `dedicated`."
  default     = "kp-dedicated-mbk-1.key"
}

variable "dedicated_master_key_share_1_passphrase" {
  type        = string
  sensitive   = true
  description = "Passphrase for key share 1 of the master key used to initialize the dedicated Key Protect instance. Only used when `plan` is `dedicated`."
  default     = ""
}

variable "dedicated_master_key_share_2_filepath" {
  type        = string
  sensitive   = true
  description = "Filepath for key share 2 of the master key used to initialize the dedicated Key Protect instance. Only used when `plan` is `dedicated`."
  default     = "kp-dedicated-mbk-2.key"
}

variable "dedicated_master_key_share_2_passphrase" {
  type        = string
  sensitive   = true
  description = "Passphrase for key share 2 of the master key used to initialize the dedicated Key Protect instance. Only used when `plan` is `dedicated`."
  default     = ""
}

variable "dedicated_master_key_share_3_filepath" {
  type        = string
  sensitive   = true
  description = "Filepath for key share 3 of the master key used to initialize the dedicated Key Protect instance. Only used when `dedicated_crypto_units` is 3. Only used when `plan` is `dedicated`."
  default     = null
}

variable "dedicated_master_key_share_3_passphrase" {
  type        = string
  sensitive   = true
  description = "Passphrase for key share 3 of the master key used to initialize the dedicated Key Protect instance. Only used when `dedicated_crypto_units` is 3. Only used when `plan` is `dedicated`."
  default     = null
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
    operations = optional(list(object({
      api_types = list(object({
        api_type_id = string
      }))
    })))
  }))
  description = "The context-based restrictions rule to create. Only one rule is allowed."
  default     = []
  # Validation happens in the rule module
  validation {
    condition     = length(var.cbr_rules) <= 1
    error_message = "Only one CBR rule is allowed."
  }
}
