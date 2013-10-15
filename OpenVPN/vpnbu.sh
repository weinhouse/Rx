#!/bin/bash

# /root/bin/vpnbu.sh

# Run cron as root
# 57 09,13,17 * * * /root/bin/vpnbu.sh

# vpnbu.sh copies the openvpn_as program directory excluding databases.
# It then dumps the database files and places them in the backup directory.
# It then copies Password, Group, and Shadow files since we use PAM for auth.

set -e
set -u

synckey="/root/.ssh/id_rsa"
busource="/usr/local/openvpn_as"
budir="/root/vpn_bu"
archivedir="vpn_archive"
dbfiles="certs.db config.db userprop.db log.db"
pgsfiles="passwd group shadow"
timestamp=$(date +%b%d_%I%M.%S%P_%Z)
archivefor=8
pidname="/tmp/"$(basename $0)".pid"
logfile="/var/log/openvpn_as.log"

DumpDbFiles () {
   for database in ${dbfiles}
   do
      "${busource}"/scripts/sqlite3 "${busource}"/etc/db/"${database}" \
          .dump > "${budir}"/"${database}".dump
      rm -f "${budir}"/$(basename "${busource}")/etc/db/"${database}"
      "${busource}"/scripts/sqlite3 < "${budir}"/"${database}".dump \
           "${budir}"/$(basename "${busource}")/etc/db/"${database}"
      chown root.root "${budir}"/$(basename "${busource}")/etc/db/"${database}"
   done
}

Copypgs () {
   for pgs in ${pgsfiles}
   do
      rm -f "${budir}"/"${pgs}" && cp /etc/"${pgs}" "${budir}"
   done
}

MakeArchive () {
   this_archive="${budir}/${archivedir}/$(basename ${busource})_${timestamp}"
   mkdir -p "${this_archive}"
   find "${budir}"/ -maxdepth 1 -type f -exec mv '{}' "${this_archive}" \;
   mv ""${budir}"/$(basename "${busource}")" "${this_archive}"
}

RemoveArchive () {
   count=0
   for archive in $(ls -t "${budir}"/"${archivedir}")
   do
      count=$((count + 1))
      if [ $count -gt "${archivefor}" ]; then
        rm -rf "${budir}"/"${archivedir}"/"${archive}"
      fi
   done
}

rotatelog () {
   lines=$(cat "${logfile}" | wc -l)
   # echo $lines
   if [ "${lines}" -gt 3000 ]; then
      cp -f "${logfile}" "${logfile}".1
      echo /dev/null > "${logfile}"
   fi
}

traperror () {
    printf "%s\n" \
           "[Error] ${timestamp}: script ${0} on ${HOSTNAME}" >> "${logfile}"
}
trap traperror ERR

# MAIN. . .

mkdir -p "${budir}"/"${archivedir}"

# Lock file
if [ -f ${pidname} ] && [ -d /proc/$(cat ${pidname}) ]; then
   printf "%s %s\n" \
           "[Error] ${timestamp}: script ${0} on ${HOSTNAME}"\
           "has been running for a long time please check"  >> "${logfile}"
   exit 0
else
   rm -f ${pidname}
fi
echo $$ > ${pidname}

# Check if there is a backup & Create a daily archive if not already done.
if [ -d ""${budir}"/$(basename "${busource}")" ] && \
! ls "${budir}/${archivedir}" | grep "_$(date +%b%d)_" >/dev/null 2>&1
then
   MakeArchive
fi

# Add a file with date stamp
rm -f "${budir}"/this_bu*
echo -e "Backup performed on $(hostname -f) \
         \nWhen: "${timestamp}"" > "${budir}/this_bu.${timestamp}"

# Backup the program directory excluding the running databases
/usr/bin/rsync -a --delete --exclude=*.db "${busource}" "${budir}"

DumpDbFiles

Copypgs

RemoveArchive

echo "[Success] "${timestamp}" running ${0} on ${HOSTNAME}" >> "${logfile}"

rotatelog

rm -f ${pidname}
