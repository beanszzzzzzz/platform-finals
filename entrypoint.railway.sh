#!/usr/bin/env sh
set -eu

cd /var/www

if [ -z "${DATABASE_URL:-}" ]; then
  if [ -n "${MYSQL_URL:-}" ]; then
    export DATABASE_URL="$MYSQL_URL"
  elif [ -n "${MYSQL_PRIVATE_URL:-}" ]; then
    export DATABASE_URL="$MYSQL_PRIVATE_URL"
  elif [ -n "${MYSQL_PUBLIC_URL:-}" ]; then
    export DATABASE_URL="$MYSQL_PUBLIC_URL"
  elif [ -n "${DATABASE_PRIVATE_URL:-}" ]; then
    export DATABASE_URL="$DATABASE_PRIVATE_URL"
  elif [ -n "${DATABASE_PUBLIC_URL:-}" ]; then
    export DATABASE_URL="$DATABASE_PUBLIC_URL"
  fi
fi

if [ -z "${DATABASE_URL:-}" ] && [ -n "${MYSQLHOST:-}" ] && [ -n "${MYSQLPORT:-}" ] && [ -n "${MYSQLDATABASE:-}" ] && [ -n "${MYSQLUSER:-}" ] && [ -n "${MYSQLPASSWORD:-}" ]; then
  export DATABASE_URL="mysql://${MYSQLUSER}:${MYSQLPASSWORD}@${MYSQLHOST}:${MYSQLPORT}/${MYSQLDATABASE}?serverVersion=8.0.32&charset=utf8mb4"
fi

mkdir -p var/cache var/log
chown -R www-data:www-data var

if [ "${APP_ENV:-prod}" = "prod" ]; then
  php bin/console cache:clear --no-warmup --env=prod || true
  php bin/console cache:warmup --env=prod
fi

if [ "${RUN_MIGRATIONS:-1}" = "1" ]; then
  php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration
fi

# Prevent permission issues from startup commands running as root.
chown -R www-data:www-data var

envsubst '${PORT}' < /etc/nginx/http.d/default.conf.template > /etc/nginx/http.d/default.conf

php-fpm -D
exec nginx -g 'daemon off;'