# Data source to read the 'global' state, which contains backend info.
data "terraform_remote_state" "global" {
  backend = "local"

  config = {
    path = "../global/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
  }
}

# Data source to read the 'aws' state and get its outputs.
data "terraform_remote_state" "aws" {
  backend = "s3"

  config = {
    bucket = data.terraform_remote_state.global.outputs.aws_backend_bucket
    key    = "multicloud-k8s/aws/${terraform.workspace}.tfstate"
    region = var.aws_region # Assumes the bucket is in the same region
  }
}

# Data source to read the 'gcp' state and get its outputs.
data "terraform_remote_state" "gcp" {
  backend = "gcs"

  config = {
    bucket = data.terraform_remote_state.global.outputs.gcp_backend_bucket
    prefix = "multicloud-k8s/gcp/${terraform.workspace}"
  }
}