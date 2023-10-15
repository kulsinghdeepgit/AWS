#!/bin/bash
LogLocation="/var/log/elasticsearch/"
#Comress logs older than 2 days
find $LogLocation  -type f ! -name '*.gz' -mtime +1 -exec gzip "{}" \;   
sleep 2
#Deleting files older than 15 days
find $LogLocation -name "*.gz" -type f -mtime +15 -exec rm -f {} \;