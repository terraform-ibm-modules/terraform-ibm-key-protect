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
# Enable Metrics
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
