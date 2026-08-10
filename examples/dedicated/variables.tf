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

variable "dedicated_signature_key_filepath" {
  type        = string
  sensitive   = true
  description = "Filepath for the signature key used to initialize the dedicated Key Protect instance."
  default     = "kp-dedicated-signature.key"
}

variable "dedicated_signature_key_passphrase" {
  type        = string
  sensitive   = true
  description = "Passphrase for the signature key used to initialize the dedicated Key Protect instance."
  default     = ""
}

variable "dedicated_signature_key_owner" {
  type        = string
  sensitive   = true
  description = "Owner label for the signature key used to initialize the dedicated Key Protect instance."
  default     = "ADMIN"
}

variable "dedicated_master_key_keyname" {
  type        = string
  sensitive   = true
  description = "The name of the master key for initializing the dedicated Key Protect instance. Must be 8 characters or less."
  default     = "mbkkey"
}

variable "dedicated_master_key_share_1_filepath" {
  type        = string
  sensitive   = true
  description = "Filepath for key share 1 of the master key used to initialize the dedicated Key Protect instance."
  default     = "kp-dedicated-mbk-1.key"
}

variable "dedicated_master_key_share_1_passphrase" {
  type        = string
  sensitive   = true
  description = "Passphrase for key share 1 of the master key used to initialize the dedicated Key Protect instance."
  default     = ""
}

variable "dedicated_master_key_share_2_filepath" {
  type        = string
  sensitive   = true
  description = "Filepath for key share 2 of the master key used to initialize the dedicated Key Protect instance."
  default     = "kp-dedicated-mbk-2.key"
}

variable "dedicated_master_key_share_2_passphrase" {
  type        = string
  sensitive   = true
  description = "Passphrase for key share 2 of the master key used to initialize the dedicated Key Protect instance."
  default     = ""
}

variable "dedicated_master_key_share_3_filepath" {
  type        = string
  sensitive   = true
  description = "Filepath for key share 3 of the master key. Only required when `dedicated_crypto_units` is 3."
  default     = null
}

variable "dedicated_master_key_share_3_passphrase" {
  type        = string
  sensitive   = true
  description = "Passphrase for key share 3 of the master key. Only required when `dedicated_crypto_units` is 3."
  default     = null
}
