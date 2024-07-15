# Advanced private example

An advanced example that shows how to provision a private only Key Protect instance with a new Key Ring and Key.

The following resources are provisioned by this example:
 - A new resource group, if an existing one is not passed in.
 - A new private key protect instance in the given resource group and region.
 - A new KMS key ring.
 - A new KMS root key in the newly created key ring.
 - A context-based restriction (CBR) rule to only allow Key Protect to be accessible from Schematics
