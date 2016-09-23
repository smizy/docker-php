FROM alpine:3.4
MAINTAINER smizy

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
ARG PHP_EXTENSION

LABEL \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="Apache License 2.0" \
    org.label-schema.name="smizy/php" \
    org.label-schema.url="https://github.com/smizy" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-url="https://github.com/smizy/docker-php"

ENV PHP_MAJOR_VERSION     ${VERSION}
ENV PECL_XDEBUG_VERSION   2.4.1
ENV PECL_YAML_VERSION     2.0.0RC8

RUN set -x \
    && apk --no-cache --update add \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
        php${PHP_MAJOR_VERSION}-curl \
        php${PHP_MAJOR_VERSION}-ctype \
        php${PHP_MAJOR_VERSION}-dom \
        php${PHP_MAJOR_VERSION}-fpm \
        php${PHP_MAJOR_VERSION}-intl \
        php${PHP_MAJOR_VERSION}-json \
        php${PHP_MAJOR_VERSION}-mbstring \
        php${PHP_MAJOR_VERSION}-opcache \
        php${PHP_MAJOR_VERSION}-openssl \
        php${PHP_MAJOR_VERSION}-pdo_mysql \
        php${PHP_MAJOR_VERSION}-pdo_pgsql \
        php${PHP_MAJOR_VERSION}-phar \
        php${PHP_MAJOR_VERSION}-xml \
        php${PHP_MAJOR_VERSION}-zip \
        php${PHP_MAJOR_VERSION}-zlib \
        ${PHP_EXTENSION} \
        wget \
        yaml \
    && ln -s /usr/bin/php7        /usr/bin/php \
    && ln -s /usr/bin/phpize7     /usr/bin/phpize \
    && ln -s /usr/bin/php-config7 /usr/bin/php-config \
    && ln -s /usr/sbin/php-fpm7   /usr/sbin/php-fpm \
    ## composer
    && wget -q -O - https://getcomposer.org/installer \
         | php --  --install-dir=/usr/local/bin --filename=composer \
    ## xdebug
    && apk --no-cache add --virtual .builddeps \
        autoconf \
        automake \
        bash \
        build-base \  
        git \
        yaml-dev \
    && apk --no-cache add --virtual .builddeps.edge \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
        php${PHP_MAJOR_VERSION}-dev \
    && wget -q -O - https://pecl.php.net/get/xdebug-${PECL_XDEBUG_VERSION}.tgz \
        | tar -xzf - -C /tmp \
    && cd /tmp/xdebug-${PECL_XDEBUG_VERSION} \
    && phpize \
    && ./configure --prefix=/usr \
    && make \
    && make test \
    && make install \
    && rm -rf /tmp/xdebug* \
    ## yaml
    && wget -q -O - https://pecl.php.net/get/yaml-${PECL_YAML_VERSION}.tgz \
        | tar -xzf - -C /tmp \
    && cd /tmp/yaml-${PECL_YAML_VERSION} \
    && phpize \
    && ./configure --prefix=/usr \
    && make \
#    && make test \
    && make install \
    && rm -rf /tmp/yaml* \ 
    ## webgrind (xdebug profile analyzer)
    && mkdir -p /code \
    && cd /code \
    && git clone https://github.com/jokkedk/webgrind \
    && cd webgrind \
    && rm -rf .git \
    && apk del .builddeps .builddeps.edge \
    ## user
    && adduser -D  -g '' -s /sbin/nologin -u 1000 docker 


COPY bin/*  /usr/local/bin/
COPY etc/php-fpm.conf  /etc/php${PHP_MAJOR_VERSION}/

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["entrypoint.sh"]

CMD ["php-fpm"]
#CMD ["built-in"]
#CMD ["php", "-S", "0.0.0.0:9000"] # as same as built-in