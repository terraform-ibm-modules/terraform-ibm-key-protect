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
# Create Instance Policies
##############################################################################

resource "ibm_kms_instance_policies" "key_protect_instance_policies" {
  instance_id = ibm_resource_instance.key_protect_instance.guid
  metrics {
    enabled = var.metrics_enabled
  }
}
