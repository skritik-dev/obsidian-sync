#!/bin/bash

export MSYS_NO_PATHCONV=1

if [ -z "$1" ]; then
  echo "[x] Error: Please specify the backup file to restore."
  echo "Usage: ./scripts/restore.sh ./backups/obsidian_backup_2026-XX-XX.tar.gz"
  exit 1
fi

BACKUP_FILE="$1"

echo "[!] WARNING: This will OVERWRITE your current database!"
echo "Restoring from: $BACKUP_FILE"
read -p "Are you sure? (y/N) " confirm
if [[ $confirm != [yY] ]]; then
  echo "Aborting."
  exit 1
fi

echo "Stopping database..."
docker compose stop couchdb

echo "Restoring data..."

docker run --rm \
  --volumes-from obsidian-db \
  -i \
  ubuntu \
  bash -c "cd / && tar xzf -" < "$BACKUP_FILE"

echo "Restarting database..."
docker compose start couchdb

echo "[OK] Restore complete. You may need to restart Obsidian."
