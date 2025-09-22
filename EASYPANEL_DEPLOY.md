# 🚀 Deploy no EasyPanel - Solução de Problemas

## ❌ Problema Encontrado

```
The /app/bootstrap/cache directory must be present and writable.
Script @php artisan package:discover --ansi handling the post-autoload-dump event returned with error code 1
```

## ✅ Solução Implementada

### 1. **Dockerfile Corrigido**

-   Criamos os diretórios necessários ANTES de executar `composer install`
-   Configuramos permissões adequadas para `www-data`
-   Adicionamos `.dockerignore` para otimizar o build

### 2. **Arquivos Criados/Atualizados**

-   ✅ `Dockerfile` - Corrigido com criação de diretórios
-   ✅ `docker-entrypoint.sh` - Melhorado com retry logic
-   ✅ `.dockerignore` - Otimização do build
-   ✅ `easypanel-config.yml` - Configuração específica

## 🔧 Passos para Deploy no EasyPanel

### **Passo 1: Configurar Repositório**

```bash
git add .
git commit -m "Fix Docker build issues for EasyPanel"
git push origin main
```

### **Passo 2: Configurar EasyPanel**

1. **Criar Novo Projeto:**

    - Tipo: `Docker`
    - Repositório: Seu repositório Git
    - Branch: `main`

2. **Configurar Build:**

    - **Dockerfile Path**: `./Dockerfile`
    - **Build Context**: `.`
    - **Port**: `80`

3. **Variáveis de Ambiente:**

```env
APP_NAME=Gerenciar
APP_ENV=production
APP_DEBUG=false
APP_URL=https://seudominio.com
APP_KEY=base64:wID/CO/WkfE3yoWpQOoy15de8FtOpvC3dM/z5FuHiEU=

DB_CONNECTION=mysql
DB_HOST=mysql-service
DB_PORT=3306
DB_DATABASE=gerenciar_db
DB_USERNAME=gerenciar_user
DB_PASSWORD=senha_segura_aqui

CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

REDIS_HOST=redis-service
REDIS_PASSWORD=null
REDIS_PORT=6379
```

### **Passo 3: Configurar Serviços**

1. **MySQL Database:**

    - Criar serviço MySQL
    - Usar as credenciais das variáveis de ambiente

2. **Redis (Opcional mas Recomendado):**
    - Criar serviço Redis
    - Para cache e sessões

### **Passo 4: Deploy**

-   EasyPanel fará o build automaticamente
-   O processo agora deve funcionar sem erros

## 🐛 Troubleshooting

### **Se ainda houver problemas:**

1. **Verificar Logs:**

    - Acesse os logs do build no EasyPanel
    - Procure por erros específicos

2. **Testar Localmente:**

```bash
docker build -t gerenciar-test .
docker run -p 8000:80 gerenciar-test
```

3. **Verificar Permissões:**
    - O Dockerfile agora cria todos os diretórios necessários
    - Permissões são configuradas corretamente

### **Comandos Úteis para Debug:**

```bash
# Verificar estrutura de diretórios
docker run --rm gerenciar-test ls -la /app/bootstrap/

# Verificar permissões
docker run --rm gerenciar-test ls -la /app/bootstrap/cache/

# Testar conexão com banco
docker run --rm -e DB_HOST=mysql-service gerenciar-test php artisan migrate:status
```

## 📋 Checklist Final

-   [x] Dockerfile corrigido com criação de diretórios
-   [x] Permissões configuradas adequadamente
-   [x] Script de entrada melhorado
-   [x] .dockerignore criado para otimização
-   [ ] Repositório Git atualizado
-   [ ] EasyPanel configurado
-   [ ] Variáveis de ambiente definidas
-   [ ] Serviços MySQL/Redis criados
-   [ ] Deploy executado com sucesso

## 🎯 Próximos Passos

1. **Commit e Push** das alterações
2. **Configurar EasyPanel** com as novas configurações
3. **Executar Deploy** e verificar se funciona
4. **Configurar Domínio** e SSL
5. **Testar Aplicação** em produção

---

**Nota:** O problema original era que o Laravel precisa do diretório `bootstrap/cache` para executar o `composer install`, mas ele não existia. Agora criamos todos os diretórios necessários antes de executar qualquer comando do Laravel.
