terraform {
  backend "s3" {
    # bucket and dynamodb_table are configured via -backend-config
    # Example key: multicloud-k8s/dns/staging.tfstate
    region         = "ap-south-1" # This must be a static value.
    encrypt        = true
  }
}