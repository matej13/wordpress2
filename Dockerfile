FROM registry.access.redhat.com/rhscl/php-56-rhel7:latest

# To be able to change the Image
USER 0

ENV WP_DL https://wordpress.org/latest.tar.gz
ENV SMTP_DL https://downloads.wordpress.org/plugin/wp-mail-smtp.0.9.6.zip

# mod_authn_dbd mod_authn_dbm mod_authn_dbd mod_authn_dbm mod_echo mod_lua

RUN set -x && \
    yum -y autoremove rh-php56-php-pgsql rh-php56-php-ldap postgresql postgresql-devel postgresql-libs autoconf automake glibc-devel glibc-headers libcom_err-devel libcurl-devel libstdc++-devel make openssl-devel pcre-devel gcc gcc-c++ gdb gdb-gdbserver git libgcrypt-devel libgpg-error-devel libxml2-devel libxslt-devel openssh openssh-clients sqlite-devel zlib-devel && \
    rpm -qa|sort && \
    cd /tmp/ && \
    mkdir -p /data/wp-content && \
    mkdir -p /var/www/html && \
    curl -sSO ${SMTP_DL} && \
    curl -sSO ${WP_DL} && \
    tar xfz latest.tar.gz && \
    mv /tmp/wordpress/* /var/www/html && \
    mv /var/www/html/wp-content /tmp/ && \
    ln -s /data/wp-content /var/www/html/wp-content && \
   # sed -i 's/LogFormat "%h /LogFormat "%{X-Forwarded-For}i /' /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf && \
   # sed -i 's/;date.timezone.*/date.timezone = Europe\/Vienna/' /etc/opt/rh/rh-php56/php.ini && \
    touch /var/www/html/wp-config.php && \
    echo '<?php phpinfo(); ' > /var/www/html/pinf.php && \
    chown -R 1001:0 /data/wp-content /var/www/html && \
    chmod 777 /var/www/html/wp-config.php /var/www/html/wp-content && \
    chmod -R 777 /data/wp-content /var/opt/rh/rh-php56/lib/php/session /var/www/html/wp-content

EXPOSE 8080

USER 1001

COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
#CMD ["/bin/sh","-c","while true; do echo hello world; sleep 60; done"]
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["docker-entrypoint.sh"]

# wp-admin01
# ZD2R^0H0lq&4&X6g%5
