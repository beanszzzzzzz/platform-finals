#!/usr/bin/env sh
set -eu

cd /var/www

mkdir -p var/cache var/log
chown -R www-data:www-data var

if [ "${APP_ENV:-prod}" = "prod" ]; then
  php bin/console cache:clear --no-warmup --env=prod || true
  php bin/console cache:warmup --env=prod
fi

if [ "${RUN_MIGRATIONS:-0}" = "1" ]; then
  php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration
fi

# Prevent permission issues from startup commands running as root.
chown -R www-data:www-data var

envsubst '${PORT}' < /etc/nginx/http.d/default.conf.template > /etc/nginx/http.d/default.conf

php-fpm -D
exec nginx -g 'daemon off;'