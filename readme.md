# NestJS Base - Entorno de Bases de Datos

Configuración automatizada de bases de datos PostgreSQL y MongoDB para aplicaciones NestJS usando Docker.

## 📋 Descripción

Este proyecto proporciona un entorno pre-configurado de bases de datos para aplicaciones NestJS, incluyendo:

- **PostgreSQL 16** con múltiples schemas y usuarios específicos
- **MongoDB 7** con base de datos de logs y usuario de aplicación
- Scripts de inicialización automatizados
- Sistema de templates para configuración dinámica
- Logging completo de operaciones

## 🏗️ Arquitectura

### PostgreSQL

El proyecto crea automáticamente tres schemas separados:

1. **CORE** - Funcionalidad principal de la aplicación
2. **AUTH** - Gestión de autenticación y autorización

Cada schema tiene:

- Un rol propietario (NOLOGIN) para gestión de permisos
- Un usuario de aplicación con permisos específicos
- Configuración de seguridad que revoca accesos al schema `public`
- Permisos configurados para objetos existentes y futuros

### MongoDB

Crea una base de datos de logs con:

- Usuario específico para la aplicación
- Permisos de lectura/escritura
- Inicialización automática mediante scripts

## 📦 Requisitos

- Docker
- Docker Compose
- Bash (para scripts de inicialización)
- Sistema operativo compatible con bash scripts (Linux, macOS, WSL en Windows)

## 🚀 Instalación y Configuración

### 1. Crear archivo de variables de entorno

Crea un archivo `.env` en la raíz del proyecto con las siguientes variables:

```env
# PostgreSQL - Configuración Admin
POSTGRES_ADMIN_USER=postgres
POSTGRES_ADMIN_PASSWORD=tu_password_admin
POSTGRES_DB=tu_base_datos
POSTGRES_PORT=5432

# PostgreSQL - Schema CORE
POSTGRES_SCHEMA_CORE=core
POSTGRES_USER_CORE=app_core
POSTGRES_PASSWORD_CORE=password_core

# PostgreSQL - Schema AUDIT
POSTGRES_SCHEMA_AUDIT=audit
POSTGRES_USER_AUDIT=app_audit
POSTGRES_PASSWORD_AUDIT=password_audit

# PostgreSQL - Schema AUTH
POSTGRES_SCHEMA_AUTH=auth
POSTGRES_USER_AUTH=app_auth
POSTGRES_PASSWORD_AUTH=password_auth

# MongoDB - Configuración Root
MONGO_ROOT_USER=root
MONGO_ROOT_PASSWORD=tu_password_root
MONGO_PORT=27017

# MongoDB - Base de datos de Logs
MONGO_DB=admin
MONGO_BD_LOGS=logs
MONGO_USER_LOGS=app_logs
MONGO_PASSWORD_LOGS=password_logs
```

### 2. Levantar el entorno

```bash
# Dar permisos de ejecución a los scripts
chmod +x generate-sql.sh run.sh

# Ejecutar el script principal
./run.sh
```

El script `run.sh` realiza automáticamente:

1. Genera archivos SQL desde los templates
2. Detiene contenedores existentes
3. Construye y levanta los contenedores
4. Limpia archivos temporales
5. Muestra el estado de los servicios

## 📁 Estructura del Proyecto

```
.
├── docker-compose.yml              # Configuración de servicios Docker
├── Dockerfile.postgres             # Dockerfile personalizado para PostgreSQL
├── generate-sql.sh                 # Script para generar SQL desde templates
├── run.sh                          # Script principal de inicialización
├── readme.md                       # Este archivo
│
├── logs/                           # Directorio de logs
│   ├── generate-sql/               # Logs de generación SQL
│   └── run/                        # Logs de ejecución principal
│
├── mongo/                          # Scripts de inicialización MongoDB
│   └── mongo-app-user.js           # Creación de usuario de logs
│
└── postgres/                       # Configuración PostgreSQL
    └── template/                   # Templates SQL
        ├── 01-schema-and-app-user-core.sql.tpl
        ├── 02-schema-and-app-user-audit.sql.tpl
        └── 03-schema-and-app-user-auth.sql.tpl
```

## 🔧 Comandos Útiles

### Docker Compose

```bash
# Ver logs en tiempo real
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f postgres
docker-compose logs -f mongo

# Detener los contenedores
docker-compose down

# Detener y eliminar volúmenes (⚠️ Esto borrará los datos)
docker-compose down -v

# Reiniciar servicios
docker-compose restart

# Ver estado de contenedores
docker-compose ps
```

### Conexión a las Bases de Datos

#### PostgreSQL

```bash
# Conectar como admin
docker exec -it nestjs_base_postgres psql -U postgres -d tu_base_datos

# Conectar como usuario de aplicación (ejemplo: core)
docker exec -it nestjs_base_postgres psql -U app_core -d tu_base_datos

# Conectar a un schema específico
docker exec -it nestjs_base_postgres psql -U app_core -d tu_base_datos -c "SET search_path TO core;"
```

#### MongoDB

```bash
# Conectar como root
docker exec -it nestjs_base_mongo mongosh -u root -p tu_password_root --authenticationDatabase admin

# Conectar como usuario de logs
docker exec -it nestjs_base_mongo mongosh -u app_logs -p password_logs --authenticationDatabase logs
```

## 🔐 Seguridad

### PostgreSQL

- Cada schema tiene su propio usuario con permisos limitados
- Se revoca el acceso al schema `public` por defecto
- Los usuarios no tienen permisos para crear bases de datos o roles
- Las credenciales de administrador se limpian después de la inicialización
- Permisos configurados siguiendo el principio de mínimo privilegio

### MongoDB

- Usuario root con credenciales personalizadas
- Usuarios de aplicación con permisos específicos por base de datos
- Autenticación habilitada por defecto

## 📊 Logging

Los scripts generan logs automáticamente en el directorio `logs/`:

- **generate-sql/**: Logs de la generación de archivos SQL
- **run/**: Logs completos de la inicialización del entorno

Formato de nombres: `[operación]-YYYYMMDD-HHMMSS.log`

## 🛠️ Personalización

### Agregar nuevos schemas PostgreSQL

1. Crea un nuevo template en `postgres/template/`:

   ```sql
   -- 04-schema-and-app-user-[nombre].sql.tpl
   ```

2. Agrega las variables necesarias al archivo `.env`:

   ```env
   POSTGRES_SCHEMA_[NOMBRE]=[nombre]
   POSTGRES_USER_[NOMBRE]=app_[nombre]
   POSTGRES_PASSWORD_[NOMBRE]=password_[nombre]
   ```

3. El script `generate-sql.sh` procesará automáticamente el nuevo template

### Agregar nuevas bases de datos MongoDB

1. Modifica o crea un nuevo script en `mongo/`:

   ```javascript
   // [nombre]-init.js
   ```

2. Agrega las variables al archivo `.env`

3. Los scripts se ejecutarán automáticamente al inicializar el contenedor

## 🐛 Solución de Problemas

### Los contenedores no inician

```bash
# Ver logs detallados
docker-compose logs

# Verificar que no haya conflictos de puertos
docker ps -a
```

### Error al generar archivos SQL

```bash
# Verificar que exista el archivo .env
ls -la .env

# Verificar los logs de generación
cat logs/generate-sql/generate-sql-*.log
```

### No se pueden conectar a las bases de datos

```bash
# Verificar que los contenedores estén corriendo
docker-compose ps

# Verificar los puertos expuestos
docker-compose port postgres 5432
docker-compose port mongo 27017

# Revisar las credenciales en el archivo .env
```

## 📝 Notas Importantes

1. **Volúmenes**: Los datos se persisten en volúmenes Docker nombrados:
   - `nestjs_base_pg_data`: Datos PostgreSQL
   - `nestjs_base_mongo_data`: Datos MongoDB
   - `nestjs_base_mongo_config`: Configuración MongoDB

2. **Red**: Los servicios se comunican a través de la red `nestjs_base`

3. **Templates**: Los archivos `.sql.tpl` utilizan sintaxis de `envsubst` para reemplazo de variables

4. **Seguridad**: En producción, considera:
   - Usar secretos de Docker o variables de entorno más seguras
   - Implementar políticas de contraseñas más estrictas
   - Configurar SSL/TLS para las conexiones
   - Restringir acceso a la red

## 🔄 Actualización del Entorno

Para actualizar la configuración:

1. Modifica las variables en `.env` o los templates
2. Ejecuta nuevamente `./run.sh`
3. El script reconstruirá los contenedores con la nueva configuración

## 📄 Licencia

Este proyecto está licenciado bajo Apache License Version 2.0, January 2004.

Para más detalles, consulta el archivo LICENSE o visita: http://www.apache.org/licenses/LICENSE-2.0
