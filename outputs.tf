##############################################################################
# Outputs
##############################################################################

output "key_protect_guid" {
  value       = ibm_resource_instance.key_protect_instance.guid
  description = "GUID of the Key Protect instance"
}

output "key_protect_id" {
  value       = ibm_resource_instance.key_protect_instance.id
  description = "ID of the Key Protect instance"
}

output "key_protect_crn" {
  value       = ibm_resource_instance.key_protect_instance.crn
  description = "CRN of the Key Protect instance"
}

output "key_protect_name" {
  value       = ibm_resource_instance.key_protect_instance.name
  description = "Name of the Key Protect instance"
}

output "key_protect_instance_policies" {
  value       = local.instance_policies
  description = "Instance Polices of the Key Protect instance"
}

output "kp_private_endpoint" {
  description = "Instance private endpoint URL"
  value       = local.kp_endpoints["endpoints.private"]
}
output "kp_public_endpoint" {
  description = "Instance public endpoint URL"
  value       = local.kp_endpoints["endpoints.public"]
}

output "cbr_rule_ids" {
  description = "CBR rule ids created to restrict Key Protect"
  value       = length(module.cbr_rule[*]) > 0 ? module.cbr_rule[*].rule_id : null
}
