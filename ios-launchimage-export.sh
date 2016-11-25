#!/bin/sh

f=$(pwd)

if [ ! -n "$1" ]; then
    echo "Must specify a filename."
    exit
    
elif [ -f "$1".* ]; then
    echo "File with name $1 already exists."
    exit
fi

# iPhone 4s
sips --resampleHeightWidth 480 320 "${f}/${1}" --out "${f}/LaunchImage.png"
sips --resampleHeightWidth 960 640 "${f}/${1}" --out "${f}/LaunchImage@2x.png"
sips --resampleHeightWidth 960 640 "${f}/${1}" --out "${f}/LaunchImage@2x-1.png"

# iPhone 5s
sips --resampleHeightWidth 1136 640 "${f}/${1}" --out "${f}/LaunchImage-568h@2x.png"
sips --resampleHeightWidth 1136 640 "${f}/${1}" --out "${f}/LaunchImage-568h@2x-1.png"

# iPhone 6
sips --resampleHeightWidth 1334 750 "${f}/${1}" --out "${f}/LaunchImage-667h@2x.png"

# iPhone 6+
sips --resampleHeightWidth 2208 1242 "${f}/${1}" --out "${f}/LaunchImage-736h@3x.png"

#iPad
sips --resampleHeightWidth 1024 768 "${f}/${1}" --out "${f}/LaunchImage-Portrait-StatusBar.png"
sips --resampleHeightWidth 1024 768 "${f}/${1}" --out "${f}/LaunchImage-Portrait-StatusBar-1.png"
sips --resampleHeightWidth 2048 1536 "${f}/${1}" --out "${f}/LaunchImage-Portrait-StatusBar@2x.png"
sips --resampleHeightWidth 2048 1536 "${f}/${1}" --out "${f}/LaunchImage-Portrait-StatusBar@2x-1.png"

sips --resampleHeightWidth 1004 768 "${f}/${1}" --out "${f}/LaunchImage-Portrait.png"
sips --resampleHeightWidth 2008 1536 "${f}/${1}" --out "${f}/LaunchImage-Portrait@2x.png"
