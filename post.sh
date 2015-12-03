#!/bin/sh

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 title"
    exit 1
fi

POST_DATE=`date +%Y-%m-%d`
POST_TIME=`date +%H:%M:%S`

# Replace spaces with dashes, convert to lower case, strip non-slug chars
TITLE=`echo "$@" | sed -E 's/ /-/g' | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]-'`

POST_DIR=./_posts

POST_FILE=$POST_DIR/$POST_DATE-$TITLE.md

echo $POST_FILE

if [ -e $POST_FILE ]; then
    echo $POST_FILE already exists
    exit
fi

echo "---
date: '$POST_DATE $POST_TIME'
layout: post
slug: $TITLE
published: true
title: $@
categories:
---

" >> $POST_FILE

#create file, print utc date & local time
#open it in textmate

$EDITOR $POST_FILE
