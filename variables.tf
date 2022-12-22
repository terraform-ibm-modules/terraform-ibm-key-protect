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
  description = "Set to true to enable metrics on the Key Protect instance. In order to view metrics, you will need a Monitoring (Sysdig) instance that is located in the same region as the Key Protect instance. Once you provision the Monitoring instance, you will need to enable platform metrics."
  default     = true
}
