# User Documentation

This guide explains how to use and manage the Inception infrastructure.

## Services Provided
- **WordPress Website:** A complete CMS accessible via HTTPS.
- **Adminer:** Web-based database management for MariaDB.
- **Static Website:** A simple bonus showcase page.
- **CAdvisor:** Real-time container resource monitoring.
- **FTP Server:** Direct file access to the WordPress content.
- **Redis Cache:** Integrated caching to speed up the main site.

## Getting Started

### How to Start the Project
1. Open your terminal in the project root.
2. Run the command:
   ```bash
   make
   ```
   This will automatically build the images and start all containers.

### How to Stop the Project
- To stop the services:
  ```bash
  make down
  ```
- To restart the services without losing data:
  ```bash
  make restart
  ```

## Accessing the Stack
Once the project is running, you can access the following URLs in your browser (after configuring your hosts file):

- **Main Website:** `https://moabdels.42.fr`
- **WordPress Admin:** `https://moabdels.42.fr/wp-admin`
- **Adminer (Database):** `https://moabdels.42.fr/adminer`
- **Monitoring (CAdvisor):** `https://moabdels.42.fr/cadvisor`
- **Static Page:** `https://moabdels.42.fr/website`

## Credentials Management
Credentials are not stored in the codebase for security. You can manage them in:
- **`srcs/.env`**: General environment variables (Domain, Database names).
- **`secrets/`**: Text files containing sensitive passwords (DB root, DB user, FTP user).
  - `db_root_password.txt`
  - `db_password.txt`

## Monitoring Service Health
To check if all services are running correctly:
1. Run `docker compose -f srcs/docker-compose.yml ps`. All statuses should be "Up".
2. Check the logs for a specific service:
   ```bash
   docker compose -f srcs/docker-compose.yml logs <service_name>
   ```
3. Visit the **CAdvisor** page for visual resource metrics.
