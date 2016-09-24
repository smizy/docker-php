#!/bin/sh

set -eo pipefail

PHP_MODULE_SO_DIR=/usr/lib/php${PHP_VERSION_MAJOR}/modules
PHP_MODULE_INI_DIR=/etc/php${PHP_VERSION_MAJOR}/conf.d

XDEBUG_REMOTE=${XDEBUG_REMOTE:-""}
XDEBUG_PROFILER=${XDEBUG_PROFILER:-0}
XDEBUG_LOG=${XDEBUG_LOG:-0}

YAML_PARSE=${YAML_PARSE:-1}

if [ "${XDEBUG_REMOTE}" != "" ] || [ ${XDEBUG_PROFILER} -eq 1  ] ; then

  XDEBUG_INI=${PHP_MODULE_INI_DIR}/xdebug.ini

  echo zend_extension=${PHP_MODULE_SO_DIR}/xdebug.so > ${XDEBUG_INI}

  if [ "${XDEBUG_REMOTE}" != "" ]; then
      echo 'xdebug.remote_enable=on'       >> ${XDEBUG_INI} 
      echo 'xdebug.remote_autostart=on'    >> ${XDEBUG_INI} 

      if [ "${XDEBUG_REMOTE}" = "1" ] || [ "${XDEBUG_REMOTE}" = "connect_back" ]; then
        echo 'xdebug.remote_connect_back=on' >> ${XDEBUG_INI} 
      else 
        echo 'xdebug.remote_host='${XDEBUG_REMOTE} >> ${XDEBUG_INI}
      fi

      if [ "${XDEBUG_LOG}" != "" ]; then
        echo 'xdebug.remote_log=/proc/self/fd/2' >> ${XDEBUG_INI} 
      fi
  fi

  if [ ${XDEBUG_PROFILER} -eq 1 ]; then
      echo 'xdebug.profiler_enable_trigger=on' >> ${XDEBUG_INI}
  fi

fi

if [ "${YAML_PARSE}" = "1" ]; then
  echo extension=${PHP_MODULE_SO_DIR}/yaml.so > ${PHP_MODULE_INI_DIR}/yaml.ini
  echo "yaml.decode_php=0" >> ${PHP_MODULE_INI_DIR}/yaml.ini
fi

if  [ "$1" = "php-fpm" ]; then
  exec php-fpm

elif [ "$1" = "built-in" ]; then
  shift

  if [ "$1" = "" ]; then
    exec php -S 0.0.0.0:9000
  fi 

  exec "$@"
fi

exec "$@"