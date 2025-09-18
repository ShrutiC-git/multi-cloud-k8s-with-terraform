#!/bin/bash
set -e

# This script initializes a Terraform directory (aws, gcp, dns)
# by dynamically configuring its backend using outputs from the 'global' state.

DIR="$1"
ENV="$2"

if [ -z "$DIR" ]; then
    echo "Usage: $0 <directory> <environment>"
    echo "Example: $0 ../aws staging"
    exit 1
fi

if [ ! -d "$DIR" ]; then
    echo "Error: Directory '$DIR' not found."
    exit 1
fi

if [ -z "$ENV" ]; then
    echo "Error: Environment not specified."
    echo "Usage: $0 <directory> <environment>"
    exit 1
fi

echo "--- Initializing Terraform in $DIR for environment: $ENV ---"

# Read all outputs from the global state file in a single command
GLOBAL_OUTPUTS=$(terraform -chdir=../global output -state="terraform.tfstate.d/$ENV/terraform.tfstate" -json)

# Use a tool like 'jq' to parse the JSON and populate shell variables
AWS_BUCKET=$(echo "$GLOBAL_OUTPUTS" | jq -r '.aws_backend_bucket.value')
AWS_LOCK_TABLE=$(echo "$GLOBAL_OUTPUTS" | jq -r '.aws_backend_lock_table.value')
GCP_BUCKET=$(echo "$GLOBAL_OUTPUTS" | jq -r '.gcp_backend_bucket.value')

# Validate that the outputs were successfully parsed
if [ -z "$AWS_BUCKET" ] || [ -z "$AWS_LOCK_TABLE" ] || [ -z "$GCP_BUCKET" ]; then
    echo "Error: Failed to parse backend configuration from global state."
    echo "Please ensure the 'global' component for environment '$ENV' has been applied successfully."
    exit 1
fi

# Use -chdir for consistency with other scripts instead of cd
if [ "$DIR" == "../aws" ]; then
    terraform -chdir="$DIR" init -reconfigure \
        -backend-config="bucket=$AWS_BUCKET" \
        -backend-config="dynamodb_table=$AWS_LOCK_TABLE" \
        -backend-config="key=multicloud-k8s/aws/$ENV.tfstate"
elif [ "$DIR" == "../gcp" ]; then
    terraform -chdir="$DIR" init -reconfigure \
        -backend-config="bucket=$GCP_BUCKET" \
        -backend-config="prefix=multicloud-k8s/gcp/$ENV"
elif [ "$DIR" == "../dns" ]; then
    # The 'dns' component also uses the AWS S3 backend for its own state.
    terraform -chdir="$DIR" init -reconfigure \
        -backend-config="bucket=$AWS_BUCKET" \
        -backend-config="dynamodb_table=$AWS_LOCK_TABLE" \
        -backend-config="key=multicloud-k8s/dns/$ENV.tfstate"
else
    terraform -chdir="$DIR" init -reconfigure
fi
