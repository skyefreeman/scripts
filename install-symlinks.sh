#!/bin/sh

## creates scripts symlinks in the /usr/local/bin

echo "Linked: "
for file in $PWD/*; do
    filename=$ echo "${file##*/}"
    ln -s $file /usr/local/bin/$filename
    echo "$filename"
done
