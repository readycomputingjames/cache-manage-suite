README File = Last Updated 20190807

James Hipp
System Support Engineer
Ready Computing

Main Bash script for Cache Manage Script Suite
This is a combo of Basic Functions and Tasks

This script assumes that the user running the script has OS
Auth enabled into Cache instance(s) and is %All role

Our system OS use-case will be RHEL 7+ (or CentOS 7+)

### CHANGE LOG ###
#
# [Version 1.00]
#
# 20190727 = Changed csession commands from root to script run user
# 20190729 = Added Auth-Enabled Flag
# 20190730 = Changed 'sudo ccontrol...' to '/usr/bin/ccontrol...'
# 20190730 = Changed 'csession...' to '/usr/bin/csession...'
#
# [Version 1.50]
#
# 20190805 = Added List-Namespaces  Flag
# 20190805 = Added Show-App-Errors Flag
# 20190806 = Added Journal-Status Flag
# 20190806 = Added Mirror-Status Flag
#

Script Usage Text

[jhipp@test-sbox cache-manage]$ ./cache_manage.sh --help

----------------------

cache_manage.sh

----------------------

Usage:

./cache_manage.sh <command(s)>, ...
 

Commands:

--add-user <username> <role> = Add an OS user account to Cache
--auth-enabled = Print out authentication settings for instance(s)
--cache-info = Display version and ISC product information for Cache
--del-user <username> = Delete an OS user account from Cache
--disable-user <username> = Disables a user account in Cache
--enable-user <username> = Enables a user account in Cache
--help = Show help notes for this script
--journal-status = Show current status for journal
--license = Show license usage and info
--list-namespaces = Show list of namespaces in database
--mirror-status = Show current mirror status
--restart = Restart all instances on this machine
--show-app-errors <namespace> = List application errors for a namespace
--show-log = Show console log warnings and errors
--start = Start all instances on this machine
--status = Show status of all instances on this machine
--stop = Stop all instances on this machine
--user-exists = Show if OS user account exists in Cache and is enabled
--version = Print out script version


Examples:

./cache_manage.sh --start

./cache_manage.sh --status

./cache_manage.sh --add-user jdoe %All


See Demo Usage Doc for More Examples

