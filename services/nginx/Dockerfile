FROM debian:bookworm
RUN apt-get update && apt-get install -y nginx
RUN apt-get install openssl -y && mkdir -p /etc/nginx/ssl && \
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  		-keyout /etc/nginx/ssl/key.pem -out /etc/nginx/ssl/cert.pem \
  		-subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=aautin.42.fr/UID=aautin"

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default /etc/nginx/sites-enabled/default

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
