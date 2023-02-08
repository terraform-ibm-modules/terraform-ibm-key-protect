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

##############################################################################
# Enable Metrics - Deprecated
##############################################################################

resource "restapi_object" "enable_metrics" {
  count          = var.metrics_enabled ? 1 : 0
  path           = "//${var.region}.kms.cloud.ibm.com/api/v2/instance/policies?policy=metrics"
  data           = "{\"metadata\": {\"collectionType\": \"application/vnd.ibm.kms.policy+json\", \"collectionTotal\": 1}, \"resources\": [{\"policy_type\": \"metrics\", \"policy_data\": {\"enabled\": true}}]}"
  create_method  = "PUT"
  create_path    = "//${var.region}.kms.cloud.ibm.com/api/v2/instance/policies?policy=metrics"
  update_method  = "PUT"
  update_path    = "//${var.region}.kms.cloud.ibm.com/api/v2/instance/policies?policy=metrics"
  destroy_method = "GET"
  destroy_path   = "//${var.region}.kms.cloud.ibm.com/api/v2/instance/policies?policy=metrics"
  read_path      = "//${var.region}.kms.cloud.ibm.com/api/v2/instance/policies?policy=metrics"
  object_id      = ibm_resource_instance.key_protect_instance.guid
  id_attribute   = ibm_resource_instance.key_protect_instance.guid
}

##############################################################################
# Create Instance Policies
##############################################################################

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
    create_root_key     = var.key_create_import_access_settings.create_root_key
    create_standard_key = var.key_create_import_access_settings.create_standard_key
    import_root_key     = var.key_create_import_access_settings.import_root_key
    import_standard_key = var.key_create_import_access_settings.import_standard_key
    enforce_token       = var.key_create_import_access_settings.enforce_token
  }
}
