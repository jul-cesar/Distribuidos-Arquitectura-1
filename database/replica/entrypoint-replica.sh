#!/bin/bash
set -e

echo "Iniciando réplica contra el maestro: $PRIMARY_HOST:$PRIMARY_PORT"

if [ ! -s "$PGDATA/PG_VERSION" ]; then
  echo "Clonando datos desde el maestro..."

  rm -rf "$PGDATA"/*

  export PGPASSWORD="$REPLICATION_PASSWORD"

  pg_basebackup \
    -h "$PRIMARY_HOST" \
    -p "${PRIMARY_PORT:-5432}" \
    -D "$PGDATA" \
    -U "$REPLICATION_USER" \
    -Fp -Xs -P -R

  echo "Clonado completo."
fi

echo "Arrancando PostgreSQL réplica..."
exec docker-entrypoint.sh postgres
