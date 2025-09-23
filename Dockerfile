# Use PHP 8.2 com PHP-FPM (para funcionar atrás do Nginx do provedor)
FROM php:8.2-fpm

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    zip \
    unzip \
    nodejs \
    npm \
    supervisor \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# (Sem Apache) O Nginx externo fará o proxy para o PHP-FPM na porta 9000

# Definir diretório de trabalho
WORKDIR /var/www/html

# Criar diretórios necessários antes de copiar arquivos
RUN mkdir -p /var/www/html/bootstrap/cache \
    && mkdir -p /var/www/html/storage/logs \
    && mkdir -p /var/www/html/storage/framework/cache \
    && mkdir -p /var/www/html/storage/framework/sessions \
    && mkdir -p /var/www/html/storage/framework/views \
    && mkdir -p /var/www/html/storage/app/public

# Copiar arquivos do projeto
COPY . .

# Configurar permissões básicas antes do composer
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage

# Instalar dependências PHP
RUN composer install --no-dev --optimize-autoloader

# Instalar dependências Node.js e build
RUN npm install && npm run build

# Configurar permissões finais
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache \
    && chmod -R 755 /var/www/html/public

# Configurar supervisor para Laravel Queue
RUN echo '[program:laravel-worker]\n\
    process_name=%(program_name)s_%(process_num)02d\n\
    command=php /var/www/html/artisan queue:work --sleep=3 --tries=3 --max-time=3600\n\
    autostart=true\n\
    autorestart=true\n\
    stopasgroup=true\n\
    killasgroup=true\n\
    user=www-data\n\
    numprocs=1\n\
    redirect_stderr=true\n\
    stdout_logfile=/var/www/html/storage/logs/worker.log\n\
    stopwaitsecs=3600' > /etc/supervisor/conf.d/laravel-worker.conf

# Expor porta do PHP-FPM
EXPOSE 9000

# Script de inicialização
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]