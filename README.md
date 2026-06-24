*This project has been created as part of the 42 curriculum by moabdels.*

# Inception

## Description
This project introduces Containers through Docker. Containerization
is the backbone of modern web architecture, giving us control over all elements
of a techstack.

The project is also a change to develop some System Administration skills as
we set up a complex infrastructure using Docker. The goal is to containerize a
LEMP stack (Nginx, MariaDB, and WordPress with PHP-FPM) and several bonus services, ensuring they are properly orchestrated, secure, and persistent.

Key components:
- **WordPress + PHP-FPM:** The content management system.
- **MariaDB:** Secure database for WordPress.
- **Nginx:** The only entry point, configured with TLSv1.2/v1.3.
- **Bonus Services:** Redis cache, FTP server, Adminer, Static Website, and CAdvisor.

## Instructions

### Prerequisites
- `sudo` privileges on the machine running the program.
- Docker and Docker Compose installed.
- Domain mapping in `/etc/hosts`, add the following line if it's not present:
`127.0.0.1  moabdels.42.fr`
- Javascript enabled to view the website.

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

### Evaluation Commands

#### Testing that NGINX is only accessible via 443:

 Check which ports are bound to host machine:
- `docker compose -f srcs/docker-compose.yml ps`
- Under the PORTS Column for the nginx container, you should *only* see: `0.0.0.0:443/tcp`
- Test connecton on 443 `curl -vk https://moabdels.42.fr --connect-timeout 2` you should see a successful connection and the HTML output or a redirect to Wordpress.
- Check that NGINX is the only entrypoint: `nc -zv localhost 3306` to test MariaDB and `nc -zv localhost 9000` to test PHP-FPM, both should say `Connection refused` proving they're isolated within the Docker network and can only be reached through Nginx

`docker compose ps`: Lists containers for a Compose project, with current status and exposed ports.
`nc -zv`: invoke the netcat command with the verbose flag and only scanning
for listening daemons.


Note: per the bonus rules, our FTP server is allowed to have it's own ports open, for us
that's **21** and **40000-40005**.

#### Testing that NGINX cannot be accessed through http (port 80):

`curl -v http://moabdels.42.fr --connect-timeout 2`

#### Demosntrating TLS

Force a connection using only 1.3/1.2 -> You should see SSL connection using TLSv1.3.

`curl -vk --tlsv1.3 https://moabdels.42.fr 2>&1 | grep "SSL connection using"`

`curl -vk --tlsv1.2 --tls-max 1.2 https://moabdels.42.fr 2>&1 | grep "SSL connection using"`

Force a connection using 1.1 -> Should fail as NGINX is configured to reject this.

`curl -vk --tlsv1.1 --tls-max 1.1 https://moabdels.42.fr`

Verify the config file:

`docker exec -it nginx grep "ssl_protocols" /etc/nginx/nginx.conf`

#### Logging in to services

Wordpress: moabdels.42.fr/wp-admin/
User: `moabdels`
Pass: `secure_admin_password`

Accessing the Database: 
Via Adminer: https://moabdels.42.fr/adminer
System: MySQL
Server: mariadb
Username: wp_user
Password: pass
Database: wordpress_db

Via CLI:
`docker exec -it mariadb mysql -u wp_user -p`
When prompted for a password: `pass`
to use the root user instead:
`docker exec -it mariadb mysql -u root -p`

- See all databases: `SHOW DATABASES`
- Select wordpress db: `USE wordpress_db`
- See all tables: `SHOW TABLES;`
- See users: `SELECT user_login, user_email FROM wp_users;`
leave the CLI with `exit`

## Project Description & Design Choices

### Docker


What a container 'is' is a minimalist VM, the barebones needed to run
a particular service. This is useful in modern web dev because we
rely on multiple services, and we need to be able to manage and replicate
them separately.

The main benefit of containers is ... containement. Each process
and part of our stack can exist in total isolation to each other
part of our tech stack, this entails the following benefits:

- each container has everything it needs for it's process to function without relying on the host machine. This lets us run the container on any machine.

- better security: a breach in the database for example will not affect the front end and vice versa.

- because each container is running separately they're easier to manage and Docker can serve as management architecture.

- because containers are ... self contained, they can run anywhere. No (less) headaches when migrating and no endless "it runs on my machine" debacles.


### Virtual Machines vs Docker
Virtual Machines (VMs) virtualize the entire hardware layer, including the kernel, which makes them heavy and resource-intensive. Docker, on the other hand, uses *OS-level virtualization*(containers), sharing the host's kernel while isolating the application processes. This makes containers significantly lighter, faster to start, and more portable.

This environment isolates each process (hence the term Container), ideally
preventing processes running inside the container escaping it. This lets us
prevent these processes from accessing data outside the container, or using
resources outside the container.

### Images and Docker Compose

An image is a package containing everything a conainer needs to run:
files, binaries, libraries and configurations. Each container should
ideally run one service, Docker encourages this by making Containers
*immutable*. Containers are read only, any changes are 'layered' on top of
the container as their own images.

Immutablity exists to prevent things such as configuration drift,
untracked changes, broad attack surfaces, and inconsistent dev environments
across services, basically all "It Works on My Machine" issues.

### Secrets vs Environment Variables
Environment variables are useful for non-sensitive configuration but can be easily exposed (e.g., via `docker inspect`). For sensitive data like passwords, we use *Docker Secrets*. These are stored in files mounted at `/run/secrets/`, ensuring they are never logged or stored in the image layers.

### Docker Network vs Host Network
Using the *Host Network* removes isolation between the container and the host, which is a security risk. In this project, we use a dedicated *Bridge Network* (`inception-network`). This ensures containers can only communicate with each other using internal IPs/names, and only specific ports are exposed to the host (like Nginx's 443).

### Docker Volumes vs Bind Mounts
Bind mounts depend on the specific directory structure of the host machine. *Named Volumes* are managed by Docker and are more portable and secure. In this project, we use named volumes (`mariadb_data` and `wordpress_data`) that point to a specific persistent path on the host (`/home/moabdels/data`), ensuring data persists even if containers are deleted.

### Credentials Management
No passwords are hardcoded inside the Dockerfile, in `docker-compose.yml`
we define and mount secrets for the WordPress admin, the second WordPress user 
and the FTP user.

## Resources
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Official Docs](https://nginx.org/en/docs/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [WP-CLI Handbook](https://make.wordpress.org/cli/handbook/)
- [vsftpd Reference](http://vsftpd.beasts.org/vsftpd_conf.html)

### AI Usage
AI was used to:
- Draft the initialization scripts for MariaDB and FTP.
- Generate the Makefile.
- Troubleshoot Nginx location block prioritization issues.
- Generate boilerplate CSS for the static website.
