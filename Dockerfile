# Use PHP 8.2 com Apache
FROM php:8.2-apache

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    nodejs \
    npm \
    supervisor \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar Apache
RUN a2enmod rewrite
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /app/public\n\
    <Directory /app/public>\n\
    AllowOverride All\n\
    Require all granted\n\
    </Directory>\n\
    </VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Definir diretório de trabalho
WORKDIR /app

# Criar diretórios necessários antes de copiar arquivos
RUN mkdir -p /app/bootstrap/cache \
    && mkdir -p /app/storage/logs \
    && mkdir -p /app/storage/framework/cache \
    && mkdir -p /app/storage/framework/sessions \
    && mkdir -p /app/storage/framework/views \
    && mkdir -p /app/storage/app/public \
    && mkdir -p /app/public

# Copiar arquivos do projeto
COPY . /app

# Configurar permissões básicas antes do composer
RUN chown -R www-data:www-data /app \
    && chmod -R 775 /app/bootstrap/cache \
    && chmod -R 775 /app/storage

# Instalar dependências PHP
RUN composer install --no-dev --optimize-autoloader

# Instalar dependências Node.js e build
RUN npm install && npm run build

# Configurar permissões finais
RUN chown -R www-data:www-data /app \
    && chmod -R 755 /app/storage \
    && chmod -R 755 /app/bootstrap/cache \
    && chmod -R 755 /app/public

# Configurar supervisor para Laravel Queue
RUN echo '[program:laravel-worker]\n\
    process_name=%(program_name)s_%(process_num)02d\n\
    command=php /app/artisan queue:work --sleep=3 --tries=3 --max-time=3600\n\
    autostart=true\n\
    autorestart=true\n\
    stopasgroup=true\n\
    killasgroup=true\n\
    user=www-data\n\
    numprocs=1\n\
    redirect_stderr=true\n\
    stdout_logfile=/app/storage/logs/worker.log\n\
    stopwaitsecs=3600' > /etc/supervisor/conf.d/laravel-worker.conf

# Expor porta
EXPOSE 80

# Script de inicialização
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]