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
      KP_INSTANCE_ID = ibm_resource_instance.key_protect_instance.guid
      KP_TARGET_ADDR = "https://${ibm_resource_instance.key_protect_instance.guid}.api.${var.region}.kms.appdomain.cloud"
      ADMIN_PASS = var.admin_pass
      KEYSHARE_PASS_1 = var.keyshare_pass_1
      KEYSHARE_PASS_2 = var.keyshare_pass_2
      MASTER_KEY_NAME = var.master_key_name
    }
  }
}