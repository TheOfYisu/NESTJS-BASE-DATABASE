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

# Generar archivos SQL desde templates
echo "Paso 1: Generando archivos SQL desde templates..."
./generate-sql.sh
echo ""

# Detener contenedores existentes si los hay
echo "Paso 2: Deteniendo contenedores existentes..."
docker-compose down
echo ""

# Construir y levantar los contenedores
echo "Paso 3: Construyendo y levantando contenedores..."
docker-compose up -d --build
echo ""

# Limpiar archivos generados
echo "Paso 4: Limpiando archivos SQL generados..."
rm -rf postgres/generated
echo "Archivos SQL generados eliminados"
echo ""

# Eliminar .env
echo "Paso 5: Eliminando archivo .env..."
#rm -f .env # Comentado para evitar eliminar el .env durante pruebas
echo "Archivo .env eliminado"
echo ""

# Esperar a que los servicios estén listos
echo "Esperando a que los servicios estén listos..."
sleep 5
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
