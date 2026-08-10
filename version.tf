terraform {
  required_version = ">= 1.9.0"
  required_providers {
    # Use "greater than or equal to" range in modules
    # Note: ibm_kms_cryptounits (used for dedicated plan initialization) requires >= 2.4.0
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 2.4.0, < 3.0.0"
    }
  }
}
