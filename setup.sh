#! /bin/bash

mkdir -p data/databases/logs
mkdir -p data/databases/mysql-sercom

mkdir -p data/sercom/chroot
mkdir -p data/sercom/log
mkdir -p data/sercom/tmp

#required for compilation/running of TPs since they are executed with
#the sercom-backend user within the Tester class
chmod o+w data/sercom/tmp

docker-compose build

