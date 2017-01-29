#!/bin/sh

f=$(pwd)

if [ ! -n "$1" ]; then
    echo "Must specify a filename."
    exit
    
elif [ -f "$1".* ]; then
    echo "File with name $1 already exists."
    exit
fi

#itunes connect
sips --resampleWidth 512 "${f}/${1}" --out "${f}/iTunesArtwork.png"
sips --resampleWidth 1024 "${f}/${1}" --out "${f}/iTunesArtwork@2x.png"

#iphone
sips --resampleWidth 40 "${f}/${1}" --out "${f}/icon_iphone_notification.png"
sips --resampleWidth 60 "${f}/${1}" --out "${f}/icon_iphone_notification@2x.png"

sips --resampleWidth 29 "${f}/${1}" --out "${f}/icon_iphone_spotlight_small.png"
sips --resampleWidth 58 "${f}/${1}" --out "${f}/icon_iphone_spotlight_small@2x.png"
sips --resampleWidth 87 "${f}/${1}" --out "${f}/icon_iphone_spotlight_small@3x.png"

sips --resampleWidth 80 "${f}/${1}" --out "${f}/icon_iphone_spotlight@2x.png"
sips --resampleWidth 120 "${f}/${1}" --out "${f}/icon_iphone_spotlight@3x.png"

sips --resampleWidth 120 "${f}/${1}" --out "${f}/icon_iphone@2x.png"
sips --resampleWidth 180 "${f}/${1}" --out "${f}/icon_iphone@3x.png"

#ipad
sips --resampleWidth 20 "${f}/${1}" --out "${f}/icon_ipad_notifications.png"
sips --resampleWidth 40 "${f}/${1}" --out "${f}/icon_ipad_notifications@2x.png"

sips --resampleWidth 29 "${f}/${1}" --out "${f}/icon_ipad_settings.png"
sips --resampleWidth 58 "${f}/${1}" --out "${f}/icon_ipad_settings@2x.png"

sips --resampleWidth 40 "${f}/${1}" --out "${f}/icon_ipad_spotlight.png"
sips --resampleWidth 80 "${f}/${1}" --out "${f}/icon_ipad_spotlight@2x.png"

sips --resampleWidth 76 "${f}/${1}" --out "${f}/icon_ipad.png"
sips --resampleWidth 152 "${f}/${1}" --out "${f}/icon_ipad@2x.png"
sips --resampleWidth 167 "${f}/${1}" --out "${f}/icon_ipad_pro@2x.png"

#apple watch
sips --resampleWidth 48 "${f}/${1}" --out "${f}/icon_watch_notification_center_38mm.png"
sips --resampleWidth 55 "${f}/${1}" --out "${f}/icon_watch_notification_center_42mm.png"

sips --resampleWidth 58 "${f}/${1}" --out "${f}/icon_watch_companion_settings@2x.png"
sips --resampleWidth 87 "${f}/${1}" --out "${f}/icon_watch_companion_settings@3x.png"

sips --resampleWidth 80 "${f}/${1}" --out "${f}/icon_watch_home_screen@2x.png"

sips --resampleWidth 88 "${f}/${1}" --out "${f}/icon_watch_long_look_42mm.png"

sips --resampleWidth 172 "${f}/${1}" --out "${f}/icon_watch_short_look_38mm.png"
sips --resampleWidth 196 "${f}/${1}" --out "${f}/icon_watch_short_look_42mm.png"
