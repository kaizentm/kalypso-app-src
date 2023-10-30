#!/bin/bash

# Usage:
# generate-deployment-descriptor.sh DEPLOYMENT_TARGET OUTPUT_FILE TEMPLATE_FILE

export DEPLOYMENT_TARGET=$1
OUTPUT_FILE=$2
TEMPLATE_FILE=$3

echo $DEPLOYMENT_TARGET
echo $OUTPUT_FILE
echo $TEMPLATE_FILE


set -eo pipefail

envsubst <"$TEMPLATE_FILE" > "$OUTPUT_FILE"



