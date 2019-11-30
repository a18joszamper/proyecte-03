#!/bin/bash

# https://github.com/a18joszamper/proyecte-03.git

usage(){
cat <<EOF
Usage: ./disable-local-user.sh [-dra] USER [USERN]
Disable a local Linux account.
  -d Deletes accounts instead of disabling them.
  -r Removes the home directory associated with the account(s).
  -a Creates an archive of the home directory associated with the accounts(s).
EOF
exit 1
}

while getopts :dra o
do
        case $o in
                d)
                        delete=true
                        ;;
                r)
			rd=true
                        ;;
		a)
	                archive=true
			;;
                \?)
			echo "ERROR: Invalid option -$OPTARG"
                        usage
			;;
		:)
		        echo "ERROR: -$OPTARG requires an argument."
  		        ;;
		*)
			echo "Unknown error."
			usage
			;;
        esac
done

shift $((OPTIND - 1))

if [ $(id -u) -eq 0 ]; then
	if [ $# -ne 0 ]; then
		for user in $@; do
			echo "Processing user: $user"
			if id -u "$user" > /dev/null 2>&1 ; then		
				if [  $(id -u $user) -gt 999 ]; then
					if [ $archive ]; then
						if [ ! -d /archive/ ]; then
							mkdir /archive/
							echo "Creating /archive directory."
						fi
						echo "Archiving /home/$user to /archive/$user.tgz"
						tar czvf /archive/$user.tgz /home/$user > /dev/null 2>&1
					fi
					if [ $delete ]; then
						if [ $rd ]; then
							rm -rf /home/$user
							if [ $? -eq 0 ]; then echo "The directory /home/$user was deleted."; else echo "The directory /home/$user could not be deleted"; fi
						fi
						userdel $user
						if [ $? -eq 0 ]; then echo "The account $user was deleted."; else echo "The account $user could not be deleted."; fi
					else
						usermod -L $user
						echo "The account $user was disabled."
					fi
				else
					echo "Refusing to remove the $user account with UID $(id -u $user)."
				fi
			else
				echo "The account $user doesn't exist"
			fi 
		done	
	else
		usage
	fi
else
        echo 'Please run with sudo or as root.'; exit 1
fi
