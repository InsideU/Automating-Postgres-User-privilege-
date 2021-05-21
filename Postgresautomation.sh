#!/bin/bash

#check if the database exsist or not

function is_database() {
  psql -lqt | cut -d \| -f 1 | grep -wq $1
}

create_user(){
	echo "*************** Creating A New User ***************"
	for (( i=0;i<$ldatabase;i++ ))
	do
	for (( j=0;j<lnames;j++ ))
	do
	user_present=$(psql "${databases[$i]}" -c "\du" | grep "|" | awk -F ' ' '{print $1}' | grep -vwE "(List|Role)" | grep "\b"${names[$j]}"\b")
	if ! [[ $psql_user =~ "${names[$j]}" ]]
	then
		password='defaultpassword'
		echo "# Creating new user in database: "${names[$j]}""
    		psql "${databases[$i]}" -c "CREATE USER "${names[$j]}" WITH PASSWORD '$password';"
  	else
    		echo "# User exists! Skipping.."
	fi
done
done

}

pg_delete_user(){
  echo "******* Deleting ${role} user: ${name} ***********"
  for (( i=0;i<$ldatabase;i++ ))
	do
	for (( j=0;j<lnames;j++ ))
	do
  set +e
  psql_user=$(psql "${databases[$i]}" -c  "\du" | grep "|" | awk -F ' ' '{print $1}' | grep -vwE "(List|Role)" | grep "\b"${names[$j]}"\b")
  if [[ $psql_user == ${names[$j]} ]]
  then
    echo "# Deleting user: "${names[$j]}" (if this raises an error for the first database then ignore)"
    psql "${databases[$i]}" -c  "drop user "${names[$j]}";"
  else
    echo "# User does not exists! Skipping.."
  fi
  done
  done
}

superuser(){
	for ((i=0;i<ldatabase;i++ )); do
		for (( j=0;j<lnames;j++ )) ; do

	echo "******* Assigning Super User Access to the {"${name[$j]}"} ********"
	create_user
	psql $"${databases[$i]}" -c "alter "${names[$j]}" with superuser"
	echo 
	echo "SuperUser Assess Granted"
done
done
}
createrole(){
	for ((i=0;i<ldatabase;i++ )); do
		for (( j=0;j<lnames;j++ )) ; do
	echo "******* Assigning Create role  Access to the {"${name[$j]}"} ********"
	create_user
	psql $"${databases[$i]}" -c "alter "${names[$j]}" with createrole"
	echo 
	echo "Create role access granted"
done
done

}
createdatabase(){
	for ((i=0;i<ldatabase;i++ )); do
		for (( j=0;j<lnames;j++ )) ; do

	echo "******* Assigning create databaser Access to the {"${names[$j]}"} ********"
	create_user
	psql $"${databases[$i]}" -c "alter "${names[$j]}" with createdb"
	echo 
	echo "CreateDB access Granted"
done
done
}
listusers(){
	echo "*******List of Users with their Permissions ******"
	echo 
	psql $"${databases[$i]}" -c "\du"
}
readaccess (){
	for ((i=0;i<ldatabase;i++ )); do
		for (( j=0;j<lnames;j++ )) ; do
    schemas=$(psql "${databases[$i]}" -c  "\dn" | grep '|' | awk -F ' ' '{print $1}' | grep -vwE "Name")
    echo
    echo "# DATABASE: "${database[$i]}""
    for schema in ${schemas} ; do
      echo "# SCHEMA: $schema"
      psql "${databases[$i]}" -c  "GRANT SELECT ON ALL TABLES IN SCHEMA $schema TO "${names[$j]}"; GRANT USAGE ON SCHEMA $schema TO "${names[$j]}"; ALTER DEFAULT PRIVILEGES IN SCHEMA $schema GRANT SELECT ON TABLES TO "${names[$j]}"; ALTER DEFAULT PRIVILEGES IN SCHEMA $schema GRANT USAGE ON SEQUENCES TO "${names[$j]}";"
      echo
    done
  done
done
}

writeaccess (){
	for ((i=0;i<ldatabase;i++ )); do
		for (( j=0;j<lnames;j++ )) ; do
    is_pg_database_valid
    schemas=$(psql "${databases[$i]}" -c "\dn" | grep '|' | awk -F ' ' '{print $1}' | grep -vwE "Name")
    echo
    echo "# DATABASE: "${database[$i]}""
    for schema in ${schemas} ; do
      echo "# SCHEMA: $schema"
      psql "${databases[$i]}" -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA $schema TO "${names[$j]}"; GRANT USAGE ON SCHEMA $schema TO "${names[$j]}"; ALTER DEFAULT PRIVILEGES IN SCHEMA $schema GRANT ALL PRIVILEGES ON TABLES TO "${names[$j]}"; ALTER DEFAULT PRIVILEGES IN SCHEMA $schema GRANT USAGE ON SEQUENCES TO "${names[$j]}";"
      echo
    done
  done
done
}

revokeread (){
	for ((i=0;i<ldatabase;i++ )); do
		for (( j=0;j<lnames;j++ )) ; do
    schemas=$(psql "${databases[$i]}" -c "\dn" | grep '|' | awk -F ' ' '{print $1}' | grep -vwE "Name")
    echo
    echo "# DATABASE: "${database[$i]}""
    for schema in ${schemas} ; do
      echo "# SCHEMA: $schema"
      psql "${databases[$i]}" -c "REVOKE SELECT ON ALL TABLES IN SCHEMA $schema FROM "${names[$j]}"; REVOKE USAGE ON SCHEMA $schema FROM "${names[$j]}"; ALTER DEFAULT PRIVILEGES IN SCHEMA $schema REVOKE SELECT ON TABLES FROM "${names[$j]}"; ALTER DEFAULT PRIVILEGES IN SCHEMA $schema REVOKE USAGE ON SEQUENCES FROM "${names[$j]}";"
      echo
    done
  done
done
}
revokewrite (){
	for ((i=0;i<ldatabase;i++ )); do
		for (( j=0;j<lnames;j++ )) ; do
    schemas=$(psql "${databases[$i]}" -c "\dn" | grep '|' | awk -F ' ' '{print $1}' | grep -vwE "Name")
    echo
    echo "# DATABASE: "${database[$i]}""
    for schema in ${schemas} ; do
      echo "# SCHEMA: $schema"
      psql "${databases[$i]}" -c "REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA $schema FROM "${names[$j]}"; REVOKE USAGE ON SCHEMA $schema FROM "${names[$j]}"; ALTER DEFAULT PRIVILEGES IN SCHEMA $schema REVOKE ALL PRIVILEGES ON TABLES FROM "${names[$j]}"; ALTER DEFAULT PRIVILEGES IN SCHEMA $schema REVOKE USAGE ON SEQUENCES FROM "${names[$j]}";"
      echo
    done
  done
  done
}

while true; do
echo "Enter Username : "

while read line
do
    names=("${names[@]}" $line)
done



lnames=${#names[@]}

echo "choose from available options"
echo
echo "1-> Create a New User"
echo
echo "2-> Delete the user from the database"
echo
echo "3-> Grant Read Acess to the exsisting User"
echo
echo "4-> Grant Write Access to the exsisting User"
echo
echo "5-> Revoke read access from the user"
echo
echo "6-> Revoke write access from the user"
echo
echo "7--> Give Super user access to the user"
echo
echo "8--> Give create role function to the user"
echo 
echo "9--> Give create database role to the user"
echo 
echo "10--> List all the users with their roles"
read action 

echo "NAME: ${name} ACTION: ${action} ROLE: ${role}"

#take the database and check if it exsist
while read line
do
    databases=("${databases[@]}" $line)
done
ldatabase=${#databases[@]}
for (( i=0;i<ldatabase;i++ ))
do
if is_database "${databases[$i]}"
then
	if [[ $action == 1  ]]
	then
		create_user 
	elif [[ $action == 2 ]]
	then
		pg_delete_user
	elif [[ $action == 3 ]]
	then
		readaccess 
	elif [[ $action == 4 ]]
	then
		writeaccess
	elif [[ $action == 5 ]]
	then
		revokeread
	elif [[ $action == 6 ]]
	then
		revokewrite
	elif [[ $action == 7 ]]
	then
		superuser;
	elif [[ $action == 8 ]]
	then
		createrole
	elif [[ $action == 9 ]]
	then
		createdatabase
	elif [[ $action == 10 ]]
	then
		listusers

	else
		echo "YET TO DEFINE"
	fi
else
	echo $database database does not exist
fi
done
unset databases
unset names
done
