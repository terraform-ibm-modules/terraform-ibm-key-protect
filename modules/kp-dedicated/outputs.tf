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

output "key_protect_account_id" {
  value       = ibm_resource_instance.key_protect_instance.account_id
  description = "The account ID of the Key Protect instance."
}

output "key_protect_instance_policies" {
  value       = "null"
  description = "Instance Polices of the Key Protect instance"
}

output "kp_private_endpoint" {
  description = "Instance private endpoint URL"
  value       = "null"
}

output "kp_public_endpoint" {
  description = "Instance public endpoint URL"
  value       = "mull"
}

output "cbr_rule_ids" {
  description = "CBR rule ids created to restrict Key Protect"
  value       = "null"
}
