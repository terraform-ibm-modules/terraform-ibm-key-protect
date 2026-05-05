# Advanced private example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=key-protect-advanced-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-key-protect/tree/main/examples/advanced">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

An advanced example that shows how to provision a private only Key Protect instance with a new Key Ring and Key.

The following resources are provisioned by this example:
 - A new resource group, if an existing one is not passed in.
 - A new private key protect instance in the given resource group and region.
 - A new KMS key ring.
 - A new KMS root key in the newly created key ring.
 - A context-based restriction (CBR) rule to only allow Key Protect to be accessible from Schematics
