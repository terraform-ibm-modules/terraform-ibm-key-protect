// Tests in this file are run in the PR pipeline
package test

import (
	"fmt"
	"log"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group for tests
const resourceGroup = "geretain-test-key-protect"
const terraformDir = "examples/basic"
const advancedExampleTerraformDir = "examples/advanced"

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

func setupOptions(t *testing.T, prefix string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  terraformDir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"access_tags": permanentResources["accessTags"],
		},
	})
	return options
}

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "kp-basic")
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunAdvanceExample(t *testing.T) {
	t.Parallel()

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "advanced-key-protect",
		TarIncludePatterns: []string{
			"*.tf",
			advancedExampleTerraformDir + "/*.tf",
		},

		ResourceGroup:          resourceGroup,
		TemplateFolder:         advancedExampleTerraformDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "resource_group", Value: options.ResourceGroup, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunUpgrade(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "kp-basic-upgrade")
	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestPlanValidation(t *testing.T) {
	// Regions that support Cross Region Resiliency plan
	validCrossRegionPlanLocations := []string{"us-south", "eu-de", "jp-tok"}
	// Regions that don't support Cross Region Resiliency plan
	invalidCrossRegionPlanLocations := []string{"au-syd", "jp-osa", "eu-es", "eu-gb", "ca-tor", "us-east", "br-sao"}

	options := &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"prefix":         "validate-plan",
			"plan":           "cross-region-resiliency",
			"resource_group": resourceGroup,
		},
		Logger:  logger.Discard,
		Upgrade: true,
		NoColor: true,
	}

	_, initErr := terraform.InitE(t, options)
	assert.Nil(t, initErr, "This should not have errored")

	for _, validRegion := range validCrossRegionPlanLocations {
		options.Vars["region"] = validRegion
		t.Run(validRegion, func(t *testing.T) {
			output, err := terraform.PlanE(t, options)
			assert.Nil(t, err, fmt.Sprintf("This should not have errored\nRegion: %s\n", validRegion))
			assert.NotNil(t, output, "Expected some output")
		})
	}

	for _, invalidRegion := range invalidCrossRegionPlanLocations {
		options.Vars["region"] = invalidRegion
		t.Run(invalidRegion, func(t *testing.T) {
			fmt.Print("\n#################### THIS IS EXPECTED TO ERROR ####################\n\n")
			_, err := terraform.PlanE(t, options)
			fmt.Print("\n#################### END EXPECTED ERROR ####################\n\n")
			assert.NotNil(t, err, fmt.Sprintf("This should have errored\nRegion: %s", invalidRegion))
		})
	}
}
