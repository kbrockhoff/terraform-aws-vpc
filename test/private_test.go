package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformPrivateExample(t *testing.T) {
	t.Parallel()
	expectedName := generateTestNamePrefix("priv")

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/private",

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
	assert.Contains(t, planOutput, "aws_subnet.private")
	assert.Contains(t, planOutput, "aws_subnet.database")
	assert.Contains(t, planOutput, "will be created")

	// Verify private-only configuration - should NOT have public resources
	assert.NotContains(t, planOutput, "aws_internet_gateway.main")
	assert.NotContains(t, planOutput, "aws_nat_gateway.main")
	assert.NotContains(t, planOutput, "aws_subnet.public")

	// Verify VPC block public access is enabled
	assert.Contains(t, planOutput, "aws_vpc_block_public_access_options.main")

	// Verify VPC endpoints are created for private connectivity
	assert.Contains(t, planOutput, "module.main.module.vpc_endpoints")

	// Verify VPC Flow Logs are enabled
	assert.Contains(t, planOutput, "aws_flow_log.vpc")
	assert.Contains(t, planOutput, "aws_cloudwatch_log_group.vpc_flow_logs")

	// Verify security groups for private networking
	assert.Contains(t, planOutput, "module.main.module.db_security_group")
	assert.Contains(t, planOutput, "module.main.module.vpc_security_group")
	assert.Contains(t, planOutput, "module.main.module.endpoint_security_group")

	// Verify expected resource count (should have VPC and related resources)
	assert.Contains(t, planOutput, "44 to add, 0 to change, 0 to destroy")

}
