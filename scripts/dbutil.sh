#!/bin/bash
DB=$(grep 'name'  /etc/cnu/cnu_env | cut -d"'" -f2)
DB_FRAUD=$DB"_fraud"
DB_BACKUP=$DB"_backup"
DB_FRAUD_BACKUP=$DB_FRAUD"_backup"
TODELETE="cnuapp_int"

echo "1. Backup DB"
echo "2. Restore DB"
echo "3. Delete ALL Databases"
echo "4. List DBs"
echo "OR enter anything else to EXIT"

read action

# DB BACKUP
if [ $action -eq 1 ]; then
# BEFORE We delete OLD Backups, make sure orignal DB exists to make Backups
SOURCE_DB=$(psql -U postgres -l | grep -w $DB)
	if [ -z "$SOURCE_DB" ]; then
           echo "Source DB $DB does not exist. Current DB LIST:"
	   psql -U postgres -l
           exit 0
	fi
# Delete OLD Back up DBs
psql -U postgres -l | grep -w $DB_BACKUP | awk '{ system("dropdb -U postgres " $1)}'
psql -U postgres -l | grep -w $DB_FRAUD_BACKUP | awk '{ system("dropdb -U postgres " $1)}'

# BACKUP NOW
createdb -U postgres -T $DB  $DB_BACKUP
createdb -U postgres -T $DB_FRAUD  $DB_FRAUD_BACKUP

echo "Backed UP $DB       to $DB_BACKUP"
echo "Backed UP $DB_FRAUD to $DB_FRAUD_BACKUP"
exit 0
fi

# DB RESTORE
if [ $action -eq 2 ]; then
# Before we delete DBs, make sure backup DB exists
SOURCE_DB=$(psql -U postgres -l | grep -w $DB_BACKUP)
	if [ -z "$SOURCE_DB" ]; then
           echo "Backup DB $DB_BACKUP does not exist. Current DB List"
	   psql -U postgres -l
           exit 0
	fi

# Delete current DB
psql -U postgres -l | grep -w $DB | awk '{ system("dropdb -U postgres " $1)}'
psql -U postgres -l | grep -w $DB_FRAUD | awk '{ system("dropdb -U postgres " $1)}'

# RESTORE NOW
createdb -U postgres -T $DB_BACKUP  $DB
createdb -U postgres -T $DB_FRAUD_BACKUP  $DB_FRAUD

echo "Restored $DB       FROM $DB_BACKUP"
echo "Restored $DB_FRAUD FROM $DB_FRAUD_BACKUP"
exit 0
fi

if [ $action -eq 3 ]; then

psql -U postgres -l | grep  $TODELETE | awk '{ system("dropdb -U postgres " $1)}'

echo "ALL databases DELETED"
exit 0
fi

if [ $action -eq 4 ]; then
psql -U postgres -l 
exit 0
fi


