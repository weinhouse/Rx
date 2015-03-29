Rx
==

```This is a very long line that will still be quoted properly when it wraps. Oh boy let's keep writing to make sure this is long enough to actually wrap for everyone. Oh, you can *put* **Markdown** into a blockquote.```

---

![weinhouse](http://www.weinhouse.com/family.gif "go weinhouse")

Rx Various Scripts etc.

* try
* this
* one

```
have a nice day
this is some
```

~~don't want this any more~~

1. one
2. two
  * sub
  * sub2
    * and more
3. hoho
4. hehe

visit [weinhouse.com](http://www.weinhouse.com) and you will be happy

If you run the command `ls -l` you will get a long listing

```sh
#!/bin/bash
# $Header: /home/larryw/bin/BURsync,v 1.18 2013/12/16 02:43:18 larryw Exp $
# NOTE! This script depends on having KeyChain Installed so you can source your
#       ssh-key for Remote Passwordless Login, AutoSource variable below.
# rsync files from local machine to: $local_fs|$lan_fs|$remote_fs
# archive dir created each time there are changes or deletions If yes argument used
# to remove old archives copy clean_archives to $archive_dir and run it!
# Logs will be mailed and then cleared weekley.
# Add cron to run this script every day. - 1 0 * * * /PathToThisScript

BwLimit=30 #KBPS
mylog="/home/larryw/larrybu.log"
mailtowho="larry@weinhouse.com"
remote_fs="escondido.lanaicityrental.com"
lan_fs="192.168.100.250"
local_fs="localhost"
pid="/home/larryw/rsync.pid"
AutoSource="/home/larryw/.keychain/Friar-sh"

print_header () {
echo -e "\n=============================================="     >> $2
echo      "$1 $(date)"                                         >> $2
echo      "=============================================="     >> $2
 }
errors=""
err_check () {
if [ $? -gt 0 ]; then
   errors="$errors $1"
fi
}
MyBu () {
from_path=$1
to_path=$2
filesystem_to=$3
archive_yes_no=$4

archive_dir="${to_path}Archives_/"
```
| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| One           | center        | right |
| Wow           | hehe          | ab
