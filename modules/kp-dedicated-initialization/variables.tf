##############################################################################
# Input Variables
##############################################################################

# The following three variables are declared as stubs because the testhelper
# wrapper (TestOptionsDefaultWithVars) automatically injects prefix,
# resource_group, and resource_tags into every Terraform module it targets.
# They are not used by this submodule but must be declared to avoid
# "undeclared variable" errors during terraform plan/apply.

# tflint-ignore: terraform_unused_declarations
variable "prefix" {
  type        = string
  description = "Unused stub — injected automatically by the testhelper wrapper."
  default     = null
}

# tflint-ignore: terraform_unused_declarations
variable "resource_group" {
  type        = string
  description = "Unused stub — injected automatically by the testhelper wrapper."
  default     = null
}

# tflint-ignore: terraform_unused_declarations
variable "resource_tags" {
  type        = list(string)
  description = "Unused stub — injected automatically by the testhelper wrapper."
  default     = []
}

variable "instance_id" {
  type        = string
  description = "The GUID of the dedicated Key Protect instance to initialize."
}

variable "region" {
  type        = string
  description = "The region where the dedicated Key Protect instance is provisioned."
}

variable "use_private_endpoint" {
  type        = bool
  description = "If set to true, the private endpoint is used to initialize the dedicated Key Protect instance."
  default     = false
}

variable "signature_key_filepath" {
  type        = string
  sensitive   = true
  description = "Filepath for the admin signature key. The file must already exist on disk."
}

variable "signature_key_passphrase" {
  type        = string
  sensitive   = true
  description = "Passphrase for the admin signature key."
  default     = ""
}

variable "signature_key_owner" {
  type        = string
  sensitive   = true
  description = "Owner label for the admin signature key."
  default     = "ADMIN"
}

variable "master_key_keyname" {
  type        = string
  sensitive   = true
  description = "The name of the master key. Must be 8 characters or less."
  default     = "mbkkey"
}

variable "master_key_share_1_filepath" {
  type        = string
  sensitive   = true
  description = "Filepath for master key share 1. The file must already exist on disk."
}

variable "master_key_share_1_passphrase" {
  type        = string
  sensitive   = true
  description = "Passphrase for master key share 1."
  default     = ""
}

variable "master_key_share_2_filepath" {
  type        = string
  sensitive   = true
  description = "Filepath for master key share 2. The file must already exist on disk."
}

variable "master_key_share_2_passphrase" {
  type        = string
  sensitive   = true
  description = "Passphrase for master key share 2."
  default     = ""
}

variable "master_key_share_3_filepath" {
  type        = string
  sensitive   = true
  description = "Filepath for master key share 3. Required only when the instance has 3 crypto units."
  default     = null
}

variable "master_key_share_3_passphrase" {
  type        = string
  sensitive   = true
  description = "Passphrase for master key share 3. Required only when `master_key_share_3_filepath` is set."
  default     = null
}
