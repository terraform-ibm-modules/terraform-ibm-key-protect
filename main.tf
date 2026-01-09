##############################################################################
# Create Key Protect instance
##############################################################################

locals {
  kp_endpoints = { for key, value in ibm_resource_instance.key_protect_instance.extensions : key => value
  }
}

resource "ibm_resource_instance" "key_protect_instance" {
  name              = var.key_protect_name
  resource_group_id = var.resource_group_id
  service           = "kms"
  plan              = var.plan
  location          = var.region
  tags              = var.tags
  parameters = {
    allowed_network : var.allowed_network
  }

  lifecycle {
    postcondition {
      condition     = can(self.status) && self.status == "active"
      error_message = "Key Protect instance '${var.key_protect_name}' failed to provision. Status is '${try(self.status, "unknown")}', expected 'active'. Check IBM Cloud console for details."
    }

    postcondition {
      condition     = can(self.guid) && self.guid != null && self.guid != ""
      error_message = "Key Protect instance '${var.key_protect_name}' was created but has no GUID. This indicates a provisioning error and will prevent policies and CBR rules from being created."
    }

    postcondition {
      condition     = can(self.crn) && self.crn != null && self.crn != ""
      error_message = "Key Protect instance '${var.key_protect_name}' was created but has no CRN. This will prevent access tags from being attached."
    }
  }
}

##############################################################################
# Create Instance Policies
##############################################################################

resource "ibm_kms_instance_policies" "key_protect_instance_policies" {
  instance_id   = ibm_resource_instance.key_protect_instance.guid
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
    dual_auth_delete         = [for obj in ibm_kms_instance_policies.key_protect_instance_policies.dual_auth_delete : obj if obj != null]
    id                       = ibm_kms_instance_policies.key_protect_instance_policies.id
    instance_id              = ibm_kms_instance_policies.key_protect_instance_policies.instance_id
    key_create_import_access = [for obj in ibm_kms_instance_policies.key_protect_instance_policies.key_create_import_access : obj if obj != null]
    metrics                  = [for obj in ibm_kms_instance_policies.key_protect_instance_policies.metrics : obj if obj != null]
    rotation                 = [for obj in ibm_kms_instance_policies.key_protect_instance_policies.rotation : obj if obj != null]
  }
}

##############################################################################
# Attach Access Tags
##############################################################################

resource "ibm_resource_tag" "key_protect_tag" {
  count       = length(var.access_tags) == 0 ? 0 : 1
  resource_id = ibm_resource_instance.key_protect_instance.crn
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
  version          = "1.35.8"
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
        value    = ibm_resource_instance.key_protect_instance.guid
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

check "key_protect_instance_state" {
  data "ibm_resource_instance" "kp_instance_state" {
    identifier = ibm_resource_instance.key_protect_instance.id
  }

  assert {
    condition = (
      can(data.ibm_resource_instance.kp_instance_state.status) &&
      data.ibm_resource_instance.kp_instance_state.status == "active"
    )
    error_message = "Key Protect instance '${var.key_protect_name}' is not in active status. Current status: ${try(data.ibm_resource_instance.kp_instance_state.status, "unknown")}. This may indicate a provisioning or operational issue."
  }

  assert {
    condition = (
      can(data.ibm_resource_instance.kp_instance_state.guid) &&
      data.ibm_resource_instance.kp_instance_state.guid != null &&
      data.ibm_resource_instance.kp_instance_state.guid != ""
    )
    error_message = "Key Protect instance '${var.key_protect_name}' GUID is missing or empty. GUID: ${try(data.ibm_resource_instance.kp_instance_state.guid, "null")}"
  }

  assert {
    condition = (
      can(data.ibm_resource_instance.kp_instance_state.crn) &&
      data.ibm_resource_instance.kp_instance_state.crn != null &&
      data.ibm_resource_instance.kp_instance_state.crn != ""
    )
    error_message = "Key Protect instance '${var.key_protect_name}' CRN is missing or empty."
  }
}
