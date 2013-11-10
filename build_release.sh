#!/bin/bash

DATETIME=`date -u '+%Y_%m_%d_%H%M'`
RELEASE_NAME="news-$DATETIME"

jekyll build > /dev/null && \
echo "$RELEASE_NAME.tar.gz" && \
tar -c -z -f $RELEASE_NAME.tar.gz -C _site .
