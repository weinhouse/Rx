#!/bin/bash

# /root/failover.sh (Run as Root)

# Run on failover server to copy files that have synced from active server.

set -e

pushd /root

if [ -d vpn_bu ]; then
   cp /etc/passwd /etc/passwd.org
   cp /etc/group /etc/group.org
   cp /etc/shadow /etc/shadow.org
   cp vpn_bu/passwd /etc/passwd
   cp vpn_bu/group /etc/group
   cp vpn_bu/shadow /etc/shadow
   /etc/init.d/openvpnas stop
   cp /usr/local/openvpn_as/etc/db/certs.db /usr/local/openvpn_as/etc/db/certs.db.org
   cp vpn_bu/openvpn_as/etc/db/certs.db /usr/local/openvpn_as/etc/db/certs.db
   /etc/init.d/openvpnas start
else
  exit 1
fi
