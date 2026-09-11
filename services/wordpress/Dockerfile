FROM debian:bookworm
RUN apt update && apt install wget curl zip unzip -y

RUN apt install php php-fpm php-mysql php-xml php-gd php-mbstring php-curl php-phar -y
RUN mkdir -p /run/php

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
