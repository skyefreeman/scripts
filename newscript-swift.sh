#!/bin/sh

## Creating a new swift script ##

#Check if a file name was entered, or if file name already exists
if [ ! -n "$1" ]; then
    echo "Must specify a filename."
    exit
    
elif [ -f "$1".* ]; then
    echo "File with name $1 already exists."
    exit
fi

#Create new swift file
NEWFILE="$1".swift
touch $NEWFILE

#Add compiler directive
echo "#!/usr/bin/env xcrun swift" >> $NEWFILE

#Add execution permissions
chmod +x $NEWFILE

#done
echo $NEWFILE "created." 
