FROM composer:2 AS composer_deps

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-scripts

FROM php:8.3-fpm-alpine

WORKDIR /var/www

# Install runtime and build dependencies required by Symfony + Doctrine (MySQL)
RUN apk add --no-cache \
    bash \
    icu-libs \
    libzip \
    oniguruma \
    && apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    icu-dev \
    libzip-dev \
    linux-headers \
    oniguruma-dev \
    && docker-php-ext-install -j"$(nproc)" \
    intl \
    opcache \
    pdo \
    pdo_mysql \
    zip \
    && apk del .build-deps

COPY --from=composer_deps /app/vendor ./vendor
COPY . .

RUN APP_ENV=prod php bin/console importmap:install --no-interaction

RUN mkdir -p var/cache var/log \
    && chown -R www-data:www-data /var/www \
    && chmod +x /var/www/entrypoint.sh

ENV APP_ENV=prod

ENTRYPOINT ["/var/www/entrypoint.sh"]
CMD ["php-fpm", "-F"]