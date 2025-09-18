#!/bin/bash
set -e

# Source the common helper function
source ./_common.sh

ENV="$1"
if [ -z "$ENV" ]; then
    echo "Usage: $0 <environment>"
    echo "Example: $0 staging"
    exit 1
fi

TF_VARS_FILE="../global/${ENV}.tfvars"
if [ ! -f "$TF_VARS_FILE" ]; then
    echo "Error: Variables file not found for environment '$ENV' at '$TF_VARS_FILE'"
    exit 1
fi

run_tf_command "apply" "../global" "$ENV"
run_tf_command "apply" "../aws" "$ENV"
run_tf_command "apply" "../gcp" "$ENV"
run_tf_command "apply" "../dns" "$ENV"

echo "-------------------------------------"
echo "All modules for '$ENV' applied successfully."
echo "-------------------------------------"
