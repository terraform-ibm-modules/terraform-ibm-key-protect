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

variable "admin_pass" {
  type        = string
  description = ""
  sensitive   = true
}

variable "keyshare_pass_1" {
  type        = string
  description = ""
  sensitive   = true
}

variable "keyshare_pass_2" {
  type        = string
  description = ""
  sensitive   = true
}

variable "master_key_name" {
  type        = string
  description = ""
  default     = "mskey"
}
