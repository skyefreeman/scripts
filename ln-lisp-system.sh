#!/bin/bash

DIR=$(pwd)
FILES=$DIR/*

for f in $FILES; do
    if [[ "$f" == *".asd" ]]; then

	ln -s $DIR ~/.roswell/local-projects/
	echo "Linked $DIR"
	sbcl --non-interactive --eval '(ql:register-local-projects)'
	echo "Reloaded local quicklisp projects."
	
	break
    fi
done
