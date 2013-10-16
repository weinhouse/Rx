#!/bin/bash

# mtr_check script, Check for packet loss using mtr
# keyfile for a days trend, multiple sites for accuracy
# archive some quantity of days

set -e
set -u

numberofarchives=20
destination="yahoo.com google.com cisco.com"
keyfile="rx_mtr.key"
tempfile="rx_mtr.tmp"
logfile="rx_mtr.log"
thedir="${HOME}/mtr_monitor/"
archivedir="archives/"
datetime=$(date "+%m%d %T")
dateonly=$(date "+%m%d")
pid="${thedir}/$(basename $0).pid"
mailtowho="larry@rx4systems.com"
PATH=${PATH}":/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"

# Trap on error
function myerror {
    echo "Error running $0 Script on $(hostname)" | \
          mail -s "Error running $0 Script" ${mailtowho} 
}
trap myerror ERR

function RemoveArchive {
   count=0
   for archive in $(ls -t "${thedir}""${archivedir}")
   do
      count=$((count + 1))
      if [ $count -gt "${numberofarchives}" ]
      then
         rm -f "${thedir}""${archivedir}""${archive}"
      fi
   done
}

# Add directories if necessary 
mkdir -p ${thedir}${archivedir}

# Check for existing lock file and create new one
if [ -f ${pid} ] && [ -d /proc/$(cat ${pid}) ]; then
      echo -e "\nThe $0 Script did not run because of existing lock file\n" | \
           mail -s "ERROR on ${HOSTNAME} running $0 Script" ${mailtowho} 
      exit 0
   else
      rm -f ${pid}
fi
echo $$ > ${pid}

# Archive if this is a new day
if [ -f "${thedir}${keyfile}" ]
then
   currentday=$(head -1 ${thedir}${keyfile} | awk '{print $1}')
   if [ ${dateonly} -ne ${currentday} ]
   then
      cat "${thedir}${logfile}" >> "${thedir}${keyfile}"
      mv -f "${thedir}${keyfile}" "${thedir}${logfile}"
      mv "${thedir}${logfile}" "${thedir}${archivedir}${logfile}.${dateonly}"
      gzip "${thedir}${archivedir}${logfile}.${dateonly}"
      RemoveArchive
   fi
fi
 
# Run reports multiple destinations
allthenumbers=""
for i in ${destination};
do
   echo -e "\nTo ${i} ${datetime}" > "/tmp/${tempfile}${i}"
   mtr --report ${i} >> "/tmp/${tempfile}${i}"
   thenumbers=$(cat "/tmp/${tempfile}${i}" | grep -v ^[A-Z] | cut -c35-39 | \
                grep -v ^$ | awk -F "." '{print $1}')
   allthenumbers="${allthenumbers} $(echo ${i} | cut -c 1-3)":${thenumbers}
   cat   "/tmp/${tempfile}${i}" >> "${thedir}${logfile}"
   rm -f "/tmp/${tempfile}${i}"
done

echo ${datetime}" "${allthenumbers} >> "${thedir}${keyfile}"

rm -f ${pid}
