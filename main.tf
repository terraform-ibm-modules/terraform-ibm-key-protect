##############################################################################
# Create Key Protect instance
##############################################################################

locals {
  kp_endpoints = { for key, value in ibm_resource_instance.key_protect_instance.extensions : key => value
  }
  is_dedicated = var.plan == "dedicated" ? 1 : 0
}

module "dedicated_kp_instance" {
  source = "./modules/kp-dedicated"
  count = local.is_dedicated ? 1 : 0
  resource_group_id = var.resource_group_id
  key_protect_name = var.key_protect_name
  region = var.region
  tags = var.tags
}

resource "ibm_resource_instance" "key_protect_instance" {
  count = local.is_dedicated ? 0 : 1
  name              = var.key_protect_name
  resource_group_id = var.resource_group_id
  service           = "kms"
  plan              = var.plan
  location          = var.region
  tags              = var.tags
  parameters = {
    allowed_network : var.allowed_network
  }
}

##############################################################################
# Create Instance Policies
##############################################################################

resource "ibm_kms_instance_policies" "key_protect_instance_policies" {
  count = local.is_dedicated ? 0 : 1
  instance_id   = ibm_resource_instance.key_protect_instance[0].guid
  endpoint_type = var.allowed_network == "private-only" ? "private" : "public"
  rotation {
    enabled        = var.rotation_enabled
    interval_month = var.rotation_enabled == true ? var.rotation_interval_month : null
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

locals {
  # instance policy output is not formatted correctly, cleanup done in this local
  # tracking in issue: https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5163
  instance_policies = {
    dual_auth_delete         = [for obj in ibm_kms_instance_policies.key_protect_instance_policies[0].dual_auth_delete : obj if obj != null]
    id                       = ibm_kms_instance_policies.key_protect_instance_policies[0].id
    instance_id              = ibm_kms_instance_policies.key_protect_instance_policies[0].instance_id
    key_create_import_access = [for obj in ibm_kms_instance_policies.key_protect_instance_policies[0].key_create_import_access : obj if obj != null]
    metrics                  = [for obj in ibm_kms_instance_policies.key_protect_instance_policies[0].metrics : obj if obj != null]
    rotation                 = [for obj in ibm_kms_instance_policies.key_protect_instance_policies[0].rotation : obj if obj != null]
  }
}

##############################################################################
# Attach Access Tags
##############################################################################

resource "ibm_resource_tag" "key_protect_tag" {
  count       = length(var.access_tags) == 0 ? 0 : 1
  resource_id = ibm_resource_instance.key_protect_instance[0].crn
  tags        = var.access_tags
  tag_type    = "access"
}

##############################################################################
# Context Based Restrictions
##############################################################################

locals {
  default_operations = [{
    api_types = [
      {
        "api_type_id" : "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
      },
      {
        "api_type_id" : "crn:v1:bluemix:public:context-based-restrictions::::platform-api-type:"
      }
    ]
  }]
}

module "cbr_rule" {
  count            = length(var.cbr_rules)
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.36.0"
  rule_description = var.cbr_rules[count.index].description
  enforcement_mode = var.cbr_rules[count.index].enforcement_mode
  rule_contexts    = var.cbr_rules[count.index].rule_contexts
  resources = [{
    attributes = [
      {
        name  = "accountId"
        value = var.cbr_rules[count.index].account_id
      },
      {
        name     = "serviceInstance"
        value    = ibm_resource_instance.key_protect_instance[0].guid
        operator = "stringEquals"
      },
      {
        name  = "serviceName"
        value = "kms"
      }
    ]
  }]
  operations = var.cbr_rules[count.index].operations == null ? local.default_operations : var.cbr_rules[count.index].operations
}
