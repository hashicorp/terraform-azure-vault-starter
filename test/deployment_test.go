// Copyright © 2014-2022 HashiCorp, Inc.
//
// This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
//

package test

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

var tfcOrg string = "hc-tfc-dev"

var repoName string = "terraform-azure-vault-starter"

func TestClusterDeployment(t *testing.T) {
	var deployEnv string

	cwdPath, err := os.Getwd()
	if err != nil {
		logger.Log(t, "Unable to get current working directory")
		t.FailNow()
	}

	// TFC API token will be needed to update workspaces
	tfcToken := getTfeToken(t)
	if tfcToken == "" {
		t.FailNow()
	}

	if os.Getenv("DEPLOY_ENV") != "" {
		deployEnv = os.Getenv("DEPLOY_ENV")
	} else {
		if runtime.GOOS == "windows" {
			deployEnv = "test" + os.Getenv("USERNAME")
		} else {
			deployEnv = "test" + os.Getenv("USER")
		}
	}

	// Cleanup any characters that will cause problems in resource & workspace names
	deployEnv = strings.Replace(deployEnv, ".", "", -1)

	if len(deployEnv) > 15 {
		logger.Log(t, fmt.Sprintf("The chosen or autoconfigured resource name prefix (%s) exceeds 15 characters. Choose a new one by setting it as an environment variable -- e.g. export DEPLOY_ENV='%s'", deployEnv, deployEnv[0:11]))
		t.FailNow()
	}

	workspaceName := repoName + "-" + deployEnv

	// Run module, and setup its destruction during CI
	// (non-CI destruction is conditionally configured after tests below)
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{TerraformDir: cwdPath, Lock: true})
	removeAutoTfvars(t, cwdPath)
	tfVars := fmt.Sprintf("resource_name_prefix = \"%s\"\n", deployEnv)
	if os.Getenv("TEST_RESOURCE_GROUP_LOCATION") != "" && os.Getenv("TEST_RESOURCE_GROUP_NAME") != "" {
		tfVars = tfVars + fmt.Sprintf("resource_group = {location = \"%s\", name = \"%s\"}\n", os.Getenv("TEST_RESOURCE_GROUP_LOCATION"), os.Getenv("TEST_RESOURCE_GROUP_NAME"))
	}
	ioutil.WriteFile(filepath.Join(cwdPath, deployEnv+".auto.tfvars"), []byte(tfVars), 0644)
	if os.Getenv("GITHUB_ACTIONS") != "" {
		defer tfDestroyAndDeleteWorkspaceWithRetries(t, terraformOptions, tfcOrg, tfcToken, workspaceName, 3)
	}
	createTfcWorkspace(t, tfcOrg, tfcToken, workspaceName)
	os.Setenv("TF_WORKSPACE", workspaceName)
	terraform.Init(t, terraformOptions)
	if os.Getenv("GITHUB_ACTIONS") == "" {
		writeWorkspaceNameToTfDir(cwdPath, workspaceName)
	}
	terraform.ApplyAndIdempotent(t, terraformOptions)
	// Gather outputs
	vault_operator_raft_list_peers := terraform.Output(t, terraformOptions, "vault_operator_raft_list_peers")

	// Perform validation comparisons and collect pass/fail results
	_ = os.Unsetenv("TF_WORKSPACE")
	var testResults []bool

	// Check for the 5 peers
	for _, serverNum := range []string{"0", "1", "2", "3", "4"} {
		testResults = append(testResults, assert.Contains(t, vault_operator_raft_list_peers, fmt.Sprintf("%s-vault_%s", deployEnv, serverNum)))
	}

	// Comparisons complete; conditionally exit
	if os.Getenv("GITHUB_ACTIONS") == "" {
		if anyFalse(testResults) {
			logger.Log(t, "")
			logger.Log(t, "One or more tests failed; skipping terraform destroy")
			logger.Log(t, "You should either:")
			logger.Log(t, "1) Fix the Terraform code and re-run the tests until they pass and automatically invoke terraform destroy, or")
			logger.Log(t, "2) Run terraform destroy \"manually\", i.e. via ./destroy.sh")
			logger.Log(t, "")
		} else {
			if os.Getenv("TEST_DONT_DESTROY_UPON_SUCCESS") == "" {
				logger.Log(t, "")
				logger.Log(t, "All tests passed succesfully; proceeding to terraform destroy")
				logger.Log(t, "")
				os.Setenv("TF_WORKSPACE", workspaceName)
				terraform.Destroy(t, terraformOptions)
			} else {
				logger.Log(t, "")
				logger.Log(t, "Tests were successful, but skipping terraform destroy because TEST_DONT_DESTROY_UPON_SUCCESS environment variable is set")
				logger.Log(t, "")
			}
		}
	}
}
