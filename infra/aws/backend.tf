terraform {
    backend "s3" {
        # bucket, dynamodb_table, and key are configured via -backend-config
        # Example key: multicloud-k8s/aws/staging.tfstate
        region = "ap-south-1" # This must be a static value. Must match where the global backend has been described.
        encrypt = true
    }
}