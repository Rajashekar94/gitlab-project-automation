
#!/bin/bash
####
username=$1
group_name=$2

#Description 
if [ "$username" = "-h" ]; then
echo "USAGE:"
echo "1 argument - your username in gitlab"
echo "2 argument - name of the group you want to create"
exit 1
fi

if [ "$username" = "" ]; then
echo "Could not find username, please provide it."
exit 1
fi


# ask user for password
read -s -p "Enter Password: " password

request=`curl --request POST "https://gitlab.tarento.com/api/v4/session?login=$username&password=$password"`

if [ "$request" = '{"message":"401 Unauthorized"}' ]; then
echo "Username or password incorrect."
exit 1
fi

if [ "$group_name" = "" ]; then
#then
read -p "Enter group name you want to search " group_name
fi


echo "########################################################################"
is_group_name_exists=`curl --header "PRIVATE-TOKEN: a3fJQzFiWJSyy4KWpymJ" https://gitlab.tarento.com/api/v4/groups/$group_name | cut -d , -f3 | cut -d : -f2 | sed 's/"//g'`
echo "########################################################################"

if [ "$group_name" = "$is_group_name_exists" ]; then
echo "======================================================================="
echo "Group matched"

read -r -p "Do you want to create repository inside group? [y/n] " input

# check for group id and name
curl --header "PRIVATE-TOKEN: a3fJQzFiWJSyy4KWpymJ" https://gitlab.tarento.com/api/v4/groups/$group_name | cut -d , -f1,3,6
group_id=`curl --header "PRIVATE-TOKEN: a3fJQzFiWJSyy4KWpymJ" https://gitlab.tarento.com/api/v4/groups/$group_name | cut -d , -f1 | cut -d : -f2`
echo id is $group_id

case $input in
        [yY][eE][sS]|[yY])

read -p "Enter repositoryname: " repo_name

curl -H "Content-Type:application/json" https://gitlab.tarento.com/api/v4/projects?private_token=a3fJQzFiWJSyy4KWpymJ -d '{"name":"'$repo_name'","namespace_id":"'$group_id'"}' > /dev/null 2>&1
;;


esac

#echo ""
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
                id=`curl --header "PRIVATE-TOKEN: a3fJQzFiWJSyy4KWpymJ" https://gitlab.tarento.com/api/v4/projects | cut -d , -f1 | cut -d : -f2`
                user_id=`curl --header "PRIVATE-TOKEN: a3fJQzFiWJSyy4KWpymJ" https://gitlab.tarento.com/api/v4/users?username=$newuser | cut -d , -f1 | cut -d : -f2`

                # add user to gitlab project
                curl --request POST --header "PRIVATE-TOKEN: a3fJQzFiWJSyy4KWpymJ" --data "user_id=$user_id&access_level=$access" https://gitlab.tarento.com/api/v4/projects/$id/members
                ;;
esac

echo "======================================================================="

else

echo "======================================================================="
echo "Goup Deosn't match"

read -p "Please enter group_name: " group_name
          echo $group_name

#create a new group
curl -H "Content-Type:application/json" https://gitlab.tarento.com/api/v4/groups?private_token=a3fJQzFiWJSyy4KWpymJ -d '{"name":"'$group_name'","path":"'$group_name'"}'

# check for group id and filtering 
curl --header "PRIVATE-TOKEN: a3fJQzFiWJSyy4KWpymJ" https://gitlab.tarento.com/api/v4/groups/$group_name | cut -d , -f1,3,6
group_id=`curl --header "PRIVATE-TOKEN: a3fJQzFiWJSyy4KWpymJ" https://gitlab.tarento.com/api/v4/groups/$group_name | cut -d , -f1 | cut -d : -f2`
echo id is $group_id

#create project name
read -p "Please enter repo_name: "  repo_name

curl -H "Content-Type:application/json" https://gitlab.tarento.com/api/v4/projects?private_token=a3fJQzFiWJSyy4KWpymJ -d '{"name":"'$repo_name'","namespace_id":"'$group_id'"}'

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
                id=`curl --header "PRIVATE-TOKEN: a3fJQzFiWJSyy4KWpymJ" https://gitlab.tarento.com/api/v4/projects | cut -d , -f1 | cut -d : -f2`
                user_id=`curl --header "PRIVATE-TOKEN: a3fJQzFiWJSyy4KWpymJ" https://gitlab.tarento.com/api/v4/users?username=$newuser | cut -d , -f1 | cut -d : -f2`

                # add user to gitlab project
                curl --request POST --header "PRIVATE-TOKEN: a3fJQzFiWJSyy4KWpymJ" --data "user_id=$user_id&access_level=$access" https://gitlab.tarento.com/api/v4/projects/$id/members
                ;;
        [nN][oO]|[nN])
                echo "As you wish, master."
                break
                ;;
        *)
                echo "Invalid input..."
                ;;
esac

echo "===================================================================="
fi

echo ""
echo "The created repo is available at following link:"
echo "https://gitlab.tarento.com/$group_name/$repo_name"





