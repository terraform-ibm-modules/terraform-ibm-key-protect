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

output "key_protect_name" {
  value       = ibm_resource_instance.key_protect_instance.name
  description = "Name of the Key Protect instance"
}

output "key_protect_instance_policies" {
  value       = ibm_kms_instance_policies.key_protect_instance_policies
  description = "Instance Polices of the Key Protect instance"
}
