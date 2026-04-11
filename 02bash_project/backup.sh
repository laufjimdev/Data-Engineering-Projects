#! /bin/bash

if [[ $# != 2 ]]
then
    echo "backup.sh target_directory destination_directory"
    echo "Please try again"
exit 
fi  
if [[ ! -d $1 || ! -d $2 ]]
then 
    echo "Invalid directories have been entered"
    echo "Please try again"
exit 
fi 

targetdir=$1
destdir=$2

originalPath=$(pwd)
cd "$destdir"
destAbsPath=$(pwd)
cd "$originalPath"
cd "$targetdir" 

currentTS=$(date +%s)
backup_file_name="backup-$currentTS.tar.gz"

#Compressing docs that have been modified in the last 24h 

tar -czvf "$backup_file_name" $(find . -type f -mtime -1)
mv "$backup_file_name" "$destAbsPath"






