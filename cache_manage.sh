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
# Usage = cache_manage.sh <command>
#
# Ex: ./cache_manage.sh --start
# Ex: ./cache_manage.sh --status
#
# (See Help Function for Full Usage Notes)
#
#
### CHANGE LOG ###
#
#
#########################################################################

INPUT_COMMAND1=$1
INPUT_COMMAND2=$2
INPUT_COMMAND3=$3

add_user()
{

   if [ -z "$INPUT_COMMAND3" ]
   then
      echo "No User Role Input - Please Run Again with a Role Specified"
      echo ""

   else
      if os_user_exists && cache_user_exists;
      then

         # Load Instances into an Array, in case we have Multiple
         instances=()
         while IFS= read -r line; do
            instances+=( "$line" )
         done < <( sudo ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

         for i in ${instances[@]};
         do
            sudo su - root -c "echo -e 's x=##Class(Security.Users).Create(\"$INPUT_COMMAND2\",\"$INPUT_COMMAND3\",\"CHANGEPASSWORDHERE\",\"$INPUT_COMMAND2\",\"%SYS\")\nh' |csession $i -U %SYS > /dev/null 2>&1"
         done

         echo "Checking if Add was Successful..."
         echo ""

         if ! cache_user_exists;
            then
               echo "User added Successfully"
               echo ""
            else
               echo "User was not added Successfully, please check manually"
               echo ""
               return 1
         fi

      else
         echo "Requirements are not met to add new User, nothing to do..."
         echo ""
      fi

   fi

}

cache_user_exists()
{

   ### Check if User Exists in Cache ###

   if [ -z "$INPUT_COMMAND2" ]
   then
      echo ""
      echo "No User ID Input - Please Run Again with a User ID"
      echo ""

   else
      # Load Instances into an Array, in case we have Multiple
      instances=()
      while IFS= read -r line; do
         instances+=( "$line" )
      done < <( sudo ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

      for i in ${instances[@]};
      do
         output=`sudo su - root -c "echo -e 'w ##class(Security.Users).Exists(\"$INPUT_COMMAND2\")\nh' |csession $i -U %SYS |awk NR==5"`
         if [ $output -eq  1 ]
         then
            echo ""
            echo "User Exists in Cache"
            echo ""
            return 1
         else
            echo ""
            echo "User Does not Exist in Cache"
            echo ""
            return 0
         fi
      done

   fi

}

del_user()
{

   echo "placeholder"

}

help_text()
{

   # Print Help Text
   echo "----------------------"
   echo "cache_manage.sh"
   echo "----------------------"
   echo ""
   echo "Usage:"
   echo "./cache_manage.sh <command(s)>, ..."
   echo ""
   echo "Commands:"
   echo "--add-user <username> <role> = Add an OS user account to Cache"
   echo "--del-user <username> = Delete an OS user account from Cache"
   echo "--help = Show help notes for this script"
   echo "--restart = Restart all instances on this machine"
   echo "--show-log = Show log warnings and errors"
   echo "--start = Start all instances on this machine"
   echo "--status = Show status of all instances on this machine"
   echo "--stop = Stop all instances on this machine"
   echo "--user-exists = Show if OS user account exists in Cache"
   echo ""
   echo "Examples:"
   echo "./cache_manage.sh --start"
   echo "./cache_manage.sh --status"
   echo "./cache_manage.sh --add-user jdoe %All"
   echo ""

}

is_cache()
{

   ### Check if Cache is Installed ###

   if [ "`sudo ccontrol list`" ]
   then
      return 0
   else
      echo "Cache is not Installed, exiting..."
      echo ""
      return 1
   fi

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

os_user_exists()
{

   ### Check if User Exists on the OS ###

   if [ -z "$INPUT_COMMAND2" ]
   then
      echo "No User ID Input - Please Run Again with a User ID"
      echo ""

   else
      if [ "`getent passwd $INPUT_COMMAND2`" ]
      then
         return 0
      else
         echo "User does not exist in the OS, exiting..."
         echo ""
         return 1
      fi

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

show_log()
{

   echo "placeholder"

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

status_text()
{

   # Print List of Instances
   sudo ccontrol list

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

user_exists()
{


   if [ -z "$INPUT_COMMAND2" ]
   then
      echo ""
      echo "No User ID Input - Please Run Again with a User ID"
      echo ""

   else
      if cache_user_exists;
      then
         echo ""
         echo "$INPUT_COMMAND2 User Account does Exist in Cache"
         echo ""

      else
         echo ""
         echo "$INPUT_COMMAND2 Does Not Exist in Cache"
         echo ""
      fi

   fi

}

main ()
{

   if is_cache;
   then

      # Parse out CLI Argument to see what we Need to do
      case $INPUT_COMMAND1 in
         --add-user)
            echo "Add User Goes Here"
            ;;
         --del-user)
            echo "Del User Goes Here"
            ;;
         --help)
            help_text
         ;;
         --restart)
            echo ""
            echo "Restarting Instances Now"
            echo ""
            restart_instances
         ;;
         --show-log)
            show_log
         ;;
         --start)
            echo ""
            echo "Starting Instances Now"
            echo ""
            start_instances
         ;;
         --status)
            echo ""
            echo "--------------------"
            echo "Status of Instances"
            echo "--------------------"
            status_text
            echo ""
         ;;
         --stop)
            echo ""
            echo "Stopping Instances Now"
            echo ""
            stop_instances
         ;;
         --user-exists)
            cache_user_exists
         ;;
         *)
            echo "$INPUT_COMMAND1 = Not Valid Input"
            echo ""
      esac

   else
      echo ""
      echo "Cache is not Installed, ... Exiting"
      echo ""

   fi

}

main

