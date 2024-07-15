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

output "key_protect_instance_policies" {
  description = "Instance policies of the Key Protect instance"
  value       = module.key_protect_module.key_protect_instance_policies
}

output "kp_private_endpoint" {
  description = "Instance private endpoint URL"
  value       = module.key_protect_module.kp_private_endpoint
}

output "kms_root_key_id" {
  description = "Key Protect Standard Key ID"
  value       = module.ibm_kms_key.key_id
}

output "kms_root_key_rotation_interval_month" {
  description = "Month Interval for Rotation of Standard Key"
  value       = module.ibm_kms_key.rotation_interval_month
}

output "kms_root_key_dual_auth_delete_enabled" {
  description = "Is Dual Auth Delete Enabled"
  value       = module.ibm_kms_key.dual_auth_delete
}

output "kms_key_ring_id" {
  description = "KMS Key Ring ID"
  value       = module.kms_key_ring.key_ring_id
}

output "cbr_rule_ids" {
  description = "CBR rule ids created to restrict Key Protect"
  value       = module.key_protect_module.cbr_rule_ids
}

output "cbr_zone_ids" {
  description = "Zone ids created for CBR"
  value       = module.cbr_zone[*].zone_id
}
