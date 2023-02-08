provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

# Deprecated
# Retrieve IAM access token (required for restapi provider)
data "ibm_iam_auth_token" "token_data" {
}

# Deprecated
provider "restapi" {
  uri                   = "https:"
  write_returns_object  = false
  create_returns_object = false
  debug                 = false # set to true to show detailed logs, but use carefully as it might print sensitive values.
  headers = {
    Authorization    = data.ibm_iam_auth_token.token_data.iam_access_token
    Bluemix-Instance = module.key_protect_module.key_protect_guid
    Content-Type     = "application/vnd.ibm.kms.policy+json"
  }
}
