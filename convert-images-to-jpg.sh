#!/bin/bash

DIR=$(pwd)
FILES=$DIR/*

for f in $FILES; do
    if [[ "$f" == *".png" ]]; then
	FILENAME="${f##*/}"
	WITHOUT_EXTENSION=${FILENAME%.png}
	FILENAME_AFTER="$WITHOUT_EXTENSION.jpg"
	echo "$FILENAME -> $FILENAME_AFTER"
	sips --setProperty format jpeg "$FILENAME" --out "$FILENAME_AFTER" > /dev/null
    fi
done
