#!/bin/bash

badhops=$1

echo "lines with more than ${badhops:=1} bad hops"

while read line
do
   for i in $(echo ${line} | cut -c16- | sed s/[0-9a-z.]*://g)
      do
         if [ ${i} -gt 0 ]
         then
            let counter=counter+1
         fi
      done
if [ ${counter} -gt ${badhops:=1} ]
then
   echo ${line}
fi
counter=0
done < mtr_monitor/hollywood.key
