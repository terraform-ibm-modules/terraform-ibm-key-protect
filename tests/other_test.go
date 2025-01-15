package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestPlanValidation(t *testing.T) {
	t.Parallel()

	options := &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"prefix":         "validate-plan",
			"region":         "us-south",
			"plan":           "cross-region-resiliency",
			"resource_group": resourceGroup,
		},
		Upgrade: true,
	}

	output, err := terraform.InitAndPlanE(t, options)

	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")

	options.Vars = map[string]interface{}{
		"prefix":         "validate-plan",
		"region":         "us-east",
		"plan":           "cross-region-resiliency",
		"resource_group": resourceGroup,
	}

	_, err = terraform.PlanE(t, options)

	assert.NotNil(t, err, "This should have errored")
}
