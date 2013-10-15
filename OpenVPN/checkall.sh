#!/bin/bash

# /root/bin/checkall.sh

# run cron as root
# 57 23 * * * /root/bin/checkall

# checkall will reach out and confirm that critical files are in sync.
     # passwd, group, shadow, certs.db.dump

chkpasswd=""
chkgroup=""
chkshadow=""
chkdb=""
tally=""
budir="/root/vpn_bu"
failure="no"
msgtxt="/tmp/msg.txt"
sshcmd="ssh -i /root/.ssh/id_rsa"
mailtowho="larry@rx4systems.com"
serverlist="vpn-backup.rx4systems.com vpn.west.rx4systems.com"

rm -f ${msgtxt}

for server in ${serverlist}
do
   ${sshcmd} "${server}" 'cat ${budir}/passwd' \
   | diff /etc/passwd - >> ${msgtxt}
   if [ $? -ne 0 ]; then
      chkpasswd="${chkpasswd} ${server}"
   fi

   ${sshcmd} "${server}" 'cat ${budir}/group' \
   | diff /etc/group - >> ${msgtxt}
   if [ $? -ne 0 ]; then
      chkgroup="${chkgroup} ${server}"
   fi

   ${sshcmd} "${server}" 'cat ${budir}/shadow' \
   | diff /etc/shadow - >> ${msgtxt}
   if [ $? -ne 0 ]; then
      chkshadow="${chkshadow} ${server}"
   fi

   ${sshcmd} "${server}" 'cat ${budir}/certs.db.dump' \
   | diff ${budir}/certs.db.dump - >> ${msgtxt}
   if [ $? -ne 0 ]; then
      chkdb="${chkdb} ${server}"
   fi
done

if [ -z "${chkpasswd}" ]; then
   tally="${tally} passwd" 
else
   failure="yes"
fi

if [ -z "${chkgroup}" ]; then
   tally="${tally} group" 
else
   failure="yes"
fi

if [ -z "${chkshadow}" ]; then
   tally="${tally} shadow" 
else
   failure="yes"
fi

if [ -z "${chkdb}" ]; then
   tally="${tally} certs.db" 
else
   failure="yes"
fi

if [ ${failure} == "yes" ]; then
   echo -e "passwd\tout of sync  on: ${chkpasswd}\
           \ngroup\tout of sync  on: ${chkgroup}\
           \nshadow\tout of sync on: ${chkshadow}\
           \ncerts\tout of sync on: ${chdb}\
           \n\nOutput from diffs on: "${serverlist}"\n$(cat ${msgtxt})" \
   | mail -s "$0 error files out of sync" ${mailtowho} 
   rm -f ${msgtxt}
else
   echo -e "Todays Logs\
           \n$(grep $(date +%b%e) /var/log/openvpn_as.log)" \
   | mail -s "$(echo "${tally} are all in sync")" ${mailtowho} 
   rm -f ${msgtxt}
fi
