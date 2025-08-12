package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const RandomIDLength = 10

func TestTerraformDefaultsExample(t *testing.T) {
	t.Parallel()
	expectedName := generateTestNamePrefix("def")

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/defaults",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"name_prefix": expectedName,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform plan` to validate configuration without creating resources
	terraform.Init(t, terraformOptions)
	planOutput := terraform.Plan(t, terraformOptions)

	// Verify the plan completed without errors and shows expected resource creation
	assert.NotEmpty(t, planOutput)

	// Verify core VPC resources are planned for creation
	assert.Contains(t, planOutput, "aws_vpc.main")
	assert.Contains(t, planOutput, "aws_subnet.public")
	assert.Contains(t, planOutput, "aws_subnet.private")
	assert.Contains(t, planOutput, "will be created")

	// Verify expected resource count (should have VPC and related resources)
	assert.Contains(t, planOutput, "40 to add, 0 to change, 0 to destroy")

}
