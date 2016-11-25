#!/bin/sh

#Check if a file name was entered, or if file name already exists
if [ ! -n "$1" ]; then
    echo "Usage: \n\n   newrubyscript.sh FILENAME \n\n"
    exit

elif [ -f "$1".* ]; then
    echo "File with name $1 already exists."
    exit
fi

#Create new script file
TYPE=".ruby"
NAME="$1"
NEWFILE=$NAME$TYPE
DIR="~/Desktop/"

#Create File
touch $NEWFILE

#Add compiler directive
echo "#!/usr/bin/env ruby" >> $NEWFILE

#Add execution permissions
chmod 755 $NEWFILE

#Rename
mv $NEWFILE $NAME

#Move to script folder without file type appended
mv $NAME $DIR

#Create link to /usr/local/bin
ENDPATH=$DIR$NAME
ln -s $ENDPATH /usr/local/bin

#done
echo "$NAME created."
echo "Linked to: /usr/local/bin/$NAME"

emacs $ENDPATH
