#!/bin/bash

cd $SERCOM_SRC_FOLDER && \
git pull release v2/cherrypy14 && \
#Replace dynamic env variables...
sed -i -e "s/<SERCOM_DB_USER>/$SERCOM_DB_USER/" -e "s/<SERCOM_DB_PASS>/$SERCOM_DB_PASS/" -e "s/<SERCOM_DB_NAME>/$SERCOM_DB_NAME/" -e "s/<MYSQL_SERVER>/$MYSQL_SERVER/" -e "s/<MYSQL_PORT>/$MYSQL_PORT/" prod.web.cfg && \

sed -i -e "s/<SERCOM_DB_USER>/$SERCOM_DB_USER/" -e "s/<SERCOM_DB_PASS>/$SERCOM_DB_PASS/" -e "s/<SERCOM_DB_NAME>/$SERCOM_DB_NAME/" -e "s/<MYSQL_SERVER>/$MYSQL_SERVER/" -e "s/<MYSQL_PORT>/$MYSQL_PORT/" prod.backend.cfg

