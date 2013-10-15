#!/bin/bash
# /home/ubuntu/bin/useradd.sh

# Used to add VPN users, and add a comment in /etc/passwd
# Must have pwgen installed

set -e
set -u

if [ "$#" -ne 1 ] || echo $1 | grep -i .*help >/dev/null 2>&1 || \
echo $1 | grep -i [-]h$ >/dev/null 2>&1; then
   echo -e "\nUsage# $0 <username>\n"
   exit 1
fi
 
the_user=$1
the_pw=$(pwgen 8 -cnyB 1)

# NOTE! There must be a space before first OU entry
OUs=" OU-1, OU-2, OU-3, etc, etc,"

if grep ^"${the_user}:" /etc/passwd > /dev/null 2>&1; then
   echo -e "\nUser already exists"
   grep ^"${the_user}:" /etc/passwd
   exit 1
fi

# Ask to enter an OU
printf "\n%s\n\n%s\n\n" \
"Please enter an OU for $the_user, this will be entered in /etc/passwd" \
"Options:${OUs}" \

echo -n "# "
read comment

# Check for typo or no entry
if ! echo "${OUs}" | grep " ${comment}," > /dev/null 2>&1; then
   echo -e "\nYou did not enter an OU or there was a typo\n"
   exit 1
fi

# Add user and change password
sudo useradd -N ${the_user}
echo "${the_user}:${the_pw}" | sudo chpasswd

# Enter Comment into password file chfn -o
sudo chfn -o "${comment}" ${the_user}

# Print out confirmation
printf "\n%s\n%s\n%s\n" \
"User has been added:" \
"$(grep ^"${the_user}:" /etc/passwd)" \
"Username = ${the_user} Password = ${the_pw}"
