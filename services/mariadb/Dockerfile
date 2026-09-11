FROM debian:bookworm
RUN apt-get update && apt-get -y install mariadb-server

RUN mkdir -p /var/lib/mysql/ && chown mysql:mysql /var/lib/mysql/

COPY ./entrypoint.sh /entrypoint.sh
COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
