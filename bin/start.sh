#!/usr/bin/env bash
set -euo pipefail

# Detectar diretório do app
if [ -f /app/public/index.php ]; then
  cd /app
else
  cd /var/www/html 2>/dev/null || cd "$(pwd)"
fi

# Garantir diretórios necessários
mkdir -p bootstrap/cache \
         storage/app/public \
         storage/framework/cache \
         storage/framework/sessions \
         storage/framework/views \
         storage/logs

# Criar .env se não existir (a partir das ENV do container)
if [ ! -f .env ]; then
  cat > .env <<EOF
APP_NAME=${APP_NAME:-Gerenciar}
APP_ENV=${APP_ENV:-codecanyon}
APP_KEY=${APP_KEY:-}
APP_DEBUG=${APP_DEBUG:-false}
APP_URL=${APP_URL:-http://localhost}

DB_CONNECTION=${DB_CONNECTION:-mysql}
DB_HOST=${DB_HOST:-mysql}
DB_PORT=${DB_PORT:-3306}
DB_DATABASE=${DB_DATABASE:-laravel}
DB_USERNAME=${DB_USERNAME:-root}
DB_PASSWORD=${DB_PASSWORD:-}

CACHE_DRIVER=${CACHE_DRIVER:-file}
SESSION_DRIVER=${SESSION_DRIVER:-file}
QUEUE_CONNECTION=${QUEUE_CONNECTION:-sync}

REDIRECT_HTTPS=${REDIRECT_HTTPS:-false}
EOF
  chmod 644 .env
fi

# Se APP_KEY estiver vazio, gerar um
if ! grep -q "^APP_KEY=base64:" .env || [ -z "${APP_KEY:-}" ]; then
  php artisan key:generate --force || true
fi

# Limpar/otimizar caches
php artisan optimize:clear || true
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

# storage:link (ignorar erro se já existir)
php artisan storage:link || true

# Migrações automáticas (opcional via env AUTO_MIGRATE=1)
if [ "${AUTO_MIGRATE:-0}" = "1" ]; then
  php artisan migrate --force || true
fi

# Porta padrão 80
PORT_TO_USE=${PORT:-80}

# Iniciar servidor embutido do PHP apontando para public/
exec php -S 0.0.0.0:${PORT_TO_USE} -t public public/index.php
