#!/bin/bash
set -e

# Aguardar o banco de dados estar disponível
echo "Aguardando banco de dados..."
while ! php artisan migrate:status > /dev/null 2>&1; do
    echo "Banco de dados não disponível, aguardando..."
    sleep 2
done

# Executar migrações
echo "Executando migrações..."
php artisan migrate --force

# Limpar e otimizar cache
echo "Otimizando aplicação..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Iniciar supervisor para workers
echo "Iniciando supervisor..."
supervisord -c /etc/supervisor/supervisord.conf &

# Executar comando principal
exec "$@"
