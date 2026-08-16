##############################################################################
# Outputs
##############################################################################

output "cryptounits" {
  description = "Cryptounits associated with the dedicated Key Protect instance after initialization. Each element contains the crypto unit `id` and `state`."
  value       = ibm_kms_cryptounits.dedicated_key_protect_initialization.cryptounits
}
