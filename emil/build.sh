#!/bin/bash
set -e

rm -rf emil-ui emil-admin-ui deployments

wget https://github.com/eaas-framework/emil-ui/archive/master.zip -O emil-ui.zip
rm -rf emil-ui-master
unzip emil-ui.zip

wget https://github.com/eaas-framework/emil-admin-ui/archive/master.zip -O emil-admin-ui.zip
rm -rf emil-admin-ui-master
unzip emil-admin-ui.zip
rm -f *.zip

cp -a ../../src/ear/target/eaas-server.ear .

docker build -t "eaas/wildfly:master-testing" .
echo "eaas/wildfly:master-testing"
