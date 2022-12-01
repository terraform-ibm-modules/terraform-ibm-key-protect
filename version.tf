terraform {
  required_version = ">= 1.0.0"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      # Use "greater than or equal to" range in modules
      version = ">= 1.48.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = ">=1.18.0"
    }
  }
}
