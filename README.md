*This project has been created as part of the 42 curriculum by moabdels.*

# Inception

## Description
This project is a System Administration exercise that involves setting up a complex infrastructure using Docker. The goal is to containerize a LEMP stack (Nginx, MariaDB, and WordPress with PHP-FPM) and several bonus services, ensuring they are properly orchestrated, secure, and persistent.

Key components:
- **Nginx:** The only entry point, configured with TLSv1.2/v1.3.
- **MariaDB:** Secure database for WordPress.
- **WordPress + PHP-FPM:** The content management system.
- **Bonus Services:** Redis cache, FTP server, Adminer, Static Website, and CAdvisor.

## Instructions

### Prerequisites
- Docker and Docker Compose installed.
- Domain mapping in `/etc/hosts`:
  ```text
  127.0.0.1  moabdels.42.fr
  ```

### Execution
1. **Clone the repository:**
   ```bash
   git clone https://github.com/mkabdelsater/42-inception.git inception
   cd inception
   ```
2. **Build and start the services:**
   ```bash
   make
   ```
3. **Access the services:**
   - WordPress: `https://moabdels.42.fr`
   - Adminer: `https://moabdels.42.fr/adminer`
   - Static Website: `https://moabdels.42.fr/website`
   - CAdvisor: `https://moabdels.42.fr/cadvisor`

### Management Commands
- `make build`: Build Docker images.
- `make up`: Start containers in the background.
- `make down`: Stop and remove containers.
- `make restart`: Restart all services.
- `make clean`: Remove containers and untagged images.
- `make fclean`: Full clean, including volumes and data directories.
- `make re`: Rebuild and restart everything from scratch.

## Project Description & Design Choices

### Virtual Machines vs Docker
Virtual Machines (VMs) virtualize the entire hardware layer, including the kernel, which makes them heavy and resource-intensive. Docker, on the other hand, uses **OS-level virtualization** (containers), sharing the host's kernel while isolating the application processes. This makes containers significantly lighter, faster to start, and more portable.

### Secrets vs Environment Variables
Environment variables are useful for non-sensitive configuration but can be easily exposed (e.g., via `docker inspect`). For sensitive data like passwords, we use **Docker Secrets**. These are stored in files mounted at `/run/secrets/`, ensuring they are never logged or stored in the image layers.

### Docker Network vs Host Network
Using the **Host Network** removes isolation between the container and the host, which is a security risk. In this project, we use a dedicated **Bridge Network** (`inception-network`). This ensures containers can only communicate with each other using internal IPs/names, and only specific ports are exposed to the host (like Nginx's 443).

### Docker Volumes vs Bind Mounts
Bind mounts depend on the specific directory structure of the host machine. **Named Volumes** are managed by Docker and are more portable and secure. In this project, we use named volumes (`mariadb_data` and `wordpress_data`) that point to a specific persistent path on the host (`/home/moabdels/data`), ensuring data persists even if containers are deleted.

## Resources
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Official Docs](https://nginx.org/en/docs/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [WP-CLI Handbook](https://make.wordpress.org/cli/handbook/)
- [vsftpd Reference](http://vsftpd.beasts.org/vsftpd_conf.html)

### AI Usage
AI was used to:
- Draft the initialization scripts for MariaDB and FTP.
- Troubleshoot Nginx location block prioritization issues.
- Organize the documentation structure.
- Generate boilerplate CSS for the static website bonus.
All AI-generated code was manually reviewed, tested, and integrated to ensure compliance with project requirements.
