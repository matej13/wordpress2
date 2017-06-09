#!/bin/sh

set -x

MY_WP_ROOT=/opt/app-root/src
WP_CONTENT_ROOT=/data/wp-content
MY_SRV=$(echo $OPENSHIFT_BUILD_NAME|awk -F'-' '{print $1"-"$2}')

WP_SITEURL=https://${MY_SRV}-${OPENSHIFT_BUILD_NAMESPACE}.${ENV_SUB_DOMAIN}

export MY_WP_ROOT WP_CONTENT_ROOT MY_SRV

if [ ! -f ${MY_WP_ROOT}/wp-config.php ]; then
  MY_SALTS=$(curl -sS https://api.wordpress.org/secret-key/1.1/salt/ )
  export MY_SALTS
fi

if [ ! -f  ${WP_CONTENT_ROOT}/index.php ]; then
  mv /tmp/wp-content/* ${WP_CONTENT_ROOT}/
  rmdir /tmp/wp-content/
  unzip /tmp/wp-mail-smtp.0.9.6.zip -d ${WP_CONTENT_ROOT}/plugins/
fi

# ENV_SUB_DOMAIN must be set in the template depend on playground or provided
# COOKIE_DOMAIN wordpress-${OPENSHIFT_BUILD_NAMESPACE}.${ENV_SUB_DOMAIN}
# WP_SITEURL must be set over template
# https://wordpress-${OPENSHIFT_BUILD_NAMESPACE}.${ENV_SUB_DOMAIN}

# WP_CONTENT_DIR must point to the pv/pvc
if [ ! -s ${MY_WP_ROOT}/wp-config.php ]; then
  # due to the fact that $table_prefix will be substituted
  # we must handle this corner case with sed
  envsubst < ${MY_WP_ROOT}/wp-config.php.template | \
  envsubst | \
  sed 's/\$ /\$/g' > ${MY_WP_ROOT}/wp-config.php
fi

exec /opt/rh/httpd24/root/sbin/httpd-scl-wrapper -D FOREGROUND
