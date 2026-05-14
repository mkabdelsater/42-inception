FROM debian:bookworm
EXPOSE 3306
# the `rm -rf` line cleans the apt cache and avoids unnecessary files in the image
RUN	apt update && \
	apt install -y --no-install-recommends --no-install-suggests \
	mariadb-server && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/mysqld \
	&& chown -R mysql:mysql /var/run/mysqld \
	&& chmod 755 /var/run/mysqld

COPY	conf/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY	tools/init_db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_db.sh

ENV MYSQL_ROOT_PASSWORD=root \
    MYSQL_DATABASE=app_db \
    MYSQL_USER=app_user \
    MYSQL_PASSWORD=app_pass

ENTRYPOINT ["init_db.sh"]