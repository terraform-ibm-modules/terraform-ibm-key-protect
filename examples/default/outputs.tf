##############################################################################
# Outputs
##############################################################################

output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.resource_group.resource_group_id
}

output "key_protect_guid" {
  description = "GUID of the Key Protect instance"
  value       = module.key_protect_module.key_protect_guid
}

output "key_protect_id" {
  description = "ID of the Key Protect instance"
  value       = module.key_protect_module.key_protect_id
}

output "key_protect_name" {
  description = "Name of the Key Protect instance"
  value       = module.key_protect_module.key_protect_name
}
