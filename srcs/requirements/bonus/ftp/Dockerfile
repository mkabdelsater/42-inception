FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

COPY tools/script.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/script.sh

# Create the vsftpd run directory and the empty directory for chroot
RUN mkdir -p /var/run/vsftpd/empty && chmod 755 /var/run/vsftpd/empty

EXPOSE 21 40000-40005

ENTRYPOINT ["/usr/local/bin/script.sh"]
