#!/bin/bash
set -e

# Crear directorio de logs
LOG_DIR="logs/run"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/run-$(date +%Y%m%d-%H%M%S).log"

# Redirigir toda la salida al log y a la consola
exec > >(tee -a "$LOG_FILE") 2>&1

echo "==================================================="
echo "=== Iniciando entorno de bases de datos ==="
echo "=== Fecha: $(date) ==="
echo "==================================================="
echo ""

# Verificar si existe el archivo .env
if [ ! -f .env ]; then
  echo "Error: No se encontró el archivo .env"
  exit 1
fi

echo "Archivo .env encontrado"
echo ""

# Cargar variables del .env en el entorno del script
set -a
source .env
set +a

echo "Variables de entorno cargadas en el script"
echo ""

# Archivos de postgresql
echo "Archivos de PostgreSQL:"

# Generar archivos SQL desde templates
echo "Paso 1: Generando archivos SQL desde templates..."
./generate-sql.sh
echo ""


# Archivos de MongoDB
echo "Archivos de MongoDB:"
# Generar scripts de MongoDB desde templates
echo "Paso 2: Generando scripts de MongoDB desde templates..."
./generate-mongo.sh
echo ""

# Archivos de Redis
echo "Archivos de Redis:"
# Generar scripts de Redis desde templates
echo "Paso 3: Generando scripts de Redis desde templates..."
./generate-redis.sh
echo ""


# Detener contenedores existentes si los hay
echo "Paso 4: Deteniendo contenedores existentes..."
docker-compose down
echo ""

# Construir y levantar los contenedores
echo "Paso 5: Construyendo y levantando contenedores..."
docker-compose up -d --build
echo ""

# Esperar a que los servicios estén listos e inicialicen
echo "Paso 6: Esperando a que los servicios estén listos e inicialicen..."
sleep 15
echo ""

# Limpiar archivos generados
echo "Paso 7: Limpiando archivos generados..."
rm -rf postgres/generated
rm -rf mongo/generated
rm -rf redis/generated
echo "Archivos generados eliminados"
echo ""

# Eliminar .env
echo "Paso 8: Eliminando archivo .env..."
#rm -f .env # Comentado para evitar eliminar el .env durante pruebas
echo "Archivo .env eliminado"
echo ""

# Mostrar estado de los contenedores
echo "Estado de los contenedores:"
docker-compose ps
echo ""

echo "==================================================="
echo "Entorno levantado correctamente"
echo "==================================================="
echo ""
echo "Comandos útiles:"
echo "  - Ver logs: docker-compose logs -f"
echo "  - Detener: docker-compose down"
echo "  - Reiniciar: docker-compose restart"
echo ""
echo "Log guardado en: $LOG_FILE"
echo "=== Fin: $(date) ==="
