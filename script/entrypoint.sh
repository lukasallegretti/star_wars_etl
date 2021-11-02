#!/usr/bin/env bash

# User-provided configuration must always be respected.
#
# Therefore, this script must only derives Airflow AIRFLOW__ variables from other variables
# when the user did not provide their own configuration.

TRY_LOOP="20"

# Grant that a FERNET_KEY is setted up
if [[ -z $FERNET_KEY ]]; then
  echo >&2 "You must define a FERNET_KEY at your environment"
  exit 1;
fi

# Environment get
AIRFLOW__CORE__FERNET_KEY=$FERNET_KEY

# Manually set
AIRFLOW_HOME="/opt/airflow"
AIRFLOW__CORE__EXECUTOR="LocalExecutor"
AIRFLOW__CORE__LOAD_EXAMPLES=False
AIRFLOW__CORE__LOAD_DEFAULT_CONNECTIONS=False
AIRFLOW__WEBSERVER__AUTHENTICATE=True
AIRFLOW__WEBSERVER__RBAC=True
AIRFLOW__WEBSERVER__AUTH_BACKEND=airflow.contrib.auth.backends.password_auth

export \
  AIRFLOW_HOME \
  AIRFLOW__CORE__EXECUTOR \
  AIRFLOW__CORE__FERNET_KEY \
  AIRFLOW__CORE__LOAD_EXAMPLES \
  AIRFLOW__CORE__LOAD_DEFAULT_CONNECTIONS \
  AIRFLOW__WEBSERVER__AUTHENTICATE \
  AIRFLOW__WEBSERVER__AUTH_BACKEND \
  AIRFLOW__WEBSERVER__RBAC

wait_for_port() {
  local name="$1" host="$2" port="$3"
  local j=0
  while ! nc -z "$host" "$port" >/dev/null 2>&1 < /dev/null; do
    j=$((j+1))
    if [ $j -ge $TRY_LOOP ]; then
      echo >&2 "$(date) - $host:$port still not reachable, giving up"
      exit 1
    fi
    echo "$(date) - waiting for $name... $j/$TRY_LOOP"
    sleep 5
  done
}


# Check if the user has provided explicit Airflow configuration concerning the database
if [ -z "$AIRFLOW__CORE__SQL_ALCHEMY_CONN" ]; then
  if [ -z "$POSTGRES_HOST" ]; then
    echo >&2 "You must set a POSTGRES_HOST to use {Local,Celery}Executor"
    exit 1
  fi
  if [ -z "$AIRFLOW_DB" ]; then
    echo >&2 "You must set a AIRFLOW_DB to use {Local,Celery}Executor"
    exit 1
  fi
  if [ -z "$POSTGRES_USER" ]; then
    echo >&2 "You must set a POSTGRES_USER to use {Local,Celery}Executor"
    exit 1
  fi
  if [ -z "$POSTGRES_PASSWORD" ]; then
    echo >&2 "You must set a POSTGRES_PASSWORD to use {Local,Celery}Executor"
    exit 1
  fi

  : "${POSTGRES_PORT:="5432"}"
  : "${POSTGRES_EXTRAS:=""}"

  AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${AIRFLOW_DB}${POSTGRES_EXTRAS}"
  export AIRFLOW__CORE__SQL_ALCHEMY_CONN

else
  # Derive useful variables from the AIRFLOW__ variables provided explicitly by the user
  POSTGRES_ENDPOINT=$(echo -n "$AIRFLOW__CORE__SQL_ALCHEMY_CONN" | cut -d '/' -f3 | sed -e 's,.*@,,')
  POSTGRES_HOST=$(echo -n "$POSTGRES_ENDPOINT" | cut -d ':' -f1)
  POSTGRES_PORT=$(echo -n "$POSTGRES_ENDPOINT" | cut -d ':' -f2)
fi

wait_for_port "Postgres" "$POSTGRES_HOST" "$POSTGRES_PORT"

# Initialize database structure
airflow db init

# Create default connections

if [[ -z $DEFAULT_CONN_DB ]]; then
  echo 'Skipping postgres conn creation'
else
  # Postgres Connection
  PG_CONN_URI="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${DEFAULT_CONN_DB}"
  airflow connections add --conn-uri $PG_CONN_URI $PG_CONN_ID
fi

airflow users create -e 'lukasallegretti@outlook.com' -f 'Admin' -l 'Powerful' -p 'dontuseweakpasswords' -r 'Admin' -u 'admin'

case "$1" in
  webserver)
    airflow scheduler &
    exec airflow webserver
    ;;
  version)
    exec airflow "$@"
    ;;
  *)
    # The command is something like bash, not an airflow subcommand. Just run it in the right environment.
    exec "$@"
    ;;
esac