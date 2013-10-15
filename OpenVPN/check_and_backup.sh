#!/bin/bash

# /root/bin/check_and_backkup.sh

# This script will place a copy of backed up files in /home/ubuntu
# to be used for backup it also runs a diff on password file on failover server.

current_archive=$(ls -tr /root/vpn_bu/vpn_archive/ | tail -1)
vpn_secondary="vpn-backup.rx4systems.com"

echo ""
echo "failover server is $vpn_secondary"
echo "hostname is $(ssh ${vpn_secondary} 'hostname')"

echo ""
echo "Running a diff on our password file and password file on vpn-secondary"
ssh ${vpn_secondary} 'cat /root/vpn_bu/passwd' | diff /etc/passwd - > \
   /tmp/${0}.tmp
if [ $(cat /tmp/${0}.tmp | wc -l) -gt 0 ]; then
   cat /tmp/${0}.tmp
   echo ""
   echo "Something is wrong password files are different"
   exit 1
fi
rm -f /tmp/$0.tmp
echo ""
echo "drop a copy of latest arcive into /home/ubuntu and change ownership"
echo "${current_archive}"

# Clean up the old backup
rm -rf /home/ubuntu/current_vpn_archive

rsync -av --del /root/vpn_bu/vpn_archive/${current_archive} \
   /home/ubuntu/current_vpn_archive > ${0}.log

mv ${0}.log /home/ubuntu/current_vpn_archive/
chown -R ubuntu.ubuntu /home/ubuntu/current_vpn_archive
