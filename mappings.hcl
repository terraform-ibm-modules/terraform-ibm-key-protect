metadata {
  name   = "terraform-ibm-key-protect"
  source = "terraform-ibm-modules/terraform-ibm-key-protect"
}

compatible_module "resource_group" {
  source = "terraform-ibm-modules/resource-group"
}

compatible_variables {
  resource_group_id   = "resource_group.output.resource_group_id"
  resource_group_name = "resource_group.output.name"
}
