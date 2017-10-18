FROM alpine:3.6
MAINTAINER smizy

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="Apache License 2.0" \
    org.label-schema.name="smizy/php" \
    org.label-schema.url="https://github.com/smizy" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-type="Git" \
    org.label-schema.version=$VERSION \
    org.label-schema.vcs-url="https://github.com/smizy/docker-php"

ENV PHP_VERSION           ${VERSION}
ENV PHP_VERSION_MAJOR     7
ENV PECL_YAML_VERSION     2.0.0

RUN set -x \
    && apk update \
    && apk --no-cache add \
        php${PHP_VERSION_MAJOR}-curl \
        php${PHP_VERSION_MAJOR}-ctype \
        php${PHP_VERSION_MAJOR}-dom \
        php${PHP_VERSION_MAJOR}-fpm \
        php${PHP_VERSION_MAJOR}-intl \
        php${PHP_VERSION_MAJOR}-json \
        php${PHP_VERSION_MAJOR}-mbstring \
        php${PHP_VERSION_MAJOR}-opcache \
        php${PHP_VERSION_MAJOR}-openssl \
        php${PHP_VERSION_MAJOR}-pdo_mysql \
        php${PHP_VERSION_MAJOR}-pdo_pgsql \
        php${PHP_VERSION_MAJOR}-phar \
#        php${PHP_VERSION_MAJOR}-readline \
        php${PHP_VERSION_MAJOR}-session \
        php${PHP_VERSION_MAJOR}-tokenizer \
        php${PHP_VERSION_MAJOR}-xdebug \
        php${PHP_VERSION_MAJOR}-xml \
        php${PHP_VERSION_MAJOR}-zip \
        php${PHP_VERSION_MAJOR}-zlib \
        wget \
        yaml \
    ## composer
    && wget -q -O - https://getcomposer.org/installer \
         | php --  --install-dir=/usr/local/bin --filename=composer \
    ## build pecl package
    && apk --no-cache add --virtual .builddeps \
        autoconf \
        automake \
        bash \
        build-base \
        file \
        git \
        php${PHP_VERSION_MAJOR}-dev \
        re2c \
        yaml-dev \
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
    && apk del .builddeps \
    ## user
    && adduser -D  -g '' -s /sbin/nologin -u 1000 docker 

COPY bin/*  /usr/local/bin/
COPY etc/php-fpm.conf  /etc/php${PHP_VERSION_MAJOR}/

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["entrypoint.sh"]

CMD ["php-fpm"]

#CMD ["php", "-S", "0.0.0.0:9000"] # built-in php server
#CMD ["built-in"]  # exec same as the above