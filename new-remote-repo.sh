#!/bin/sh

if [ ! -n "$1" ]; then
    echo "\nUsage:\n\n    newremoterepo.sh REPO_NAME        \n"
    exit
fi

REPO=$1

curl -u 'skyefreeman' https://api.github.com/user/repos -d '{"name":"'$REPO'"}'
