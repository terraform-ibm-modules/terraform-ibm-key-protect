##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Key Protect with Private Service Endpoint
##############################################################################

module "key_protect_module" {
  source            = "../.."
  key_protect_name  = "${var.prefix}-kp"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  tags              = var.resource_tags
  access_tags       = var.access_tags
  allowed_network   = "private-only"
}

##############################################################################
# Key Ring module
##############################################################################

module "kms_key_ring" {
  source        = "terraform-ibm-modules/kms-key-ring/ibm"
  version       = "2.4.0"
  instance_id   = module.key_protect_module.key_protect_guid
  key_ring_id   = "${var.prefix}-my-key-ring"
  endpoint_type = "private"
}

##############################################################################
# KMS root key
##############################################################################

module "ibm_kms_key" {
  source          = "terraform-ibm-modules/kms-key/ibm"
  version         = "1.2.3"
  kms_instance_id = module.key_protect_module.key_protect_guid
  key_name        = "${var.prefix}-root-key"
  kms_key_ring_id = module.kms_key_ring.key_ring_id
  standard_key    = false
  force_delete    = true
  endpoint_type   = "private"
}
