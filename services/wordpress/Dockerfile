FROM docker.io/library/wordpress:latest

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
       -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

COPY install-wordpress.sh /usr/local/bin/install-wordpress.sh
RUN chmod +x /usr/local/bin/install-wordpress.sh

ENTRYPOINT ["/usr/local/bin/install-wordpress.sh"]