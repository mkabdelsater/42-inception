FROM debian:bookworm
EXPOSE 3306
# the `rm -rf` line cleans the apt cache and avoids unnecessary files in the image
RUN	apt update && \
	apt install -y --no-install-recommends --no-install-suggests \
	mariadb-server && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/mysqld /var/log/mysql \
	&& chown -R mysql:mysql /var/run/mysqld /var/log/mysql \
	&& chmod 755 /var/run/mysqld /var/log/mysql

COPY	conf/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY	tools/init_db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_db.sh
ENTRYPOINT ["init_db.sh"]