#!/bin/sh

set -e

if [ ! -n "$1" ]; then
    echo "\nUsage:\n\n    github-pr.sh 'Pull request title'\n"
    exit
fi

PR_TITLE=$1
URL=$(hub pull-request -m $PR_TITLE)
SLACK_MESSAGE='${PR_TITLE} - *${URL}*'

echo $SLACK_MESSAGE | pbcopy
