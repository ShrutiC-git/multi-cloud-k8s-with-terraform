terraform {
    backend "gcs" {
        # bucket and prefix are configured via -backend-config
        # Example prefix: multicloud-k8s/gcp/staging
        # gcs is regional, so unlike aws, we don't pass the region here.
    }
}