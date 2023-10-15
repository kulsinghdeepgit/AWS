#!/bin/bash
names='<proile name>'
for name in $names
do
echo $name >> aws-account-details
aws sts get-caller-identity --profile $name >> aws-account-details
done