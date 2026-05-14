FROM debian:bookworm

RUN apt update -y

RUN apt install vsftpd -y

COPY ./tools/script.sh /

CMD ["/script.sh"]
