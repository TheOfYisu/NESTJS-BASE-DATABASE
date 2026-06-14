#!/bin/bash
set -e

# Crear directorio de logs y archivo de log con timestamp
LOG_DIR="logs/generate-redis"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/generate-redis-$(date +%Y%m%d-%H%M%S).log"

# Redirigir toda la salida al log y a la consola
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Inicio de generación Redis scripts: $(date) ==="
echo "Log guardado en: $LOG_FILE"
echo "Generando scripts desde templates..."

# Cargar variables del .env
set -a
source .env
set +a

TEMPLATE_DIR="redis/template"
OUTPUT_DIR="redis/generated"

# Verificar que existan templates
if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "Error: El directorio $TEMPLATE_DIR no existe"
  exit 1
fi

# Contar archivos .sh.tpl
template_count=$(ls -1 "$TEMPLATE_DIR"/*.sh.tpl 2>/dev/null | wc -l)
if [ "$template_count" -eq 0 ]; then
  echo "Advertencia: No se encontraron archivos .sh.tpl en $TEMPLATE_DIR"
  echo "No hay templates para procesar"
  exit 0
fi

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

for tpl in "$TEMPLATE_DIR"/*.sh.tpl; do
  filename=$(basename "$tpl" .sh.tpl)
  output="$OUTPUT_DIR/$filename.sh"

  # Si existe el archivo output, eliminarlo
  if [ -f "$output" ]; then
    echo "Eliminando archivo anterior: $output"
    rm -f "$output"
  fi

  echo "Generando $output"
  envsubst < "$tpl" > "$output"
done

echo "Todos los scripts de Redis generados correctamente"
echo "=== Fin de generación Redis scripts: $(date) ==="
