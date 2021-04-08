package test

import (
    "fmt"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/gruntwork-io/terratest/modules/http-helper"
    "testing"
    "time"
)

func TestAlbExample(t *testing.T) {
    opts := &terraform.Options{
        TerraformDir: "../../../examples/networking/alb",
    }

    // Clean up everything at the end of the test.
    // Ensure always run 'terraform.Destroy' even if the test fails.
    // Note that the defer is added early in the code, even before the call to terraform.InitAndApply,
    // to ensure that nothing can cause the test to fail before getting to the defer statement,
    // and preventing it from queueing up the call to terraform.Destroy.
    defer terraform.Destroy(t, opts)

    // Deploy the example
    terraform.InitAndApply(t, opts)

    // Get the URL of the ALB
    albDnsName := terraform.OutputRequired(t, opts, "alb_dns_name")
    url := fmt.Sprintf("http://%s", albDnsName)

    // Test that the ALB's default action is working and returns a 404
    expectedStatus := 404
    expectedBody := "404: page not found"

    maxRetries := 10
    timeBetweenRetries := 10 * time.Second

    http_helper.HttpGetWithRetry(
        t,
        url,
        nil,
        expectedStatus,
        expectedBody,
        maxRetries,
        timeBetweenRetries,
    )
}