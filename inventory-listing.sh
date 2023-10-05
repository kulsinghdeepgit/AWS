#!/bin/bash
regions='us-east-1 us-east-2 us-west-1 us-west-2' #### region where resources are present
names='infra-old infra-internal'       #### profile name as per your aws profile. Present in ~/.aws/config. Use below command to get the list
#  'cat ~/.aws/config | grep -i profile | grep -v "source_profile" | cut -d ' ' -f 2 | rev| cut -c 2- | rev'

touch output.log    #### creating output file

echo >  output.log  #### clearing output file before re-execution

####### getting user input for operation #######
echo "Choose the operation"
echo "1 for EC2-List"
echo "2 for IP-List"
echo "3 for RDS"
echo "4 for Redshift"
echo "5 for OenSearch(ES)"
echo "6 for Kafka"
echo "7 for DMS"
echo "8 for SFTP"
read oper
echo "Selected operation is $oper"

if [[ $oper < 9 ]]  ### condition check, exit if not a valid input 
then
###### reading regions ######
for region in $regions
  do
    ###### nested loop for profile to run on all provided regions #####
    for name in $names
      do
        echo crawling account: $name region: $region
if [[ $oper == 1 ]] 
then
###### EC2-List #######
          aws ec2 describe-instances --profile $name --region $region | jq -r '.Reservations[].Instances[] | .InstanceId + "," +  .InstanceType + "," +  .State.Name + "," + .PrivateIpAddress + "," + .LaunchTime + "," + .PlatformDetails + "," + .PublicDnsName + "," + .NetworkInterfaces[].OwnerId + "," + (.Tags[]|select(.Key=="Name").Value)?' >> output.log

elif [[ $oper == 2 ]] 
then
####### IPs #######
          aws ec2 describe-addresses --profile $name --region $region >> output.log

elif [[ $oper == 3 ]]
then
####### RDS #########
aws rds describe-db-instances --profile $name --region $region| jq -r '.DBInstances[] | .DBInstanceIdentifier +","+ .DBInstanceClass +","+ .Engine +","+ .DBInstanceStatus' >> output.log

elif [[ $oper == 4 ]]
then
####### Redshift ######
echo Below servers found in $name $region >>  output.log
aws redshift describe-clusters --profile $name --region $region| jq -r '.Clusters[] | .ClusterIdentifier +","+ .NodeType +","+ .ClusterStatus' >> output.log

elif [[ $oper == 5 ]]
then
###### OpenSearch ######
echo Below servers found in $name $region >>  output.log
aws es list-domain-names --profile $name --region $region| jq -r '.DomainNames[] | .DomainName'  >> output.log

elif [[ $oper == 6 ]]
then
###### Kafka ########
echo Below servers found in $name $region >>  output.log
aws kafka list-clusters-v2 --profile $name --region $region |  jq -r '.ClusterInfoList[] | .ClusterName' >> output.log
#### Kafka with tags ####
#aws kafka list-clusters-v2 --profile $name --region $region |  jq -r '.ClusterInfoList[] | .ClusterName +" "+ .State +" "+ (.Tags[]|select(.Key=="Env").Value)?' >> output.log

elif [[ $oper == 7 ]]
then
###### DMS ########
aws dms describe-replication-instances --profile $name --region $region |  jq -r '.ReplicationInstances[] | .ReplicationInstanceIdentifier +","+ .ReplicationInstanceClass +","+ .ReplicationInstanceStatus +","+ .AvailabilityZone  +","+ "\(.AllocatedStorage)" +","+ "\(.EngineVersion)" +","+ "\(.ReplicationInstancePrivateIpAddresses)"' >> output.log

elif [[ $oper == 8 ]]
then
###### SFTP ######
sftpserver=$(aws transfer list-servers --profile $name --region $region | grep -o "/s-.*" | cut -b 2-20) 
echo SFTP server found: $sftpserver in profile $name region $region >> output.log
#Listing users in SFTP
#for server in $sftpserver 
#do
#echo Finding user on SFTP server: $server >> output.log
#aws transfer list-users --server-id $server --profile $name --region $region | grep UserName | cut -b 26-50 | awk '{ print substr( $0, 1, length($0)-1 ) }' >>  output.log
#done

fi
  done
    done
else
	echo "not a valid operation"
fi
cat output.log  ### display file output