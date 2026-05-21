# Developer Documentation

This guide provides technical details for developers working on the Inception codebase.

## Environment Setup

### Prerequisites
- **Docker Desktop** or **Docker Engine**.
- **Make** utility.
- **Git**.

### Configuration Files
- **`srcs/docker-compose.yml`**: The main orchestration file.
- **`srcs/.env`**: Configuration template.
- **`secrets/`**: Folder for secure password files (must be created before first run).

### Secrets Setup
Create the following files in the `secrets/` directory:
- `db_root_password.txt`: The MariaDB root password.
- `db_password.txt`: The WordPress database user password.

## Building and Launching

To build the images and launch the infrastructure from scratch:
```bash
make build
make up
```
The `Makefile` ensures that the required data directories are created on the host machine before the containers start.

## Container & Volume Management

### Management Commands
- **Rebuild a specific service:** `docker compose -f srcs/docker-compose.yml up -d --build <service>`
- **View live logs:** `docker compose -f srcs/docker-compose.yml logs -f`
- **Inspect volumes:** `docker volume ls`
- **Inspect network:** `docker network inspect inception-network`

### Volume Paths
The project uses Docker **Named Volumes** mapped to the host filesystem:
- **MariaDB Data:** `/home/moabdels/data/mariadb`
- **WordPress Data:** `/home/moabdels/data/wordpress`

## Data Persistence
All data is stored on the host machine in the directories defined above. This ensures that even if you delete the containers or images (`make clean`), your database and uploaded files will persist. To perform a **total reset** (including data deletion), use:
```bash
make fclean
```

## Troubleshooting
- **Permission Errors:** Ensure the host user has `sudo` privileges or is part of the `docker` group.
- **Port 443 Conflicts:** Make sure no other web server (like Apache or local Nginx) is running on port 443.
- **CAdvisor Asset Issues:** If CSS doesn't load in CAdvisor, verify the `^~` modifier in the main Nginx config.
