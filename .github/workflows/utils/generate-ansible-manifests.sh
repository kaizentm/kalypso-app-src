# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#!/bin/bash

# Usage:
# generate-ansible-manifests.sh FOLDER_WITH_MANIFESTS FOLDER_WITH_CONFIGS GENERATED_MANIFESTS_FOLDER

# Example:
# generate-ansible-manifests.sh "/ansible" "/configs" "/generated-manifests"

FOLDER_WITH_MANIFESTS=$1
FOLDER_WITH_CONFIGS=$2
GENERATED_MANIFESTS_FOLDER=$3

echo $FOLDER_WITH_MANIFESTS
echo $FOLDER_WITH_CONFIGS
echo $GENERATED_MANIFESTS_FOLDER

set -euo pipefail

export CONFIG_FILE="config.sh"

deployment_descriptor_file_name='deployment_descriptor.yaml'
deployment_descriptor_template='.github/workflows/utils/templates/deployment-descriptor-template.yaml'

mkdir -p $GENERATED_MANIFESTS_FOLDER

# Substitute env variables
# for file in `find $1 -type f \( -name "*.yml" \)`; do envsubst <"$file" > "$2/${file##*/}"; done
for file in `find $FOLDER_WITH_MANIFESTS -type f \( -name "*.yml" \)`; do envsubst <"$file" > "$file"1 && mv "$file"1 "$file"; done

cd $FOLDER_WITH_CONFIGS
for dir in `find . -type d \( ! -name . \)`; do
    # Generate manifests for every leaf folder with values.yaml
    # All values.yaml files in the path to the leaf folder are merged into one values.yaml
    if [ -z "$(find $dir -mindepth 1 -type d \( ! -name . \))" ] && [ -f $dir/$CONFIG_FILE ]; then
        manifests_dir=$GENERATED_MANIFESTS_FOLDER/$dir
        mkdir -p $manifests_dir   
        path=$dir
        while [[ $path != $FOLDER_WITH_CONFIGS ]];
        do                      
            # if there is any values.yaml in $path flush its content to manifests_dir
            if [ -f $path/$CONFIG_FILE ]; then
                touch $manifests_dir/$CONFIG_FILE
                cat $path/$CONFIG_FILE  $manifests_dir/$CONFIG_FILE  > tmp_val && cat tmp_val > $manifests_dir/$CONFIG_FILE && rm tmp_val
                echo >> $manifests_dir/$CONFIG_FILE
            fi            
            path="$(readlink -f "$path"/..)"
        done
        # # Generate manifests out of helm chart
        for file in `find $FOLDER_WITH_MANIFESTS -type f \( -name "*.yml" \)`; do envsubst <"$file" > "$manifests_dir/${file##*/}"; done        
        if [ $? -gt 0 ]
          then
            echo "Could not render manifests"
            exit 1
        fi

        pushd $manifests_dir 
        popd

        # # Generate deployment descriptor
        # commented out for now as it's not used so far
        # # take the last part from the manifests_dir path e.g. vsu from /home/runner/work/rs-dispatcher-framework-src/rs-dispatcher-framework-src/manifests/./vsu
        deployment_target=$(echo $manifests_dir | rev | cut -d'/' -f1 | rev)
        
        mkdir -p $manifests_dir/descriptor
        $GITHUB_WORKSPACE/.github/workflows/utils/generate-deployment-descriptor.sh  $deployment_target $manifests_dir/descriptor/$deployment_descriptor_file_name $GITHUB_WORKSPACE/$deployment_descriptor_template

    fi
done