#!/bin/bash

# /home/ubuntu/bin/listusers.sh

# Script used to produce some useful output from passwd file.

pwfile="/etc/passwd"

echo "Regular users with GroupID 100"
while read line
do
   myuid=$(echo ${line} | awk -F ":" '{print $3}')
   mygid=$(echo ${line} | awk -F ":" '{print $4}')
   if [ ${mygid} -eq 100 ] && [ ${myuid} -ge 1000 ]
   then
      echo "${line}" | awk -F ":" '{print $1"\t\t"$5}' | sed s/,//g
   fi
done  < ${pwfile} | sort

echo ""
echo "Regular users who do not have GroupID 100" 
while read line
do
   myuid=$(echo ${line} | awk -F ":" '{print $3}')
   mygid=$(echo ${line} | awk -F ":" '{print $4}')
   if [ ${mygid} -ne 100 ] && [ ${myuid} -ge 1000 ]
   then
      echo "${line}" | awk -F ":" '{print $1"\t\t"$5}' | sed s/,//g
   fi
done  < ${pwfile} | sort
