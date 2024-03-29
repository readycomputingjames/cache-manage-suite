#!/bin/bash
#########################################################################
# James Hipp
# System Support Engineer
# Ready Computing
#
# Main Bash script for Cache Manage Script Suite
# This is a combo of Basic Functions and Tasks
#
# This script assumes that the user running the script has OS
# Auth enabled into Cache instance(s) and is %All role
#
# Our system OS use-case will be RHEL 7+ (or CentOS 7+)
#
# Usage = cache_manage.sh <command>
#
# Ex: ./cache_manage.sh --help
# Ex: ./cache_manage.sh --start
# Ex: ./cache_manage.sh --status
#
# (See Help Function for Full Usage Notes)
#
#
### CHANGE LOG ###
#
# [Version 2.00]
#
# 20190807 = Add Enable-User and Disable-User Functions
# 20190807 = Add User Enabled/Disabled Text to User-Exists Flag
#
#########################################################################

VERSION="2.00"

INPUT_COMMAND1=$1
INPUT_COMMAND2=$2
INPUT_COMMAND3=$3

add_user()
{

   if [ -z "$INPUT_COMMAND3" ]
   then
      echo ""
      echo "No User Role Input - Please Run Again with a Role Specified"
      echo ""

   else
      if os_user_exists;
      then

         echo ""
         echo "--------------------"
         echo "Running Add-User for $INPUT_COMMAND2"
         echo ""
         echo "If the User Already Exists, it will be Skipped..."
         echo "--------------------"
         echo ""

         # Load Instances into an Array, in case we have Multiple
         instances=()
         while IFS= read -r line; do
            instances+=( "$line" )
         done < <( /usr/bin/ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

         for i in ${instances[@]};
         do

            output=`echo -e "w ##class(Security.Users).Exists(\"$INPUT_COMMAND2\")\nh" |/usr/bin/csession $i -U %SYS |awk NR==5`

            if [ $output -eq 0 ]
            then
               echo -e "s x=##Class(Security.Users).Create(\"$INPUT_COMMAND2\",\"$INPUT_COMMAND3\",\"CHANGEPASSWORDHERE\",\"$INPUT_COMMAND2\")\nh" |/usr/bin/csession $i -U %SYS > /dev/null 2>&1
            else
               echo "Username $INPUT_COMMAND2 Already Exists in $i"
               echo ""
            fi

         done

         echo "Verifying Usernames in Cache..."

         cache_user_exists

      else
         echo "Requirements are not met to add new User, nothing to do..."
         echo ""
      fi

   fi

}

auth_enabled()
{

   ### Print Out Enabled Authentication Settings for Instances ###

   # Load Instances into an Array, in case we have Multiple
   instances=()
   while IFS= read -r line; do
      instances+=( "$line" )
   done < <( /usr/bin/ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      echo ""
      echo "Printing Enabled Authentication for $i"
      echo ""
      echo -e "w ##class(Security.System).AutheEnabledGetStored(\"SYSTEM\")\nh" |/usr/bin/csession $i -U %SYS |awk NR==5
   done

   echo ""
   echo "--------------------"
   echo "Authentication Bits:"
   echo "--------------------"
   echo "Bit 0 = AutheK5CCache"
   echo "Bit 1 = AutheK5Prompt"
   echo "Bit 2 = AutheK5API"
   echo "Bit 3 = AutheK5KeyTab"
   echo "Bit 4 = AutheOS"
   echo "Bit 5 - AutheCache"
   echo "Bit 6 = AutheUnauthenticated"
   echo "Bit 7 = AutheKB"
   echo "Bit 8 = AutheKBEncryption"
   echo "Bit 9 = AutheKBIntegrity"
   echo "Bit 10 = AutheSystem"
   echo "Bit 11 = AutheLDAP"
   echo "Bit 12 = AutheLDAPCache"
   echo "Bit 13 = AutheDelegated"
   echo "Bit 14 = LoginToken"
   echo "Bit 15-19 reserved"
   echo "Bit 20 = TwoFactorSMS"
   echo "Bit 21 = TwoFactorPW"
   echo ""

}

cache_info()
{

   # Display Info About Cache

   # Load Instances into an Array, in case we have Multiple
   instances=()
   while IFS= read -r line; do
      instances+=( "$line" )
   done < <( /usr/bin/ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      echo ""
      echo "------------------------------"
      echo "Cache Info for $i:"
      echo ""
      echo -e "w ##class(%SYSTEM.Version).GetVersion()\nh" |/usr/bin/csession $i -U %SYS |awk NR==5
      echo ""

      ### ISC Product: Cache = 1, Ensemble = 2, HealthShare = 3
      product=`echo -e "w ##class(%SYSTEM.Version).GetISCProduct()\nh" |/usr/bin/csession $i -U %SYS |awk NR==5`
      case $product in
         1)
            echo "Installed ISC Product = Cache"
            ;;
         2)
            echo "Installed ISC Product = Ensemble"
         ;;
         3)
            echo "Installed ISC Product = HealthShare"
         ;;
         *)
            echo "Unable to Fetch Installed ISC Product Number"
      esac

      echo ""

   done

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
      done < <( /usr/bin/ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

      for i in ${instances[@]};
      do
         output=`echo -e "w ##class(Security.Users).Exists(\"$INPUT_COMMAND2\")\nh" |/usr/bin/csession $i -U %SYS |awk NR==5`

         if [ $output -eq  1 ]
         then
            echo ""
            echo "User $INPUT_COMMAND2 Exists in Cache for $i"
         else
            echo ""
            echo "User $INPUT_COMMAND2 Does not Exist in Cache for $i"
         fi
      done

      echo ""

   fi

}

del_user()
{

   if [ -z "$INPUT_COMMAND2" ]
   then
      echo ""
      echo "No Username Input - Please Run Again with a Username Specified"
      echo ""

   else
      echo ""
      echo "--------------------"
      echo "Running Delete-User for $INPUT_COMMAND2"
      echo ""
      echo "If Username is not in Cache, it will be Skipped..."
      echo "--------------------"
      echo ""

      # Load Instances into an Array, in case we have Multiple
      instances=()
      while IFS= read -r line; do
         instances+=( "$line" )
      done < <( /usr/bin/ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

      for i in ${instances[@]};
      do

         output=`echo -e "w ##class(Security.Users).Exists(\"$INPUT_COMMAND2\")\nh" |/usr/bin/csession $i -U %SYS |awk NR==5`

         if [ $output -eq 1 ]
         then
            echo -e "s x=##Class(Security.Users).Delete(\"$INPUT_COMMAND2\")\nh" |/usr/bin/csession $i -U %SYS > /dev/null 2>&1
         else
            echo "Username $INPUT_COMMAND2 Does Not Exist in $i"
            echo ""
         fi

         done

         echo "Verifying Updated Usernames in Cache..."

         cache_user_exists

   fi

}

disable_user()
{

   echo "placeholder"
   
}

enable_user()
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
   echo "cache_manage.sh <command(s)>, ..."
   echo ""
   echo "Commands:"
   echo "--add-user <username> <role> = Add an OS user account to Cache"
   echo "--auth-enabled = Print out authentication settings for instance(s)"
   echo "--cache-info = Display version and ISC product information for Cache"
   echo "--del-user <username> = Delete an OS user account from Cache"
   echo "--disable-user <username> = Disables a user account in Cache"
   echo "--enable-user <username> = Enables a user account in Cache"
   echo "--help = Show help notes for this script"
   echo "--journal-status = Show current status for journal"
   echo "--license = Show license usage and info"
   echo "--list-namespaces = Show list of namespaces in database"
   echo "--mirror-status = Show current mirror status"
   echo "--restart = Restart all instances on this machine"
   echo "--show-app-errors <namespace> = List application errors for a namespace"
   echo "--show-log = Show console log warnings and errors"
   echo "--start = Start all instances on this machine"
   echo "--status = Show status of all instances on this machine"
   echo "--stop = Stop all instances on this machine"
   echo "--user-exists = Show if OS user account exists in Cache and is enabled"
   echo "--version = Print out script version"
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

   if [ -e "/usr/bin/ccontrol" ]
   then
      return 0
   else
      return 1
   fi

}

is_down()
{

   # Return False if any Instances show Running
   if [ "`/usr/bin/ccontrol list |grep running,`" ]
   then
      return 1
   else
      return 0
   fi

}

is_up()
{

   # Return False if any Instances show down
   if [ "`/usr/bin/ccontrol list |grep down,`" ]
   then
      return 1
   else
      return 0
   fi

}

journal_status()
{

   # Display Current Journal Status

   # Load Instances into an Array, in case we have Multiple
   instances=()
   while IFS= read -r line; do
      instances+=( "$line" )
   done < <( /usr/bin/ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      echo ""
      echo "------------------------------"
      echo "Current Journal Status for $i:"
      echo ""
      /usr/bin/csession $i -U %SYS "Status^JOURNAL"
      echo ""
      echo ""
   done

   echo ""

}

license_usage()
{

   # Load Instances into an Array, in case we have Multiple
   instances=()
   while IFS= read -r line; do
      instances+=( "$line" )
   done < <( /usr/bin/ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      echo ""
      echo "------------------------------"
      echo "License Usage for $i:"
      echo ""
      /usr/bin/csession $i "##class(%SYSTEM.License).ShowSummary()"
      echo ""
      echo ""
   done

}

list_namespaces()
{

   # Print list of Namespaces for a Database

   # Load Instances into an Array, in case we have Multiple
   instances=()
   while IFS= read -r line; do
      instances+=( "$line" )
   done < <( /usr/bin/ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      echo ""
      echo "------------------------------"
      echo "Listing Namespaces for $i:"
      echo ""
      echo -e "d ##class(%SYS.Namespace).ListAll(.result)\nzw result\nh" |/usr/bin/csession $i |egrep "Node|result"
      echo ""
   done

   echo ""

}

mirror_status()
{

   # Display Current Mirror Status

   # Load Instances into an Array, in case we have Multiple
   instances=()
   while IFS= read -r line; do
      instances+=( "$line" )
   done < <( /usr/bin/ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      echo ""
      echo "------------------------------"
      echo "Current Mirror Status for $i:"
      echo ""
      echo -e "w ##class(%SYSTEM.Mirror).GetMemberStatus()\nh" |/usr/bin/csession $i -U %SYS |awk NR==5
      echo ""
   done

   echo ""

}

os_user_exists()
{

   ### Check if User Exists on the OS ###

   if [ -z "$INPUT_COMMAND2" ]
   then
      echo ""
      echo "No User ID Input - Please Run Again with a User ID"
      echo ""

   else
      if [ "`getent passwd $INPUT_COMMAND2`" ]
      then
         return 0
      else
         echo ""
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
   done < <( /usr/bin/ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      /usr/bin/ccontrol stop $i quietly restart > /dev/null 2>&1
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

show_app_errors()
{

   # Show Application Errors for a Namespace

   echo ""
   echo "Fetching Application Errors for Namespace"
   echo ""
   echo "(If you did not provide a namespace, it will be list from default User Namespace)"
   echo ""

   if [ -z "$INPUT_COMMAND2" ]
   then
      echo "Fetching App Error Log for Default User Namespace"

      # Load Instances into an Array, in case we have Multiple
      instances=()
      while IFS= read -r line; do
         instances+=( "$line" )
      done < <( /usr/bin/ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

      for i in ${instances[@]};
      do
         echo ""
         echo "------------------------------"
         echo "Listing Default App Error Log for $i:"
         echo ""
         /usr/bin/csession $i "^%ERN"
         echo ""
      done

   else
      echo "Fetching App Error Log for Namespace $INPUT_COMMAND2"

      # Load Instances into an Array, in case we have Multiple
      instances=()
      while IFS= read -r line; do
         instances+=( "$line" )
      done < <( /usr/bin/ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

      for i in ${instances[@]};
      do
         echo ""
         echo "------------------------------"
         echo "Listing App Error in $i for Namespace $INPUT_COMMAND2:"
         echo ""
         /usr/bin/csession $i -U $INPUT_COMMAND2 "^%ERN"
         echo ""
      done

   fi

}

show_log()
{

   echo ""
   echo "Parsing out cconsole.log for Severity Messages Greater Than 1"
   echo ""

   # Load Instances into an Array, in case we have Multiple
   instances=()
   while IFS= read -r line; do
      instances+=( "$line" )
   done < <( /usr/bin/ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      echo "Log Messages for $i"
      echo ""

      local_installdir=`/usr/bin/ccontrol list $i |grep directory |awk '{ print $2 }'`
      log_file=$local_installdir/mgr/cconsole.log

      cat $log_file |egrep -i "\) 2 | \( 3" |tail -n 20
      echo ""
   done

}

start_instances()
{

   # Load Instances into an Array, in case we have Multiple
   instances=()
   while IFS= read -r line; do
      instances+=( "$line" )
   done < <( /usr/bin/ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      /usr/bin/ccontrol start $i > /dev/null 2>&1
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
   /usr/bin/ccontrol list

}

stop_instances()
{

   # Load Instances into an Array, in case we have Multiple
   instances=()
   while IFS= read -r line; do
      instances+=( "$line" )
   done < <( /usr/bin/ccontrol list |grep Configuration |awk '{ print $2 }' |tr -d "'" )

   for i in ${instances[@]};
   do
      /usr/bin/ccontrol stop $i quietly > /dev/null 2>&1
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

   # For Main Case Function, and also if User is Enabled/Disabled

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
         
         ### Check if User is Enabled/Disabled ###

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
            add_user
         ;;
         --auth-enabled)
            auth_enabled
         ;;
         --cache-info)
            cache_info
         ;;
         --del-user)
            del_user
         ;;
         --disable-user)
            disable_user
         ;;
         --enable-user)
            enable_user
         ;;
         --help)
            help_text
         ;;
         --journal-status)
            journal_status
         ;;
         --license)
            license_usage
         ;;
         --list-namespaces)
            list_namespaces
         ;;
         --mirror-status)
            mirror_status
         ;;
         --restart)
            echo ""
            echo "Restarting Instances Now"
            echo ""
            restart_instances
         ;;
         --show-app-errors)
            show_app_errors
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
            user_exists
         ;;
         --version)
            echo ""
            echo "Script Version = $VERSION"
            echo ""
         ;;
         *)
            echo ""
            echo "$INPUT_COMMAND1 = Not Valid Input"
            echo ""
            help_text
      esac

   else
      echo ""
      echo "Cache is not Installed, ... Exiting"
      echo ""

   fi

}

main


