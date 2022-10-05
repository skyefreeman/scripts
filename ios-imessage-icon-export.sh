#!/bin/sh


if [ ! -n "$1" ]; then
    echo "Must specify a filename for the 1024x1024 App Icon."
    exit
    
elif [ -f "$1".* ]; then
    echo "File with name $1 already exists."
    exit
fi

if [ ! -n "$2" ]; then
    echo "Must specify a filename for the 1024x768 iMessage App Icon."
    exit
    
elif [ -f "$2".* ]; then
    echo "File with name $2 already exists."
    exit
fi


f=$(pwd)

# Regular App Icons
sips --resampleHeightWidth 1024 1024 "${f}/${1}" --out "${f}/AppIcon@1024w1024h.png"

sips --resampleHeightWidth 58 58 "${f}/${1}" --out "${f}/iMessage-iPhone-Settings@29w29h-2x.png"

sips --resampleHeightWidth 87 87 "${f}/${1}" --out "${f}/iMessage-iPhone-Settings@29w29h-3x.png"

sips --resampleHeightWidth 58 58 "${f}/${1}" --out "${f}/iMessage-iPad-Settings@29w29h-2x.png"

# iMessage App Icons

sips --resampleHeightWidth 768 1024 "${f}/${2}" --out "${f}/AppIcon@1024w768h.png"

sips --resampleHeightWidth 90 120 "${f}/${2}" --out "${f}/iMessage-Messages-iPhone@60w45h-2x.png"
sips --resampleHeightWidth 135 180 "${f}/${2}" --out "${f}/iMessage-Messages-iPhone@60w45h-3x.png"

sips --resampleHeightWidth 100 134 "${f}/${2}" --out "${f}/iMessage-Messages-iPad@67w50h-2x.png"
sips --resampleHeightWidth 110 148 "${f}/${2}" --out "${f}/iMessage-Messages-iPadPro@74w55h-2x.png"

sips --resampleHeightWidth 40 54 "${f}/${2}" --out "${f}/iMessage-Messages@27w20h-2x.png"
sips --resampleHeightWidth 60 81 "${f}/${2}" --out "${f}/iMessage-Messages@27w20h-3x.png"

sips --resampleHeightWidth 48 64 "${f}/${2}" --out "${f}/iMessage-Messages@32w24h-2x.png"
sips --resampleHeightWidth 72 96 "${f}/${2}" --out "${f}/iMessage-Messages@32w24h-3x.png"


