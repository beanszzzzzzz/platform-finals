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
    nginx \
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

# Create nginx config directory
RUN mkdir -p /etc/nginx/http.d

# Copy nginx config template
COPY nginx-main.conf /etc/nginx/http.d/default.conf.template

# Copy PHP-FPM config
COPY php-fpm.conf /usr/local/etc/php-fpm.d/railway.conf

# Build assets and prepare cache
RUN APP_ENV=dev php bin/console importmap:install --no-interaction
RUN mkdir -p var/cache var/log
RUN APP_ENV=prod php bin/console cache:warmup --env=prod || true

# Ensure correct permissions
RUN chmod 755 /var/www/entrypoint.railway.sh
RUN chmod -R 777 var

ENV APP_ENV=prod

EXPOSE 8080

ENTRYPOINT ["/var/www/entrypoint.railway.sh"]