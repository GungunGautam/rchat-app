#!/bin/sh
set -e

host="$1"
shift

export PGPASSWORD=${POSTGRES_PASSWORD:-mypassword}

until psql -h "$host" -U ${POSTGRES_USER:-myuser} -d ${POSTGRES_DB:-mydb} -c '\q'; do
  echo "Postgres is unavailable - sleeping"
  sleep 1
done

exec "$@"

