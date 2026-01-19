#!/bin/bash
set -e

# Crear directorio de logs y archivo de log con timestamp
LOG_DIR="logs/generate-sql"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/generate-sql-$(date +%Y%m%d-%H%M%S).log"

# Redirigir toda la salida al log y a la consola
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Inicio de generación SQL: $(date) ==="
echo "Log guardado en: $LOG_FILE"
echo "Generando SQL desde templates..."

# Cargar variables del .env
set -a
source .env
set +a

TEMPLATE_DIR="postgres/template"
OUTPUT_DIR="postgres/generated"

# Verificar que existan templates
if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "Error: El directorio $TEMPLATE_DIR no existe"
  exit 1
fi

# Contar archivos .sql.tpl
template_count=$(ls -1 "$TEMPLATE_DIR"/*.sql.tpl 2>/dev/null | wc -l)
if [ "$template_count" -eq 0 ]; then
  echo "Advertencia: No se encontraron archivos .sql.tpl en $TEMPLATE_DIR"
  echo "No hay templates para procesar"
  exit 0
fi

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

for tpl in "$TEMPLATE_DIR"/*.sql.tpl; do
  filename=$(basename "$tpl" .sql.tpl)
  output="$OUTPUT_DIR/$filename.sql"

  # Si existe el archivo output, eliminarlo
  if [ -f "$output" ]; then
    echo "Eliminando archivo anterior: $output"
    rm -f "$output"
  fi

  echo "Generando $output"
  envsubst < "$tpl" > "$output"
done

echo "Todos los SQL generados correctamente"
echo "=== Fin de generación SQL: $(date) ==="
