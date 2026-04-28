resource "ibm_resource_instance" "key_protect_instance" {
  name              = var.key_protect_name
  resource_group_id = var.resource_group_id
  service           = "kms"
  plan              = "dedicated"
  location          = var.region
  tags              = var.tags
}

resource "terraform_data" "kp_dedicated_init" {
  depends_on = [ibm_resource_instance.key_protect_instance]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "${path.module}/scripts/kp_initialization.sh"
    environment = {
      instance_id = ibm_resource_instance.key_protect_instance[0].guid
    }
  }
}