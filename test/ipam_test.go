package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestTerraformIPAMIPv4OnlyExample tests the IPAM example with IPv4 configuration only
func TestTerraformIPAMIPv4OnlyExample(t *testing.T) {
	t.Parallel()
	expectedName := generateTestNamePrefix("ipam4")

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/ipam",
		Vars: map[string]interface{}{
			"name_prefix":            expectedName,
			"ipam_pool_enabled":      true,
			"ipv4_ipam_pool_id":      "ipam-pool-xxxxxxxxxxxxxxxxx",
			"ipv4_netmask_length":    20,
			"ipv6_enabled":           false,
			"ipv6_ipam_pool_enabled": false,
		},
		EnvVars:                  map[string]string{},
		RetryableTerraformErrors: getBaseTerraformOptions("../examples/ipam").RetryableTerraformErrors,
		MaxRetries:               3,
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.Init(t, terraformOptions)
	planOutput := terraform.Plan(t, terraformOptions)

	// Verify the plan completed without errors
	assert.NotEmpty(t, planOutput)

	// Verify IPAM-specific resources are planned
	assert.Contains(t, planOutput, "aws_vpc.main")
	assert.Contains(t, planOutput, "ipam_pool_id")
	assert.Contains(t, planOutput, "ipv4_netmask_length")

	// Verify IPv6 resources are NOT created when disabled
	assert.NotContains(t, planOutput, "destination_ipv6_cidr_block")
	assert.NotContains(t, planOutput, "egress_only_gateway_id")

	// Verify core VPC resources are planned
	assert.Contains(t, planOutput, "aws_subnet.public")
	assert.Contains(t, planOutput, "aws_subnet.private")
	assert.Contains(t, planOutput, "aws_nat_gateway.main")
	assert.Contains(t, planOutput, "will be created")
}

// TestTerraformIPAMIPv4IPv6Example tests the IPAM example with both IPv4 and IPv6 configuration
func TestTerraformIPAMIPv4IPv6Example(t *testing.T) {
	t.Parallel()
	expectedName := generateTestNamePrefix("ipam6")

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/ipam",
		Vars: map[string]interface{}{
			"name_prefix":            expectedName,
			"ipam_pool_enabled":      true,
			"ipv4_ipam_pool_id":      "ipam-pool-xxxxxxxxxxxxxxxxx",
			"ipv4_netmask_length":    20,
			"ipv6_enabled":           true,
			"ipv6_ipam_pool_enabled": true,
			"ipv6_ipam_pool_id":      "ipam-pool-yyyyyyyyyyyyyyyy",
			"ipv6_netmask_length":    56,
			"enabled_databases":      []string{"postgres", "mysql"},
			"enabled_caches":         []string{"redis", "memcached"},
		},
		EnvVars:                  map[string]string{},
		RetryableTerraformErrors: getBaseTerraformOptions("../examples/ipam").RetryableTerraformErrors,
		MaxRetries:               3,
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.Init(t, terraformOptions)
	planOutput := terraform.Plan(t, terraformOptions)

	// Verify the plan completed without errors
	assert.NotEmpty(t, planOutput)

	// Verify both IPv4 and IPv6 IPAM configurations
	assert.Contains(t, planOutput, "ipv4_ipam_pool_id")
	assert.Contains(t, planOutput, "ipv4_netmask_length")
	assert.Contains(t, planOutput, "ipv6_ipam_pool_id")
	assert.Contains(t, planOutput, "ipv6_netmask_length")

	// Verify IPv6-specific resources are created
	assert.Contains(t, planOutput, "aws_egress_only_internet_gateway.main")
	assert.Contains(t, planOutput, "destination_ipv6_cidr_block")
	assert.Contains(t, planOutput, "::/0")

	// Verify VPC and subnet resources
	assert.Contains(t, planOutput, "aws_vpc.main")
	assert.Contains(t, planOutput, "aws_subnet.public")
	assert.Contains(t, planOutput, "aws_subnet.private")
	assert.Contains(t, planOutput, "will be created")

	// Verify expected resource count (should have VPC and related resources)
	assert.Contains(t, planOutput, "43 to add, 0 to change, 0 to destroy")

}
