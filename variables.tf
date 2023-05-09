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

variable "service_endpoints" {
  type        = string
  description = "Types of the service endpoints to be set for the Key Protect instance. Possible values are 'public', 'private', or 'public-and-private'"
  default     = "public-and-private"

  validation {
    condition     = can(regex("public|public-and-private|private", var.service_endpoints))
    error_message = "Valid values for service_endpoints are 'public', 'public-and-private', and 'private'."
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

variable "metrics_enabled" {
  type        = bool
  description = "If set to true, Key Protect enables metrics on the Key Protect instance. In order to view metrics, you will need a Monitoring (Sysdig) instance that is located in the same region as the Key Protect instance. Once you provision the Monitoring instance, you will need to enable platform metrics."
  default     = true
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the resources created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\", see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits for more details"
  }
}
