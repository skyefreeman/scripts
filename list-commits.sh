#!/bin/bash

if [ -n "$1" ]; then
    START=$1
else
    echo "Requires a starting git hash"
    exit 0
fi

if [ -n "$2" ]; then
    END=$2
else
    echo "Requires an ending git hash"
    exit 0
fi

git log --oneline --ancestry-path $START..$END
