#!/bin/bash

>&2 echo "Waiting for DB..."
#enable error trapping to detect broken connections and retry
set +e

COUNT=0
MAX_RETRIES=30
RETRY_DELAY_SECS=1
HOST="$1"
PORT="$2"

DB_DETECTED=0
while [ $COUNT -lt $MAX_RETRIES -a $DB_DETECTED -eq 0 ]; do
  mysqladmin ping -h$HOST -P$PORT -u$MYSQL_ADMIN_USER -p$MYSQL_ADMIN_PASS
  if [ $? -eq 0 ]; then
    DB_DETECTED=1
  else
    >&2 echo "DB is down. Retrying $COUNT/$MAX_RETRIES..."
    sleep $RETRY_DELAY_SECS
    ((COUNT+=1))
  fi
done

if [ $DB_DETECTED -eq 1 ]; then
  >&2 echo "DB is up - Ready to execute commands..."
  exit 0
else
  >&2 echo "DB is down. Max Retries reached. Shutting down server..."
  exit 1
fi
 
