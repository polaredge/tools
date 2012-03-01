#!/bin/bash
CURRENT_DB=$(grep 'name'  /etc/cnu/cnu_env | cut -d"'" -f2)

echo "1. Backup DB"
echo "2. Restore DB"
echo "3. Delete ALL Databases"
echo "OR enter anything else to EXIT"

read action

if [ $action -eq 1]; then

# Delete OLD Back up DBs
psql -U postgres -l | grep -w $CURRENT_DB"_backup" | awk '{ system("dropdb -U postgres " $1)}'
psql -U postgres -l | grep -w $CURRENT_DB"_fraud_backup" | awk '{ system("dropdb -U postgres " $1)}'

createdb -U postgres -T $CURRENT_DB  $CURRENT_DB"_backup"
createdb -U postgres -T $CURRENT_DB"_fraud"  $CURRENT_DB"_fraud_backup"

echo "Backed UP DBs:$CURRENT_DB_backup"
echo "Backed UP DBs:$CURRENT_DB_fraud_backup"
exit 0
fi

if [ $action -eq 2]; then

# Delete current DBs
psql -U postgres -l | grep -w $CURRENT_DB | awk '{ system("dropdb -U postgres " $1)}'
psql -U postgres -l | grep -w $CURRENT_DB"_fraud" | awk '{ system("dropdb -U postgres " $1)}'

createdb -U postgres -T $CURRENT_DB"_backup"  $CURRENT_DB"_backup"
createdb -U postgres -T $CURRENT_DB"_fraud_back"  $CURRENT_DB"_fraud_backup"

echo "Restored DBs:$CURRENT_DB"
echo "Restored DBs:$CURRENT_DB_fraud"
exit 0
fi

if [ $action -eq 3]; then

# Delete All DBs
psql -U postgres -l | grep -v '^ template\|^ postgre' | awk '{ system("dropdb -U postgres " $1)}'

echo "ALL databases DELETED"
exit 0
fi


sudo psql -U postgres -l | grep 'cnuapp_int'| awk '{ system("dropdb -U postgres " $1)}'
dbdel=grep 'name'  /etc/cnu/cnu_env | cut -d"'" -f2 | awk '{ system("dropdb -U postgres " $1)}'
backupdbs=grep 'name'  /etc/cnu/cnu_env | cut -d"'" -f2 | awk '{ system("createdb -U postgres -T" $1  $1"_Backup")}'
restoredb=awk '{ system("createdb -U postgres -T" $1  $1"_Backup2")}'
grep 'name'  /etc/cnu/cnu_env | cut -d"'" -f2
