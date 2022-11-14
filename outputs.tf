##############################################################################
# Outputs
##############################################################################

output "key_protect_guid" {
  value       = ibm_resource_instance.key_protect_instance.guid
  description = "GUID of the Key Protect instance"
}

output "key_protect_name" {
  value       = ibm_resource_instance.key_protect_instance.name
  description = "Name of the Key Protect instance"
}
