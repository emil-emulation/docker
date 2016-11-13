#!/bin/bash
set -x

#DOCKER=eaas/bwfla:eaas-dev

set -e
releaseContainer()
{
    RET=$?
    set +e

    if [ -n "$CONTAINER" ]
    then
        docker rm -f "$CONTAINER" 1> /dev/null
    fi

    return $RET
}

#docker pull "$DOCKER"

BASEDIR=$1

VOLUMES="-v $BASEDIR/log:/home/bwfla/log"

if [! -d "$BASEDIR/appserver"]; then
  echo "appserver not found" 
  return -1
fi

VOLUMES="$VOLUMES -v $BASEDIR/appserver:/home/bwfla/bw-fla-server"

if [ -d "$BASEDIR/emil-ui" ]; then
  echo "found local emil-ui: adding to container"
  VOLUMES="$VOLUMES -v $BASEDIR/emil-ui:/home/bwfla/emil-ui"
fi

if [ -d "$BASEDIR/emil-admin-ui" ]; then
  echo "found local emil-admin-ui: adding to container"
  VOLUMES="$VOLUMES -v $BASEDIR/emil-admin-ui:/home/bwfla/emil-admin-ui"
fi

if [ -d "$BASEDIR/config" ]; then
  echo "found local config: adding to container"
  VOLUMES="$VOLUMES -v $BASEDIR/config:/home/bwfla/.bwFLA"
fi

if [ -d "$BASEDIR/objects" ]; then
  echo "found local objects: adding to container"
  VOLUMES="$VOLUMES -v $BASEDIR/objects:/home/bwfla/objects"
fi

if [ -d "$BASEDIR/image-archive" ]; then
  echo "found local image-archive: adding to container"
  VOLUMES="$VOLUMES -v $BASEDIR/image-archive:/home/bwfla/image-archive"
fi

CONTAINER="bwFLA-Container_$$"

## need to run in priviliged mode to be able to run sheepshaver (running sysctl)
docker run --privileged -p 8080:80 --name "$CONTAINER" --net bridge -it "eaas/bwfla:emil-base" 
trap releaseContainer EXIT QUIT INT TERM

echo "FINISHED!"
