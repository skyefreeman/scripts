#!/bin/sh

## Creating a new bash script with build/run permissions ##

if [ ! -n "$1" ]; then
    echo "Must specify a filename."
    exit

elif [ -f "$1".* ]; then
    echo "File with name $1 already exists."
    exit
fi

NEWFILE="$1".sh
touch $NEWFILE
echo "#!/bin/sh" >> $NEWFILE
chmod +x $NEWFILE

echo $NEWFILE "created."
