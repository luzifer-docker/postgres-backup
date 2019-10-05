# Luzifer-Docker / postgres-backup

Container with a small backup script to be running next to a `postgres` container for backups.

## Usage

```yaml
---

version: "3.7"
services:

  postgres:
    image: postgres:9.6
    volumes:
      - /var/lib/postgresql/data:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=topsecret
    restart: always
    stop_grace_period: 2m30s

  postgres_backup:
    image: luzifer/postgres-backup:latest
    volumes:
      - /data/pgbackup:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=topsecret
    restart: always

...
```

If you are starting this `docker-compose.yml` file you'll get a running PostgreSQL database with a backup container next to it which will dump your databases to disk every hour.

For more configuration options see [`pgbackup.sh`](pgbackup.sh) script and look for variables.
