##############################################################################
# Outputs
##############################################################################

output "key_protect_guid" {
  value       = local.is_dedicated ? ibm_resource_instance.dedicated_key_protect_instance[0].guid : ibm_resource_instance.key_protect_instance[0].guid
  description = "GUID of the Key Protect instance"
}

output "key_protect_id" {
  value       = local.is_dedicated ? ibm_resource_instance.dedicated_key_protect_instance[0].id : ibm_resource_instance.key_protect_instance[0].id
  description = "ID of the Key Protect instance"
}

output "key_protect_crn" {
  value       = local.is_dedicated ? ibm_resource_instance.dedicated_key_protect_instance[0].crn : ibm_resource_instance.key_protect_instance[0].crn
  description = "CRN of the Key Protect instance"
}

output "key_protect_name" {
  value       = local.is_dedicated ? ibm_resource_instance.dedicated_key_protect_instance[0].name : ibm_resource_instance.key_protect_instance[0].name
  description = "Name of the Key Protect instance"
}

output "key_protect_account_id" {
  value       = local.is_dedicated ? ibm_resource_instance.dedicated_key_protect_instance[0].account_id : ibm_resource_instance.key_protect_instance[0].account_id
  description = "The account ID of the Key Protect instance."
}

output "key_protect_instance_policies" {
  value       = local.is_dedicated ? null : local.instance_policies
  description = "Instance Polices of the Key Protect instance"
}

output "kp_private_endpoint" {
  description = "Instance private endpoint URL"
  value       = local.is_dedicated ? local.kp_endpoints_dedicated["endpoints.private"] : local.kp_endpoints["endpoints.private"]
}

output "kp_public_endpoint" {
  description = "Instance public endpoint URL"
  value       = local.is_dedicated ? local.kp_endpoints_dedicated["endpoints.public"] : local.kp_endpoints["endpoints.public"]
}

output "cbr_rule_ids" {
  description = "CBR rule ids created to restrict Key Protect"
  value       = length(module.cbr_rule[*]) > 0 ? module.cbr_rule[*].rule_id : null
}
