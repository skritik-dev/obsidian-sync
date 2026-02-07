#!/bin/bash

export MSYS_NO_PATHCONV=1

# Configuration
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="obsidian_backup_$TIMESTAMP.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

echo "Starting backup for Obsidian Database..."

# Improved Method: Stream output directly to host file
# 'tar czf -' tells tar to write to Standard Output instead of a file
# Using alpine for faster backups (also less storage)
docker run --rm \
  --volumes-from obsidian-db \
  alpine \
  tar czf - /opt/couchdb/data > "$BACKUP_DIR/$BACKUP_FILE"

echo "[OK] Backup complete: $BACKUP_DIR/$BACKUP_FILE"
