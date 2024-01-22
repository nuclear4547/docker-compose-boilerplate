FROM php:8.3-fpm-alpine

ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN addgroup -g ${GID} --system docker_dev
RUN adduser -G docker_dev --system -D -s /bin/sh -u ${UID} docker_dev

COPY ./php/php.ini /usr/local/etc/php/conf.d/php-custom.ini
COPY ./php/php-fpm.conf /usr/local/etc/php-fpm.conf

RUN docker-php-ext-install pdo pdo_mysql

RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/5.3.4.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis
    
USER docker_dev

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
