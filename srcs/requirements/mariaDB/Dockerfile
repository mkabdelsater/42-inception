FROM debian:bookworm
EXPOSE 3306
# the `rm -rf` line cleans the apt cache and avoids unnecessary files in the image
RUN	apt update && \
	apt install -y --no-install-recommends --no-install-suggests \
	mariadb-server && \
	rm -rf /var/lib/apt/lists/*
COPY	conf/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY	tools/setup.sh /bin/
RUN	chmod +x /bin/setup.sh
CMD	["setup.sh", "mysqld_safe"]