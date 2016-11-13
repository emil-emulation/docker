#!/bin/sh


bindmount() {
    if [ $# -ne 2 ]; then
        echo Fatal: wrong number of arguments to bindmount
        exit 1
    fi

    bindfs -u bwfla --create-for-user=$(stat -c "%u" "$1") --create-for-group=$(stat -c "%g" "$1") "$1" "$2"
}

test -d /eaas/emil-environments && bindmount /eaas/emil-environments /home/bwfla/emil-environments
test -d /eaas/emil-object-environments && bindmount /eaas/emil-object-environments /home/bwfla/emil-object-environments

echo mount log
test -d /eaas/log && bindmount /eaas/log /home/bwfla/log
echo mount config
test -d /eaas/config && bindmount /eaas/config /home/bwfla/.bwFLA
echo mounting imagearchive
test -d /eaas/image-archive && bindmount /eaas/image-archive /home/bwfla/image-archive
echo mount objects
test -d /eaas/objects && bindmount /eaas/objects /home/bwfla/objects
echo mounting sw
if test -d /eaas/software-archive ; then
    bindmount /eaas/software-archive /home/bwfla/software-archive
fi
