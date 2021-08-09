#!/bin/sh


if [ ! -n "$1" ]; then
    echo "Must specify a filename."
    exit
    
elif [ -f "$1".* ]; then
    echo "File with name $1 already exists."
    exit
fi

f=$(pwd)

# App Store Connect

sips --resampleWidth 1024 "${f}/${1}" --out "${f}/AppIcon@1024w.png"

# iPhone

sips --resampleWidth 40 "${f}/${1}" --out "${f}/AppIcon-iPhone-Notification@40w.png"
sips --resampleWidth 60 "${f}/${1}" --out "${f}/AppIcon-iPhone-Notification@60w.png"

sips --resampleWidth 58 "${f}/${1}" --out "${f}/AppIcon-iPhone-Settings@58w.png"
sips --resampleWidth 87 "${f}/${1}" --out "${f}/AppIcon-iPhone-Settings@87w.png"

sips --resampleWidth 80 "${f}/${1}" --out "${f}/AppIcon-iPhone-Spotlight@80w.png"
sips --resampleWidth 120 "${f}/${1}" --out "${f}/AppIcon-iPhone-Spotlight@120w.png"

sips --resampleWidth 120 "${f}/${1}" --out "${f}/AppIcon-iPhone@120w.png"
sips --resampleWidth 180 "${f}/${1}" --out "${f}/AppIcon-iPhone@180w.png"

# iPad

sips --resampleWidth 20 "${f}/${1}" --out "${f}/AppIcon-iPad-Notifications@20w.png"
sips --resampleWidth 40 "${f}/${1}" --out "${f}/AppIcon-iPad-Notifications@40w.png"

sips --resampleWidth 29 "${f}/${1}" --out "${f}/AppIcon-iPad-Settings@29w.png"
sips --resampleWidth 58 "${f}/${1}" --out "${f}/AppIcon-iPad-Settings@58w.png"

sips --resampleWidth 40 "${f}/${1}" --out "${f}/AppIcon-iPad-Spotlight@40w.png"
sips --resampleWidth 80 "${f}/${1}" --out "${f}/AppIcon-iPad-Spotlight@80w.png"

sips --resampleWidth 76 "${f}/${1}" --out "${f}/AppIcon-iPad@76w.png"
sips --resampleWidth 152 "${f}/${1}" --out "${f}/AppIcon-iPad@152w.png"

sips --resampleWidth 167 "${f}/${1}" --out "${f}/AppIcon-iPad-Pro@167w.png"
