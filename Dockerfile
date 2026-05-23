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

# Create nginx config directly (no template needed)
RUN mkdir -p /etc/nginx/http.d && cat > /etc/nginx/http.d/default.conf << 'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/public;
    index index.php;

    location / {
        try_files $uri /index.php$is_args$args;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_read_timeout 60;
    }

    location ~ ^/index\.php(/|$) {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
        fastcgi_param HTTPS off;
        fastcgi_buffer_size 32k;
        fastcgi_buffers 8 16k;
    }

    location ~* \.(?:css|js|jpg|jpeg|gif|png|ico|svg|woff2?)$ {
        expires 7d;
        add_header Cache-Control "public";
        access_log off;
        try_files $uri /index.php$is_args$args;
    }

    location ~ /\. {
        deny all;
    }
}
EOF

# Build assets and prepare cache
RUN APP_ENV=dev php bin/console importmap:install --no-interaction
RUN mkdir -p var/cache var/log
RUN APP_ENV=prod php bin/console cache:warmup --env=prod || true

# Ensure correct permissions
RUN chmod 755 /var/www/entrypoint.railway.sh
RUN chmod -R 777 var

ENV APP_ENV=prod

EXPOSE 80

ENTRYPOINT ["/var/www/entrypoint.railway.sh"]