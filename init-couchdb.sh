#!/bin/sh
echo "Waiting for CouchDB to start..."
# Loop until CouchDB answers
until curl -s http://couchdb:5984 > /dev/null; do
  sleep 2
done

echo "[OK] CouchDB is up. Creating 'obsidian' database..."

# Create the database (if it doesn't exist)
curl -X PUT -u ${COUCHDB_USER}:${COUCHDB_PASSWORD} http://couchdb:5984/${COUCHDB_DB_NAME}

# Create the _users database (required for auth)
curl -X PUT -u ${COUCHDB_USER}:${COUCHDB_PASSWORD} http://couchdb:5984/_users

echo "[OK] Database initialization complete."
