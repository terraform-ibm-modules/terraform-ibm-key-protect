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
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# Create CBR Zone
##############################################################################

# A network zone with Service reference to schematics
module "cbr_zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.27.0"
  name             = "${var.prefix}-network-zone"
  zone_description = "CBR Network zone for schematics"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type = "serviceRef"
    ref = {
      account_id   = data.ibm_iam_account_settings.iam_account_settings.account_id
      service_name = "schematics"
    }
  }]
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
  # CBR rule only allowing the Key Protect instance to be accessbile from Schematics
  cbr_rules = [{
    description      = "${var.prefix}-key-protect access only from schematics"
    enforcement_mode = "enabled"
    account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
    rule_contexts = [{
      attributes = [
        {
          name  = "networkZoneId"
          value = module.cbr_zone.zone_id
        }
      ]
    }]
  }]
}

##############################################################################
# Key Ring module
##############################################################################

module "kms_key_ring" {
  source        = "terraform-ibm-modules/kms-key-ring/ibm"
  version       = "2.4.1"
  instance_id   = module.key_protect_module.key_protect_guid
  key_ring_id   = "${var.prefix}-my-key-ring"
  endpoint_type = "private"
}

##############################################################################
# KMS root key
##############################################################################

module "ibm_kms_key" {
  source          = "terraform-ibm-modules/kms-key/ibm"
  version         = "1.2.4"
  kms_instance_id = module.key_protect_module.key_protect_guid
  key_name        = "${var.prefix}-root-key"
  kms_key_ring_id = module.kms_key_ring.key_ring_id
  standard_key    = false
  force_delete    = true
  endpoint_type   = "private"
}
