#!/bin/bash
set -e

# Garantir que estamos em /var/www/html
cd /var/www/html

# Criar diretórios necessários se não existirem
echo "Criando diretórios necessários..."
mkdir -p /var/www/html/bootstrap/cache
mkdir -p /var/www/html/storage/logs
mkdir -p /var/www/html/storage/framework/cache
mkdir -p /var/www/html/storage/framework/sessions
mkdir -p /var/www/html/storage/framework/views
mkdir -p /var/www/html/storage/app/public
mkdir -p /var/www/html/public


# Configurar permissões
echo "Configurando permissões..."
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage

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

# Limpar caches e otimizar novamente
echo "Limpando caches..."
php artisan optimize:clear || true
php artisan cache:clear || true
php artisan config:clear || true
php artisan view:clear || true

echo "Otimizando aplicação..."
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

# Garantir storage:link
echo "Criando symlink de storage -> public/storage (se necessário)..."
php artisan storage:link || true

# Iniciar supervisor para workers
echo "Iniciando supervisor..."
supervisord -c /etc/supervisor/supervisord.conf &

# Executar comando principal (Apache)
exec "$@"