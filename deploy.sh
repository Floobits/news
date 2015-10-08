#!/bin/bash

if [ $# -eq 0 ]
then
  echo "Usage: $0 release-name.tar.gz hostname0 hostname1 hostname2 ..."
  exit 0
fi

echo $1 | grep '\.tar\.gz$'

if [ $? -eq 0 ]
then
  TARBALL=$1
  shift
else
  echo "Building tarball..."
  TARBALL=`./build_release.sh`
  echo "Built $TARBALL"
fi

RELEASE_NAME=$(basename "$TARBALL")
RELEASE_NAME="${RELEASE_NAME%%.*}"
RELEASE_DIR="/data/releases/$RELEASE_NAME"

for HOST in $@
do
  echo "Deploying $RELEASE_NAME to $HOST"

  scp -C $TARBALL $HOST:/tmp

  (ssh $HOST "sudo mkdir $RELEASE_DIR && \
    sudo tar xzf /tmp/$RELEASE_NAME.tar.gz --directory $RELEASE_DIR && \
    sudo ln -s -f $RELEASE_DIR /data/news-new && \
    sudo mv -T -f /data/news-new /data/news"

  if [ $? -eq 0 ]
  then
    curl -X POST https://$USER:$USER@dev00.floobits.com/deploy/news/$HOST
  else
    echo "OMG DEPLOY FAILED"
  fi) &
done
