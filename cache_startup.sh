#!/bin/bash
#########################################################################
# James Hipp
# System Support Engineer
# Ready Computing
#
# Bash script to start Cache instances on boot
# Can add other startup tasks for Cache if needed
#
# Since this is a startup script, we will assume Cache is installed
#
# Cache instances do no start automatically on boot
#
# Our system OS use-case will be RHEL 7+ (or CentOS 7+)
#
# Usage = cache_startup.sh
# Ex: ./cache_startup.sh
#
#
### CHANGE LOG ###
#
#
#########################################################################

start_instances()
{

   # Load Instances into an Array, in case we have Multiple
   instances=()
   while IFS= read -r line; do
      instances+=( "$line" )
   done < <( sudo ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      sudo ccontrol start $i > /dev/null 2>&1
   done

}

is_up()
{

   # Load Instances into an Array, in case we have Multiple
   instances=()
   while IFS= read -r line; do
      instances+=( "$line" )
   done < <( sudo ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      
   done

}

main()
{



}



