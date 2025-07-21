FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
        libpq-dev \
        unzip \
        git \
        curl \
    && docker-php-ext-install pdo_pgsql pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "display_errors=On\n\
display_startup_errors=On\n\
error_reporting=E_ALL" > /usr/local/etc/php/conf.d/docker-php-errors.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

COPY . /var/www/html


FROM nginx:latest AS nginx

COPY --from=php /var/www/html /var/www/html
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

# Copie PHP-FPM
COPY --from=php /usr/local/etc /usr/local/etc
COPY --from=php /usr/local/bin/php-fpm /usr/local/bin/php-fpm

CMD php-fpm -D && nginx -g 'daemon off;'