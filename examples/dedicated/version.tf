terraform {
  required_version = ">= 1.9.0"
  required_providers {
    # Pin to the lowest provider version of the range defined in the main module's version.tf to ensure lowest version still works
    # ibm_kms_cryptounits (dedicated plan initialization) requires >= 2.4.0
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "2.5.0-beta0"
    }
  }
}
