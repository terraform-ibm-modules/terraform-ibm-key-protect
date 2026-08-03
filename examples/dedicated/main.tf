##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.6.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Key Protect
##############################################################################

module "key_protect_module" {
  source                                  = "../.."
  key_protect_name                        = "${var.prefix}-kp"
  resource_group_id                       = module.resource_group.resource_group_id
  plan                                    = "dedicated"
  region                                  = var.region
  resource_tags                           = var.resource_tags
  access_tags                             = var.access_tags
  dedicated_crypto_units                  = var.dedicated_crypto_units
  dedicated_use_private_endpoint          = var.dedicated_use_private_endpoint
  dedicated_signature_key                 = var.dedicated_signature_key
  dedicated_master_key_keyname            = var.dedicated_master_key_keyname
  dedicated_master_key_share_1_filepath   = var.dedicated_master_key_share_1_filepath
  dedicated_master_key_share_1_passphrase = var.dedicated_master_key_share_1_passphrase
  dedicated_master_key_share_2_filepath   = var.dedicated_master_key_share_2_filepath
  dedicated_master_key_share_2_passphrase = var.dedicated_master_key_share_2_passphrase
  dedicated_master_key_share_3_filepath   = var.dedicated_master_key_share_3_filepath
  dedicated_master_key_share_3_passphrase = var.dedicated_master_key_share_3_passphrase
}
