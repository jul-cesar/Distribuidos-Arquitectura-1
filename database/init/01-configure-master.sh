#!/bin/bash
set -e

echo "Configurando PostgreSQL Master para replicación..."

# Crear usuario de replicación
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER $REPLICATION_USER WITH REPLICATION ENCRYPTED PASSWORD '$REPLICATION_PASSWORD';
EOSQL

# Configurar postgresql.conf para replicación
cat >> ${PGDATA}/postgresql.conf <<EOF

# Configuración de replicación
wal_level = replica
max_wal_senders = 10
max_replication_slots = 10
hot_standby = on
EOF

# Configurar pg_hba.conf para permitir conexiones de replicación
echo "host replication $REPLICATION_USER all md5" >> ${PGDATA}/pg_hba.conf

echo "Configuración del Master completada."
