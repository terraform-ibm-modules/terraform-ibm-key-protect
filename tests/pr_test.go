// Tests in this file are run in the PR pipeline
package test

import (
	"context"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
	"time"

	// "github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	// "github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group for tests
const resourceGroup = "geretain-test-key-protect"

// const terraformDir = "examples/basic"
// const advancedExampleTerraformDir = "examples/advanced"
const dedicatedKPDir = "examples/dedicated"
const dedicatedInitDir = "modules/kp-dedicated-initialization"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}

func TestMain(m *testing.M) {
	// Read the YAML file contents
	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

// func setupOptions(t *testing.T, prefix string) *testhelper.TestOptions {
// 	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
// 		Testing:       t,
// 		TerraformDir:  terraformDir,
// 		Prefix:        prefix,
// 		ResourceGroup: resourceGroup,
// 		TerraformVars: map[string]interface{}{
// 			"access_tags": permanentResources["accessTags"],
// 		},
// 	})
// 	return options
// }

// func TestRunBasicExample(t *testing.T) {
// 	t.Parallel()

// 	options := setupOptions(t, "kp-basic")
// 	output, err := options.RunTestConsistency()
// 	assert.Nil(t, err, "This should not have errored")
// 	assert.NotNil(t, output, "Expected some output")
// }

var dedicatedRegions = []string{
	"us-south",
	"eu-de",
	"us-east",
}

// Passphrases and key name used for dedicated key generation in tests.
// Passphrases must be 6-255 characters per the CLI requirement.
const (
	dedicatedSigKeyPassphrase = "T3stPassw0rd!" // #nosec G101
	dedicatedMBKPassphrase    = "T3stPassw0rd!" // #nosec G101
	dedicatedMasterKeyName    = "mbkkey"
)

func setupOptionsDedicated(t *testing.T, prefix string, region string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dedicatedKPDir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"access_tags": permanentResources["accessTags"],
			"region":      region,
		},
	})
	return options
}

// generateDedicatedKeyFiles uses the IBM Cloud CLI to generate real signature key
// and master key share files locally.
//
//   - sig-key generate is purely local (no instance needed)
//   - mk generate requires --instance-id for CLI validation, so the dedicated
//     instance must be provisioned before calling this function
//
// The generated files are written into keyDir and their absolute paths are
// returned so Terraform can reference them directly.
//
// When ibm_kms_cryptounits runs apply it finds the files already on disk
// (keyExists=true) and imports them into the HSM rather than generating new ones.
func generateDedicatedKeyFiles(t *testing.T, keyDir string, instanceID string, region string) (sigKeyPath, mbk1Path, mbk2Path string) {
	t.Helper()

	// Log in to IBM Cloud using the API key that Terraform also uses.
	// The ibmcloud CLI must be authenticated before any kp subcommands work.
	// Must target the same region as the instance — mk generate queries crypto
	// units from the regional endpoint.
	apiKey := os.Getenv("TF_VAR_ibmcloud_api_key")
	require.NotEmpty(t, apiKey, "TF_VAR_ibmcloud_api_key must be set")

	loginCmd := exec.Command("ibmcloud", "login", "--apikey", apiKey, "-r", region) // #nosec G204 G702
	loginCmd.Stdout = os.Stdout
	loginCmd.Stderr = os.Stderr
	require.NoError(t, loginCmd.Run(), "ibmcloud login failed")

	sigKeyPath = filepath.Join(keyDir, "kp-dedicated-signature.key")
	mbk1Path = filepath.Join(keyDir, "kp-dedicated-mbk-1.key")
	mbk2Path = filepath.Join(keyDir, "kp-dedicated-mbk-2.key")

	// 1. Generate admin signature key (RSA-2048, local only, no instance needed)
	sigCmd := exec.Command("ibmcloud", "kp", "crypto-unit", "sig-key", "generate", // #nosec G204
		"--file", sigKeyPath,
		"--passphrase", dedicatedSigKeyPassphrase,
		"--algo", "RSA-2048",
	)
	sigCmd.Stdout = os.Stdout
	sigCmd.Stderr = os.Stderr
	require.NoError(t, sigCmd.Run(), "ibmcloud kp sig-key generate failed")
	t.Logf("Generated signature key: %s", sigKeyPath)

	// 2. Generate master key shares (AES-256).
	//    --auth format: '[{"<owner>": "<filepath>#<passphrase>"}]'
	//    --instance-id is required by the CLI plugin even for local key splitting.
	authJSON := fmt.Sprintf(`[{"ADMIN": "%s#%s"}]`, sigKeyPath, dedicatedSigKeyPassphrase)
	mkCmd := exec.Command("ibmcloud", "kp", "crypto-unit", "mk", "generate", // #nosec G204
		"--instance-id", instanceID,
		"--auth", authJSON,
		"--keyshare-files", fmt.Sprintf("[%q,%q]",
			fmt.Sprintf("%s#%s", mbk1Path, dedicatedMBKPassphrase),
			fmt.Sprintf("%s#%s", mbk2Path, dedicatedMBKPassphrase),
		),
		"--keyshare-minimum", "2",
		"--algo", "AES-256",
		"--key-name", dedicatedMasterKeyName,
	)
	mkCmd.Stdout = os.Stdout
	mkCmd.Stderr = os.Stderr
	require.NoError(t, mkCmd.Run(), "ibmcloud kp mk generate failed")
	t.Logf("Generated master key shares: %s, %s", mbk1Path, mbk2Path)

	return sigKeyPath, mbk1Path, mbk2Path
}

func TestRunDedicatedExample(t *testing.T) {
	t.Parallel()

	region := dedicatedRegions[common.CryptoIntn(len(dedicatedRegions))]

	// Step 1: Apply examples/dedicated to provision the instance.
	// We use TestSetup/TestTearDown directly (instead of RunTestConsistency) so
	// the instance stays live after apply — we need its GUID for key generation.
	// TestTearDown runs terraform destroy at the end, even on failure.
	instanceOptions := setupOptionsDedicated(t, "kp-d", region)
	instanceOptions.TestSetup()
	defer instanceOptions.TestTearDown()

	_, err := terraform.InitAndApplyContextE(t, context.Background(), instanceOptions.TerraformOptions)
	require.Nil(t, err, "Dedicated instance provisioning should not have errored")

	outputs, outputErr := terraform.OutputAllContextE(t, context.Background(), instanceOptions.TerraformOptions)
	require.Nil(t, outputErr, "Failed to read outputs from dedicated instance")

	instanceID, ok := outputs["key_protect_guid"].(string)
	require.True(t, ok && instanceID != "", "key_protect_guid output must be a non-empty string")
	t.Logf("Provisioned dedicated KP instance: %s", instanceID)

	// The dedicated HSM crypto units need a settling period after the resource
	// reports active before they can be queried by the CLI. 3 minutes is
	// conservative but reliable based on observed provisioning behaviour.
	t.Log("Waiting 3m for crypto units to become queryable...")
	time.Sleep(3 * time.Minute)

	// Step 2 & 3: Generate signature key and master key shares via IBM Cloud CLI.
	// mk generate requires --auth (the signature key file) and --instance-id.
	keyDir := t.TempDir()
	sigKeyPath, mbk1Path, mbk2Path := generateDedicatedKeyFiles(t, keyDir, instanceID, region)

	// Step 4: Initialize the dedicated instance using the kp-dedicated-initialization submodule.
	initOptions := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dedicatedInitDir,
		Prefix:        "kp-d-init",
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"instance_id":                   instanceID,
			"region":                        region,
			"signature_key_filepath":        sigKeyPath,
			"signature_key_passphrase":      dedicatedSigKeyPassphrase,
			"signature_key_owner":           "ADMIN",
			"master_key_keyname":            dedicatedMasterKeyName,
			"master_key_share_1_filepath":   mbk1Path,
			"master_key_share_1_passphrase": dedicatedMBKPassphrase,
			"master_key_share_2_filepath":   mbk2Path,
			"master_key_share_2_passphrase": dedicatedMBKPassphrase,
		},
	})
	initPlan, initErr := initOptions.RunTestConsistency()
	assert.Nil(t, initErr, "Dedicated initialization should not have errored")
	assert.NotNil(t, initPlan, "Expected plan output from dedicated initialization")
}

// func TestRunAdvanceExample(t *testing.T) {
// 	t.Parallel()

// 	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
// 		Testing: t,
// 		Prefix:  "advanced-key-protect",
// 		TarIncludePatterns: []string{
// 			"*.tf",
// 			advancedExampleTerraformDir + "/*.tf",
// 		},

// 		ResourceGroup:          resourceGroup,
// 		TemplateFolder:         advancedExampleTerraformDir,
// 		Tags:                   []string{"test-schematic"},
// 		DeleteWorkspaceOnFail:  false,
// 		WaitJobCompleteMinutes: 60,
// 	})

// 	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
// 		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
// 		{Name: "region", Value: options.Region, DataType: "string"},
// 		{Name: "prefix", Value: options.Prefix, DataType: "string"},
// 		{Name: "resource_group", Value: options.ResourceGroup, DataType: "string"},
// 	}

// 	err := options.RunSchematicTest()
// 	assert.Nil(t, err, "This should not have errored")
// }

// func TestRunUpgrade(t *testing.T) {
// 	t.Parallel()

// 	options := setupOptions(t, "kp-basic-upgrade")
// 	output, err := options.RunTestUpgrade()
// 	if !options.UpgradeTestSkipped {
// 		assert.Nil(t, err, "This should not have errored")
// 		assert.NotNil(t, output, "Expected some output")
// 	}
// }

// func TestPlanValidation(t *testing.T) {
// 	// Regions that support Cross Region Resiliency plan
// 	validCrossRegionPlanLocations := []string{"us-south", "eu-de", "jp-tok"}
// 	// Regions that don't support Cross Region Resiliency plan
// 	invalidCrossRegionPlanLocations := []string{"au-syd", "jp-osa", "eu-es", "eu-gb", "ca-tor", "us-east", "br-sao"}

// 	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
// 		Testing:       t,
// 		TerraformDir:  terraformDir,
// 		Prefix:        "validate-plan",
// 		ResourceGroup: resourceGroup,
// 		Region:        "us-south", // skip VPC region picker
// 	})
// 	options.TestSetup()
// 	options.TerraformOptions.NoColor = true
// 	options.TerraformOptions.Logger = logger.Discard
// 	options.TerraformOptions.Vars = map[string]interface{}{
// 		"prefix":         options.Prefix,
// 		"plan":           "cross-region-resiliency",
// 		"resource_group": options.ResourceGroup,
// 	}

// 	_, initErr := terraform.InitContextE(t, context.Background(), options.TerraformOptions)
// 	if assert.Nil(t, initErr, "This should not have errored") {
// 		for _, validRegion := range validCrossRegionPlanLocations {
// 			options.TerraformOptions.Vars["region"] = validRegion
// 			t.Run(validRegion, func(t *testing.T) {
// 				output, err := terraform.PlanContextE(t, context.Background(), options.TerraformOptions)
// 				assert.Nil(t, err, fmt.Sprintf("This should not have errored\nRegion: %s\n", validRegion))
// 				assert.NotNil(t, output, "Expected some output")
// 			})
// 		}

// 		for _, invalidRegion := range invalidCrossRegionPlanLocations {
// 			options.TerraformOptions.Vars["region"] = invalidRegion
// 			t.Run(invalidRegion, func(t *testing.T) {
// 				fmt.Print("\n#################### THIS IS EXPECTED TO ERROR ####################\n\n")
// 				_, err := terraform.PlanContextE(t, context.Background(), options.TerraformOptions)
// 				fmt.Print("\n#################### END EXPECTED ERROR ####################\n\n")
// 				assert.NotNil(t, err, fmt.Sprintf("This should have errored\nRegion: %s", invalidRegion))
// 			})
// 		}
// 	}
// }
