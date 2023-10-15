#!/bin/bash
#set -x
names='<aws profile name present in ~/.aws/config>'
for name in $names
do
echo $name >> psqlhosts
aws rds describe-db-instances --profile $name | grep "Address" >> psqlhosts
done