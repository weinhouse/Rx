#!/bin/bash

# Good idea to have these items in all important scripts:

# set comments are to exit on errors, and error on undefined veriables.
# traperror function can log or send email just edit what you like
# lock checks for lock file and /proc directory if there is orphan lock file

set -e
set -u

logfile="/var/log/<The Log File Name>"
timestamp=$(date +%b%d_%I%M.%S%P_%Z)
pidname="/tmp/"$(basename $0)".pid"

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

# < Your Script Goes Here
# . . .
# . . . >

rm -f ${pidname}

exit 0
