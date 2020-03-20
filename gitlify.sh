#!/bin/bash
####
username=$1
repo_name=$2


if [ "$username" = "-h" ]; then
echo "USAGE:"
echo "1 argument - your username in gitlab"
echo "2 argument - name of the repo you want to create"
exit 1
fi

if [ "$username" = "" ]; then
echo "Could not find username, please provide it."
exit 1
fi

dir_name=`basename $(pwd)`

if [ "$repo_name" = "" ]; then
read -p "Repo name (hit enter to use '$dir_name')? " repo_name
fi

if [ "$repo_name" = "" ]; then
repo_name=$dir_name
fi

# ask user for password
read -s -p "Enter Password: " password

request=`curl --request POST "https://git.idc.tarento.com/api/v4/session?login=$username&password=$password"`

if [ "$request" = '{"message":"401 Unauthorized"}' ]; then
echo "Username or password incorrect."
exit 1
fi

token=`echo $request | cut -d , -f 28 | cut -d : -f 2 | cut -d '"' -f 2`

echo -n "Creating GitLab repository '$repo_name' ..."
curl -H "Content-Type:application/json" https://git.idc.tarento.com/api/v4/projects?private_token=uxjCeggkiu8U_4hkaPn_ -d '{"name":"'$repo_name'"}' > /dev/null 2>&1
echo $repo_name
echo " done."

# 2>$1 means that we want redirect stderr to stdout


while :
do
echo ""
read -r -p "Do you want to add a user to your repository? [y/n] " input
case $input in
	[yY][eE][sS]|[yY])
                read -p "Enter username: " newuser
		echo "Enter access_level"
		echo "10 => Guest access"
		echo "20 => Reporter access"
		echo "30 => Developer access"
		echo "40 => Master access"
		read -p "50 => Owner access # Only valid for groups - " access
                echo "================================="
		echo $newuser		
                echo "==============================="
		# find out id of the project and user_id
		id=`curl --header "PRIVATE-TOKEN: uxjCeggkiu8U_4hkaPn_" https://git.idc.tarento.com/api/v4/projects | cut -d , -f1 | cut -d : -f2`
		user_id=`curl --header "PRIVATE-TOKEN: uxjCeggkiu8U_4hkaPn_" https://git.idc.tarento.com/api/v4/users?username=$newuser | cut -d , -f1 | cut -d : -f2`

		# add user to gitlab project
		curl --request POST --header "PRIVATE-TOKEN: uxjCeggkiu8U_4hkaPn_" --data "user_id=$user_id&access_level=$access" https://git.idc.tarento.com/api/v4/projects/$id/members
		;;
	[nN][oO]|[nN])
		echo "As you wish, master."
		break
		;;
	*)
		echo "Invalid input..."
		;;
esac
done

echo ""
echo "The created repo is available at following link:"
echo "https://git.idc.tarento.com/$username/$repo_name"
