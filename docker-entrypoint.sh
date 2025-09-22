#!/bin/bash
set -e

# Garantir que estamos em /app
cd /app

# Criar diretórios necessários se não existirem
echo "Criando diretórios necessários..."
mkdir -p /app/bootstrap/cache
mkdir -p /app/storage/logs
mkdir -p /app/storage/framework/cache
mkdir -p /app/storage/framework/sessions
mkdir -p /app/storage/framework/views
mkdir -p /app/storage/app/public
mkdir -p /app/public

# Configurar permissões
echo "Configurando permissões..."
chown -R www-data:www-data /app
chmod -R 775 /app/bootstrap/cache
chmod -R 775 /app/storage

# Aguardar o banco de dados estar disponível
echo "Aguardando banco de dados..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    if php artisan migrate:status > /dev/null 2>&1; then
        echo "Banco de dados conectado!"
        break
    fi
    
    echo "Tentativa $attempt/$max_attempts - Banco de dados não disponível, aguardando..."
    sleep 5
    attempt=$((attempt + 1))
done

if [ $attempt -gt $max_attempts ]; then
    echo "ERRO: Não foi possível conectar ao banco de dados após $max_attempts tentativas"
    exit 1
fi

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

# Executar comando principal (Apache)
exec "$@"