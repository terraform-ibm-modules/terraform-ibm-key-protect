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

output "key_protect_account_id" {
  value       = module.key_protect_module.key_protect_account_id
  description = "The account ID of the Key Protect instance."
}

output "key_protect_instance_policies" {
  description = "Instance policies of the Key Protect instance"
  value       = module.key_protect_module.key_protect_instance_policies
}

output "kp_private_endpoint" {
  description = "Instance private endpoint URL"
  value       = module.key_protect_module.kp_private_endpoint
}

output "kp_public_endpoint" {
  description = "Instance public endpoint URL"
  value       = module.key_protect_module.kp_public_endpoint
}
