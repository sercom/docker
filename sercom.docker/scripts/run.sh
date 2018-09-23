#!/bin/bash

function init {
    echo "=> Updating SERCOM App..." && \
    ./init_sercom_app.sh && \
    echo "=> Checking Database..." && \
    ./init_database.sh && \
    echo "=> Checking chroot..." && \
    ./init_chroot.sh
}

function startServer {
    echo "Starting Server..." && \
    supervisord -c /etc/supervisor.conf
}

./wait_for_mysql.sh $MYSQL_SERVER $MYSQL_PORT && \
   init && \
   startServer
