#!/bin/sh

## creates script symlinks in /usr/local/bin

echo "linking..."
for file in $PWD/*; do
    filename=$ echo "${file##*/}"
    ln -s $file /usr/local/bin/$filename
    echo "$filename"
done
echo "finished linking."
