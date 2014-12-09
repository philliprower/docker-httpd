FROM philliprower/httpd
MAINTAINER Phillip Rower <philliprower@gmail.com>

ENV HTTPD_PREFIX /usr/local/apache2
ENV DOMAIN localhost
ENV CONFD_DIR ${HTTPD_PREFIX}/conf/conf.d/
ENV SSL_DIR ${HTTPD_PREFIX}/ssl/
ENV CERT_PATH ${SSL_DIR}certs
ENV KEY_PATH ${SSL_DIR}private
RUN mkdir -p $SSL_DIR \
	&& mkdir -p $CONFD_DIR
ADD openssl.cnf $SSL_DIR
ADD conf.d $CONFD_DIR
RUN apt-get update \
	&& apt-get install openssl \
	&& mkdir -p $CERT_PATH \
	&& mkdir -p $KEY_PATH \
	&& openssl genrsa -out $KEY_PATH/$DOMAIN.key 2048 \
	&& openssl req -new -nodes -key $KEY_PATH/$DOMAIN.key -out $CERT_PATH/$DOMAIN.csr -config ${SSL_DIR}openssl.cnf -batch \
	&& openssl x509 -req -days 365 -in $CERT_PATH/$DOMAIN.csr -signkey $KEY_PATH/$DOMAIN.key -out $CERT_PATH/$DOMAIN.crt \
	&& echo "Include ${CONFD_DIR}*.conf" >> ${HTTPD_PREFIX}/conf/httpd.conf

EXPOSE 80
EXPOSE 443
CMD ["httpd", "-DFOREGROUND"]

