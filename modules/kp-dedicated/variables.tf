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

variable "admin_pass" {
  type = string
  description = ""
  sensitive = true
}

variable "keyshare_pass_1" {
  type = string
  description = ""
  sensitive = true
}

variable "keyshare_pass_2" {
  type = string
  description = ""
  sensitive = true
}

variable "master_key_name" {
  type = string
  description = ""
  default = "mskey"
}