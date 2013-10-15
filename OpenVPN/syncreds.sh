#!/bin/bash

# /root/bin/syncreds.sh

# run cron as root
# 57 10,14,18 * * * /root/bin/syncreds "vpn-backup.rx4systems.com.com"
# 57 11,15,19 * * * /root/bin/syncreds "vpn.west.rx4systems.com"

# syncreds script, will syncronize the most current backup to a failover server.

set -e
set -u

rsynccmd="/usr/bin/rsync"
synckey="/root/.ssh/id_rsa"
budir="/root/vpn_bu"
archivedir="vpn_archive"
logfile="/var/log/openvpn_as.log"
timestamp=$(date +%b%d_%I%M.%S%P_%Z)
pidname="/tmp/"$(basename $0)".pid"
failserver="${1:?"Should run from cron, needs failover server as an argument"}"

traperror () {
    printf "%s\n" \
           "[Error] ${timestamp}: script ${0} on ${HOSTNAME}" >> "${logfile}"
}
trap traperror ERR

# Check for and create lock file
if [ -f ${pidname} ] && [ -d /proc/$(cat ${pidname}) ]; then
   printf "%s %s\n" \
           "[Error] ${timestamp}: script ${0} on ${HOSTNAME}"\
           "Job has been running for a long time please check"  >> "${logfile}"
   exit 0
else
   rm -f ${pidname}
fi
echo $$ > ${pidname}

${rsynccmd} -aL -e "ssh -i ${synckey}" "${budir}" --exclude "${archivedir}" \
--delete root@"${failserver}":/root

rm -f ${pidname}

exit 0
