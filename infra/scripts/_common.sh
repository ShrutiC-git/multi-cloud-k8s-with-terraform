#!/bin/bash

# This script is not meant to be executed directly.
# It provides a shared function for other scripts to use.

# run_tf_command <COMMAND> <DIRECTORY> <ENV>
# COMMAND: The terraform command to run (plan, apply, destroy)
# DIRECTORY: The target directory (e.g., ../aws)
# ENV: The environment (e.g., staging)
run_tf_command() {
    local command="$1"
    local dir="$2"
    local env="$3"
    local component_name
    component_name=$(basename "$dir")

    echo "### ${command}ing ${component_name} for environment: ${env} ###"

    # For 'global', the logic is simpler as it doesn't need dynamic backend init
    if [ "$component_name" == "global" ]; then
        terraform -chdir="$dir" init -reconfigure >/dev/null
        terraform -chdir="$dir" workspace select "$env" || terraform -chdir="$dir" workspace new "$env" >/dev/null
        
        if [ "$command" == "plan" ]; then
            terraform -chdir="$dir" plan -var-file="../global/${env}.tfvars" -out="${env}.tfplan"
        elif [ "$command" == "apply" ]; then
            terraform -chdir="$dir" apply -auto-approve "${env}.tfplan"
        elif [ "$command" == "destroy" ]; then
            terraform -chdir="$dir" destroy -var-file="../global/${env}.tfvars" -auto-approve
        fi
        return
    fi

    # For all other components, use the init script
    ./terraform-init.sh "$dir" "$env"

    if [ "$command" == "plan" ]; then
        terraform -chdir="$dir" plan -var-file="${env}.tfvars" -out="${env}.tfplan"
    elif [ "$command" == "apply" ]; then
        terraform -chdir="$dir" apply -auto-approve "${env}.tfplan"
    elif [ "$command" == "destroy" ]; then
        terraform -chdir="$dir" destroy -var-file="${env}.tfvars" -auto-approve
    fi
}
