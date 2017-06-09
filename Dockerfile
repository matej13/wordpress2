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
    curl -sSO ${SMTP_DL} && \
    curl -sS ${WP_DL} | tar xfz - -C /tmp && \
    mv /tmp/wordpress/* /opt/app-root/src && \
    mv /opt/app-root/src/wp-content /tmp/ && \
    ln -s /data/wp-content /opt/app-root/src/wp-content && \
    sed -i 's/LogFormat "%h /LogFormat "%{X-Forwarded-For}i /' /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf && \
    sed -i 's/;date.timezone.*/date.timezone = Europe\/Vienna/' /etc/opt/rh/rh-php56/php.ini && \
    touch /opt/app-root/src/wp-config.php && \
    echo '<?php phpinfo(); ' > /opt/app-root/src/pinf.php && \
    chown -R 1001:0 /data/wp-content /opt/app-root/src && \
    chmod 777 /opt/app-root/src/wp-config.php /opt/app-root/src/wp-content && \
    chmod -R 777 /data/wp-content /var/opt/rh/rh-php56/lib/php/session /opt/app-root/src/wp-content

EXPOSE 8080

USER 1001

ADD containerfiles/ /
RUN chmod +x /docker-entrypoint.sh
#CMD ["/bin/sh","-c","while true; do echo hello world; sleep 60; done"]
CMD ["/docker-entrypoint.sh"]

# wp-admin01
# ZD2R^0H0lq&4&X6g%5
