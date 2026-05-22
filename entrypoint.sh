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

# Cache warmup and migrations run as root during container init; reset ownership for php-fpm workers.
chown -R www-data:www-data var

exec "$@"