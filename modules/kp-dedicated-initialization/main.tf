##############################################################################
# Initialize Dedicated Key Protect Instance
##############################################################################

resource "ibm_kms_cryptounits" "dedicated_key_protect_initialization" {
  instance_id          = var.instance_id
  region               = var.region
  use_private_endpoint = var.use_private_endpoint

  signature_key {
    filepath   = var.signature_key_filepath
    passphrase = var.signature_key_passphrase
    owner      = var.signature_key_owner
  }

  master_key {
    keysharefile {
      filepath   = var.master_key_share_1_filepath
      passphrase = var.master_key_share_1_passphrase
    }
    keysharefile {
      filepath   = var.master_key_share_2_filepath
      passphrase = var.master_key_share_2_passphrase
    }
    dynamic "keysharefile" {
      for_each = var.master_key_share_3_filepath != null ? [1] : []
      content {
        filepath   = var.master_key_share_3_filepath
        passphrase = var.master_key_share_3_passphrase
      }
    }
    keyname = var.master_key_keyname
  }
}
