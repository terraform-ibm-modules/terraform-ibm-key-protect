moved {
  from = ibm_kms_instance_policies.key_protect_instance_policies
  to   = ibm_kms_instance_policies.key_protect_instance_policies[0]
}

moved {
  from = ibm_resource_instance.key_protect_instance
  to   = ibm_resource_instance.key_protect_instance[0]
}
