# Migration: count-indexed → single resource (count removed when dedicated plan initialization was added)
# Note: users on the very original version (before a39db3b) will have already been migrated to [0]
# by the previous moved block, so this single block covers all upgrade paths.
moved {
  from = ibm_kms_instance_policies.key_protect_instance_policies[0]
  to   = ibm_kms_instance_policies.key_protect_instance_policies
}

moved {
  from = ibm_resource_instance.key_protect_instance
  to   = ibm_resource_instance.key_protect_instance[0]
}
