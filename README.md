# Obsidian Sync: An Open Source Tool
---

A self-hosted sync solution for [Obsidian](https://obsidian.md) using CouchDB and Tailscale. Securely sync your notes across all your devices through your private Tailscale network.

![Sync between multiple devices](/screenshots/sync_ss.png)

## Features
---

- **Self-hosted sync** — Full control over your data with CouchDB
- **Secure networking** — Access your sync server securely via Tailscale VPN
- **Docker-based** — Easy deployment with Docker Compose
- **Backup & Restore** — Built-in scripts for data management
- **Auto-initialization** — Database setup happens automatically on first run

## Installation Required
---

- [Docker](https://www.docker.com/) & Docker Compose
- [Tailscale account](https://tailscale.com/) with an auth key
- [Obsidian](https://obsidian.md) with the [Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync) plugin

## Quick Start
---

### 1. Clone the repository

```bash
git clone https://github.com/skritik-dev/obsidian-sync.git
cd obsidian-sync
```

### 2. Configure environment

```bash
cp .env.example .env
```

Edit `.env` with your credentials:

```env
# CouchDB Credentials
COUCHDB_USER=admin
COUCHDB_PASSWORD=your_secure_password
COUCHDB_DB_NAME=obsidian

# Tailscale Configuration
# Generate at: https://login.tailscale.com/admin/settings/keys
# Enable `Reusable` or `Ephemeral` tags
TS_AUTHKEY=tskey-auth-xxxxx
TS_HOSTNAME=obsidian-server
```

### 3. Start the services

```bash
docker compose up -d
```

### 4. Configure Obsidian

1. Go to settings -> Community plugins -> Install the **Self-hosted LiveSync** plugin in Obsidian
2. Open LiveSync plugin settings and configure:
    - Search for Active remote configuration
        - Select CouchDB
        - Add TailScale connection url
        - Add CouchDB credentials
        - Add CouchDB database name
3. Copy the Setup URI
4. Paste this setup URI to your other devices with you want to connect

> **Note:**  
Make sure your all your devices are connected to Tailscale to access the sync server.
> Change the sync setting in the **Self-hosted LiveSync** plugin to LiveSync

## Architecture

Instead of exposing ports locally, the `couchdb` container networks directly through the `tailscale` container. This ensures your data never leaves your private mesh network.

![Architecture](/screenshots/arch.png)

## Project Structure

```
obsidian-sync/
└── .git
├── docker-compose.yml    # Main orchestration file
├── .env.example          # Environment template
├── couchdb/
│   ├── Dockerfile        # Custom CouchDB image
│   └── local.ini         # CouchDB configuration
├── scripts/
│   ├── backup.sh         # Database backup script
│   └── restore.sh        # Database restore script
└── backups/              # Backup storage directory 
└── .gitignore
└── README.md            
```

## Backup & Restore
---

### Create a backup

```bash
./scripts/backup.sh
```

Backups are saved to `./backups/` with timestamps.

### Restore from backup

```bash
./scripts/restore.sh ./backups/obsidian_backup_2026-01-18_12-00-00.tar.gz
```

> **WARNING!** Restoring will **overwrite** your current database. Make sure to backup first!

## Configuration
---

### CouchDB Settings

Custom CouchDB image (`couchdb/local.ini`) is pre-configured for Obsidian LiveSync:

| Setting | Value | Description |
|---------|-------|-------------|
| `max_document_size` | 200MB | Large vault support |
| `max_http_request_size` | 4GB | Large file uploads |
| `enable_cors` | true | Cross-origin requests |
| `require_valid_user` | true | Authentication required |

### Tailscale Settings

| Variable | Description |
|----------|-------------|
| `TS_AUTHKEY` | Authentication key from Tailscale admin console |
| `TS_HOSTNAME` | Device name on your Tailnet |

## Troubleshooting
---

### Container won't start

```bash
# Check container logs
docker compose logs -f

# Verify Tailscale connection
docker exec obsidian-tailscale tailscale status
```

### Can't connect from Obsidian

1. Ensure your device is on Tailscale
2. Verify the hostname: `ping obsidian-server`
3. Check CouchDB is healthy: `curl http://obsidian-server:5984`

### CORS Error
Go to LiveSync plugins setting and set `Use Request API to avoid CORS problem` as `true`.

### Tailscale & Connectivity

1. Check Key Expiry: Tailscale Auth Keys expire every 90 days by default. Go to the [Tailscale Admin Console](https://login.tailscale.com/admin/machines). Disable key expiry.
2. Verify VPN State: Ensure the Tailscale app is **Active** (Connected) on both your Docker host and your client device (Phone/Laptop).
3. Check Network Identity: Ensure you are logged into the *same* Tailscale account on all devices.

### Reset everything

```bash
docker compose down -v
docker compose up -d
```

## Contributions
---

Contributions are welcome! Please feel free to submit a Pull Request.
