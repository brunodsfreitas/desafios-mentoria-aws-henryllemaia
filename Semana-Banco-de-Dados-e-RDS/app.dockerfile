FROM php:8.3.3-apache

RUN apt-get update \
    && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

WORKDIR /var/www/html

COPY app.php /var/www/html/index.php
COPY config.php /var/www/html/