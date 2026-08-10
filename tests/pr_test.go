// Tests in this file are run in the PR pipeline
package test

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group for tests
const resourceGroup = "geretain-test-key-protect"

// const terraformDir = "examples/basic"
// const advancedExampleTerraformDir = "examples/advanced"
const dedicatedKPDir = "examples/dedicated"

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

// generateDedicatedKeyFiles uses the IBM Cloud CLI to generate real signature key
// and master key share files locally. Both commands are purely local — they do not
// contact the KP instance and do not require the native ibmkmscrypto library at
// this stage. The generated files are written into keyDir and their absolute paths
// are returned so Terraform can reference them directly.
//
// When ibm_kms_cryptounits runs apply it finds the files already on disk
// (keyExists=true) and imports them into the HSM rather than generating new ones.
func generateDedicatedKeyFiles(t *testing.T, keyDir string) (sigKeyPath, mbk1Path, mbk2Path string) {
	t.Helper()

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

	// 2. Generate master key shares (AES-256, local only, no instance needed).
	//    The --auth flag is only required for master-key import (upload to HSM),
	//    not for master-key generate (local key splitting).
	keyshareFiles, err := json.Marshal([]string{
		fmt.Sprintf("%s#%s", mbk1Path, dedicatedMBKPassphrase),
		fmt.Sprintf("%s#%s", mbk2Path, dedicatedMBKPassphrase),
	})
	require.NoError(t, err)

	mkCmd := exec.Command("ibmcloud", "kp", "crypto-unit", "mk", "generate", // #nosec G204
		"--keyshare-files", string(keyshareFiles),
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

// Passphrases and key name used for dedicated key generation in tests.
// Passphrases must be 6-255 characters per the CLI requirement.
const (
	dedicatedSigKeyPassphrase = "T3stPassw0rd!" // #nosec G101
	dedicatedMBKPassphrase    = "T3stPassw0rd!" // #nosec G101
	dedicatedMasterKeyName    = "mbkkey"
)

func setupOptionsDedicated(t *testing.T, prefix string, sigKeyPath, mbk1Path, mbk2Path string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dedicatedKPDir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"access_tags":                             permanentResources["accessTags"],
			"region":                                  dedicatedRegions[common.CryptoIntn(len(dedicatedRegions))],
			"dedicated_signature_key_filepath":        sigKeyPath,
			"dedicated_signature_key_passphrase":      dedicatedSigKeyPassphrase,
			"dedicated_signature_key_owner":           "ADMIN",
			"dedicated_master_key_keyname":            dedicatedMasterKeyName,
			"dedicated_master_key_share_1_filepath":   mbk1Path,
			"dedicated_master_key_share_1_passphrase": dedicatedMBKPassphrase,
			"dedicated_master_key_share_2_filepath":   mbk2Path,
			"dedicated_master_key_share_2_passphrase": dedicatedMBKPassphrase,
		},
	})
	return options
}

func TestRunDedicatedExample(t *testing.T) {
	t.Parallel()

	// Generate real key files locally using the IBM Cloud CLI.
	// Both commands are local-only — no HSM connection required at this stage.
	// Terraform's ibm_kms_cryptounits will find the files on disk and import
	// them into the newly provisioned dedicated instance during apply.
	keyDir := t.TempDir()
	sigKeyPath, mbk1Path, mbk2Path := generateDedicatedKeyFiles(t, keyDir)

	options := setupOptionsDedicated(t, "kp-d", sigKeyPath, mbk1Path, mbk2Path)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
