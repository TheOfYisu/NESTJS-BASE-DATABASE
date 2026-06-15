#!/usr/bin/env bash
set -Eeuo pipefail

LOG_DIR="logs/run"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/run-$(date +%Y%m%d-%H%M%S).log"

exec > >(tee -a "$LOG_FILE") 2>&1

trap 'echo "[ERROR] Falló en línea $LINENO"' ERR

echo "==================================================="
echo "=== Iniciando entorno de bases de datos ==="
echo "=== Fecha: $(date) ==="
echo "==================================================="

if [ ! -f .env ]; then
  echo "Error: No se encontró .env"
  exit 1
fi

echo "Archivo .env encontrado"

# POSIX-safe
set -a
. ./.env
set +a

echo "Variables cargadas"

# Detectar docker compose
if command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
else
  COMPOSE_CMD="docker compose"
fi

echo "Usando: $COMPOSE_CMD"

# Validar scripts
for script in generate-sql.sh generate-mongo.sh generate-redis.sh; do
  if [ ! -f "$script" ]; then
    echo "Error: No existe $script"
    exit 1
  fi
  chmod +x "$script"
done

echo "Paso 1: Generando SQL..."
./generate-sql.sh

echo "Paso 2: Generando Mongo..."
./generate-mongo.sh

echo "Paso 3: Generando Redis..."
./generate-redis.sh

echo "Paso 4: Bajando contenedores..."
$COMPOSE_CMD down --remove-orphans || true

echo "Paso 5: Build + Up..."
$COMPOSE_CMD up -d --build

echo "Paso 6: Esperando inicialización..."
sleep 20

echo "Paso 7: Limpiando archivos generados..."
rm -rf postgres/generated mongo/generated redis/generated

echo "Paso 8: Estado actual..."
$COMPOSE_CMD ps

echo "==================================================="
echo "Entorno levantado correctamente"
echo "==================================================="

echo "Comandos útiles:"
echo "  Logs      -> $COMPOSE_CMD logs -f"
echo "  Stop      -> $COMPOSE_CMD down"
echo "  Restart   -> $COMPOSE_CMD restart"
echo "Log guardado en: $LOG_FILE"