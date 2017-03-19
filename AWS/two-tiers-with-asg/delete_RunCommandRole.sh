#!/bin/bash

export ROLE_NAME=RunCommandRole

echo "Remove all instance-profile which use role $ROLE_NAME..."
for INSTANCE_PROFILE_NAME in $(aws iam list-instance-profiles-for-role --role-name $ROLE_NAME --query "InstanceProfiles[].{InstanceProfileName:InstanceProfileName}" --output text)
do
    echo "Removing instance profile : $INSTANCE_PROFILE_NAME"
    aws iam remove-role-from-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME --role-name $ROLE_NAME
    aws iam delete-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME
done

echo "Detach role $ROLE_NAME from all policies..."
aws iam delete-role --role-name $ROLE_NAME

echo "Done"