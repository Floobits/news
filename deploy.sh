#!/bin/bash

if [ $# -ne 2 ] && [ $# -ne 1 ]
then
  echo "Usage: $0 release-name.tar.gz hostname"
  exit 0
fi

if [ $# -eq 1 ]
then
  ./build_release.sh
  TARBALL=`ls -t *.tar.gz | head -n 1`
  HOST=$1
else
  TARBALL=$1
  HOST=$2
fi

RELEASE_NAME=$(basename "$TARBALL")
RELEASE_NAME="${RELEASE_NAME%%.*}"
RELEASE_DIR="/data/releases/$RELEASE_NAME"

echo "Deploying $RELEASE_NAME to $HOST"

scp -C $TARBALL $HOST:/tmp

ssh $HOST "sudo mkdir $RELEASE_DIR && \
sudo tar xzf /tmp/$RELEASE_NAME.tar.gz --directory $RELEASE_DIR"
ssh $HOST "sudo ln -s -f $RELEASE_DIR /data/news-new && \
sudo mv -T -f /data/news-new /data/news"
