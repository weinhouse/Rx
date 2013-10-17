#!/bin/bash

# myth_delete_rip script to rip a more compatable and compressed file
# and also delete the original.
# depends on http://www.mythtv.org/wiki/Delete_recordings.py, place in $bindir
# depends on http://www.mythtv.org/wiki/Mythname.pl, place in $bindir
# set up cron to run daily

set -e
set -u

thepath="/var/lib/mythtv/recordings"
ripdir="${thepath}/mp4s/TV"
bindir="${thepath}/bin"
curdate=$(date +%s)

PATH=$PATH:/usr/local/bin/

# Trap on error
function myerror {
   echo "Error running $0 Script on $(hostname)" | \
      cat "${thepath}/output.log" | mail -s "Error running $0 Script" \
      larry@rx4systems.com
}
trap myerror ERR

mkdir -p ${ripdir}

pushd ${thepath}
for line in $(ls *.mpg) ; do
   mdate=$(stat -c %Y "${line}")
   hmdate=$(stat -c %y "${line}" | awk '{print $1}')
   ageinsec=$((${curdate}-${mdate}))
   theshow=$(${bindir}/mythname.pl "${line}" | sed "s/ /_/g;s/'//g;s/*//g")
   filename=$(basename "${line}")
   # Rip the recording if older than one day
   if [ ${ageinsec} -gt 86400 ]
   then
      echo "Ripping ${theshow} ${filename}" > output.log
      rm -f "${ripdir}/${theshow}${hmdate}.mp4"
      ffmpeg -i "${filename}" -s 640x480 -c:v libx264 -profile:v baseline \
      "${ripdir}/${theshow}${hmdate}.mp4" 2>>output.log
      rm output.log
# Remove the recording using delete_recordings.py and Here Document
${bindir}//delete_recordings.py --basename="${filename}" << myheredoc
yes
myheredoc
   fi
done

# Change permissions in Rip Dir.
chmod 666 ${ripdir}/*
