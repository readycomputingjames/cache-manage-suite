#!/bin/bash
#########################################################################
# James Hipp
# System Support Engineer
# Ready Computing
#
# Main Bash script for Cache Manage Suite of Scripts
# This is a combo of Startup, Shutdown, and Restart
#
# We will already assume that Cache is installed on these Systems for now
#
# Our system OS use-case will be RHEL 7+ (or CentOS 7+)
#
# Usage = cache_manage.sh <start|stop|restart|status|help>
#
# Ex: ./cache_manage.sh start
# Ex: ./cache_manage.sh status
#
#
### CHANGE LOG ###
#
#
#########################################################################

input_command=$1

help()
{

   # Print Help Text
   echo "----------------------"
   echo "cache_manage.sh"
   echo "----------------------"
   echo ""
   echo "Usage:"
   echo "./cache_manage.sh <start|stop|restart|status|help>"
   echo ""
   echo "Examples:"
   echo "./cache_manage.sh start"
   echo "./cache_manage.sh status"
   echo ""

}

is_down()
{

   # Return False if any Instances show Running
   if [ "`sudo ccontrol list |grep running,`" ]
   then
      return 1
   else
      return 0
   fi

}

is_up()
{

   # Return False if any Instances show down
   if [ "`sudo ccontrol list |grep down,`" ]
   then
      return 1
   else
      return 0
   fi

}

stop_instances()
{

   # Load Instances into an Array, in case we have Multiple
   instances=()
   while IFS= read -r line; do
      instances+=( "$line" )
   done < <( sudo ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      sudo ccontrol stop $i quietly > /dev/null 2>&1
   done
   
  # Verify
   if is_down;
   then
      echo "All instances stopped successfully"
      echo ""  
   else
      echo "One or more instances do not show down, possible issue"
      echo ""
      return 1
   fi

}

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
   
   # Verify
   if is_up;
   then
      echo "Instances started successfully"
      echo ""
   else
      echo "Instances may not all have come up cleanly or at all"
      echo ""
      return 1
   fi

}

restart_instances()
{

   # Load Instances into an Array, in case we have Multiple
   instances=()
   while IFS= read -r line; do
      instances+=( "$line" )
   done < <( sudo ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      sudo ccontrol stop $i quietly restart > /dev/null 2>&1
   done

   # Verify
   if is_up;
   then
      echo "Instance restarted successfully"
      echo ""
   else
      echo "Possible error during restart, one or more instances do now show running"
      echo ""
      return 1
   fi

}

status()
{

   # Print List of Instances
   sudo ccontrol list

}

main ()
{

   # Parse out CLI Argument to see what we Need to do
   case $input_command in
      start)
         echo "Starting Instances Now"
         echo ""
         start_instances
      ;;
      stop)
         echo "Stopping Instances Now"
         echo ""
         stop_instances
      ;;
      restart)
         echo "Restarting Instances Now"
         echo ""
         restart_instances
      ;;
      status)
         echo "View Status of Instances"
         echo ""
         status
      ;;
      help)
         help
      ;;
      *)
         echo "$input_command = Not Valid Input"
         echo ""
   esac

}

main

