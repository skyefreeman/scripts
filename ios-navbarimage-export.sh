#!/bin/sh
f=$(pwd)

if [ ! -n "$1" ]; then
    echo "Must specify a filename."
    exit
    
elif [ -f "$1".* ]; then
    echo "File with name $1 already exists."
    exit
fi

sips --resampleWidth 25 "${f}/${1}" --out "${f}/$1"
sips --resampleWidth 50 "${f}/${1}" --out "${f}/2x-$1"
sips --resampleWidth 75 "${f}/${1}" --out "${f}/3x-$1"
