variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example"
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example. If unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "Optional list of access management tags to add to the Key Protect instance"
  default     = []
}

variable "dedicated_crypto_units" {
  type        = number
  description = "The number of crypto units to allocate for the dedicated Key Protect instance."
  default     = 2
}

variable "dedicated_use_private_endpoint" {
  type        = bool
  description = "Set to true to use the private endpoint for initializing the dedicated Key Protect instance."
  default     = false
}

variable "dedicated_signature_key" {
  type = object({
    filepath   = string
    passphrase = string
    owner      = optional(string, "")
  })
  sensitive   = true
  description = "Signature key configuration for initializing the dedicated Key Protect instance."
  default = {
    filepath   = "kp-dedicated-signature.key"
    passphrase = ""
    owner      = "ADMIN"
  }
}

variable "dedicated_master_key" {
  type = object({
    keysharefile = list(object({
      filepath   = string
      passphrase = string
    }))
    keyname = string
  })
  sensitive   = true
  description = "Master key configuration for initializing the dedicated Key Protect instance. At least 2 key share files are required."
  default = {
    keysharefile = [
      { filepath = "kp-dedicated-mbk-1.key", passphrase = "" },
      { filepath = "kp-dedicated-mbk-2.key", passphrase = "" }
    ]
    keyname = "mbkkey"
  }
}
