NOTE!! there is a script bin/vpn_useradd  (This is best way to add a user)
       or below are manual Instructions :- )

Add user with the following command USE -N to place user in correct group.
sudo useradd -N <Username>

There is a custom /etc/default/useradd file
Places in user group 100
Gives user /bin/false for a shell

There is an alias "passgen" in .bashrc for generating password
alias passgen='pwgen -cnyB 8 8'

To add comments in /etc/passwd
sudo chfn -o <GECOS Comment> akronlage

There is a script to create report of users on system:
~/bin/vpn_listusers
