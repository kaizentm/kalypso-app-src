#!/bin/bash

# Usage:
#   get-tracking-info.sh


# Reads the tracking information (PROMOTED_COMMIT_ID, IMAGE_NAME) from the .github/tracking folder and 
# "promoted" label from the GitOps PR
# Sets the environment variables for the GitHub Actions workflow to use.

PROMOTED_COMMIT_ID=$(cat .github/tracking/Promoted_Commit_Id)
echo "PROMOTED_COMMIT_ID=$PROMOTED_COMMIT_ID" >> $GITHUB_ENV

IMAGE_NAME=$(cat .github/tracking/Image_name)
echo "IMAGE_NAME=$IMAGE_NAME" >> $GITHUB_ENV  

promoted=$(gh pr list --search $COMMIT_ID --state merged --label promoted)
if [[ -z "$promoted" ]]; then
    PROMOTION='n'
    echo "PROMOTION=$PROMOTION" >> $GITHUB_ENV
fi         
