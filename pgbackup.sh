#!/bin/bash
set -euo pipefail

if [[ -z ${PGPASSWORD:-} ]]; then
	echo 'No $PGPASSWORD was present, aborting.'
	exit 1
fi

set -x # Do NOT set earlier not to log the password

# Remove old backups older than N days (default 2d)
DELETE_OLDER_THAN=${DELETE_OLDER_THAN:-2}

# This directory is exposed by the postgres image
TARGET_DIR="${TARGET_DIR:-/var/lib/postgresql/data}"

# Set defaults for PostgreSQL connect
PGHOST="${PGHOST:-postgres}"
PGUSER="${PGUSER:-postgres}"

while [ 1 ]; do

	BACKUP_DATE=$(date +%Y-%m-%d_%H-%M-%S)

	pg_dumpall -h "${PGHOST}" -U "${PGUSER}" -g -f "${TARGET_DIR}/${BACKUP_DATE}_globals.sql"
	gzip "${TARGET_DIR}/${BACKUP_DATE}_globals.sql"

	# Create backup
	for dbname in $(psql -h "${PGHOST}" -U "${PGUSER}" -q -A -t -c "SELECT datname FROM pg_database" | grep -vE 'template[01]'); do
		TARGET_FILE="${TARGET_DIR}/${BACKUP_DATE}_${dbname}.sql"
		pg_dump -h "${PGHOST}" -U "${PGUSER}" -C "${dbname}" >"${TARGET_FILE}"
		gzip "${TARGET_FILE}"
	done

	# Cleanup old backups
	find "${TARGET_DIR}" -mtime "${DELETE_OLDER_THAN}" \( -name '*.sql.gz' -or -name '*.sql' \) -delete

	# Sleep until next full hour
	sleep $((3600 - $(date +%s) % 3600))

done
