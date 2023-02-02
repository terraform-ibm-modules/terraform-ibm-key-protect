##############################################################################
# Create Key Protect instance
##############################################################################

resource "ibm_resource_instance" "key_protect_instance" {
  name              = var.key_protect_name
  resource_group_id = var.resource_group_id
  service           = "kms"
  plan              = var.plan
  location          = var.region
  service_endpoints = var.service_endpoints
  tags              = var.tags
}

resource "ibm_kms_instance_policies" "key_protect_instance_policies" {
  instance_id = ibm_resource_instance.key_protect_instance.guid
  rotation {
    enabled        = var.rotation_enabled
    interval_month = var.rotation_interval_month
  }
  dual_auth_delete {
    enabled = var.dual_auth_delete_enabled
  }
  metrics {
    enabled = var.metrics_enabled
  }
  key_create_import_access {
    enabled             = var.key_create_import_access_enabled
    create_root_key     = var.key_create_import_access_create_root_key
    create_standard_key = var.key_create_import_access_create_standard_key
    import_root_key     = var.key_create_import_access_import_root_key
    import_standard_key = var.key_create_import_access_import_standard_key
  }
}
