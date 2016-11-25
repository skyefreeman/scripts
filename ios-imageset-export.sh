#!/bin/sh
f=$(pwd)

if [ ! -n "$1" ]; then
    echo "Must specify a filename."
    exit
    
elif [ -f "$1".* ]; then
    echo "File with name $1 already exists."
    exit
fi

sips --resampleWidth 24 "${f}/${1}" --out "${f}/$1"
sips --resampleWidth 48 "${f}/${1}" --out "${f}/2x-$1"
sips --resampleWidth 72 "${f}/${1}" --out "${f}/3x-$1"
