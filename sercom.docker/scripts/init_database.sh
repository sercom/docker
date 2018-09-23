#!/bin/bash

RESULT=$(echo "SELECT 1 FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '$SERCOM_DB_NAME';" | mysql -u$MYSQL_ADMIN_USER -p$MYSQL_ADMIN_PASS -h$MYSQL_SERVER -P$MYSQL_PORT --skip-column-names)
STATUS=$?
if [ $STATUS -ne 0 ]; then
    echo "It was not possible to establish a connection to the DB server. $MYSQL_SERVER:$MYSQL_PORT not enabled for user $MYSQL_ADMIN_USER."
    exit 1
fi


if [ "$RESULT" -eq 1 ]; then
    echo "An existing Sercom DB was found at $MYSQL_SERVER. Reusing Database."
else
    echo "No Sercom DB was found at $MYSQL_SERVER. Creating new DB..."
    CURRENT_IP=$(hostname -i)
    echo "CREATE DATABASE $SERCOM_DB_NAME; GRANT ALL PRIVILEGES ON $SERCOM_DB_NAME.* TO $SERCOM_DB_USER@$CURRENT_IP IDENTIFIED BY '$SERCOM_DB_PASS'; FLUSH PRIVILEGES;" | mysql -u$MYSQL_ADMIN_USER -p$MYSQL_ADMIN_PASS -h$MYSQL_SERVER -P$MYSQL_PORT

    echo "Creating schema in DB..."
    mysql -u$SERCOM_DB_USER -p$SERCOM_DB_PASS -h$MYSQL_SERVER -P$MYSQL_PORT $SERCOM_DB_NAME < "$SERCOM_SRC_FOLDER/doc/02.database_setup/sercom.schema.sql"

    echo "Creating base entities..."
    . $VIRTUALENV_FOLDER/bin/activate
    cd "$SERCOM_SRC_FOLDER"
    tg-admin --config=prod.backend.cfg shell < "doc/02.database_setup/data_initialize.py"
    deactivate
fi

