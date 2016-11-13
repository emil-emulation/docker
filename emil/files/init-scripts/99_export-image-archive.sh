#!/bin/bash

cd /home/bwfla/image-archive/nbd-export

echo "cleaning nbd export dir"
rm -fv *

echo "exporting images"
for i in $(ls ../images/base/*); do
	ln -vs $i .
done

for i in $(ls ../images/derivate/*); do
	ln -vs $i .
done

for i in $(ls ../images/object/*); do
	ln -vs $i .
done

for i in $(ls ../images/system/*); do
	ln -vs $i .
done

for i in $(ls ../images/user/*); do
	ln -vs $i .
done
