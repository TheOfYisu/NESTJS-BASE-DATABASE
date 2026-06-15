#!/usr/bin/env bash
set -Eeuo pipefail

LOG_DIR="logs/generate-redis"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/generate-redis-$(date +%Y%m%d-%H%M%S).log"

exec > >(tee -a "$LOG_FILE") 2>&1

trap 'echo "[ERROR] Falló en línea $LINENO"' ERR

echo "=== Inicio generación Redis scripts: $(date) ==="

if [ ! -f .env ]; then
  echo "Error: .env no encontrado"
  exit 1
fi

if ! command -v envsubst >/dev/null 2>&1; then
  echo "Error: envsubst no instalado"
  exit 1
fi

set -a
. ./.env
set +a

TEMPLATE_DIR="redis/template"
OUTPUT_DIR="redis/generated"

if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "Error: No existe $TEMPLATE_DIR"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR"/*.sh

shopt -s nullglob
templates=("$TEMPLATE_DIR"/*.sh.tpl)

if [ ${#templates[@]} -eq 0 ]; then
  echo "No se encontraron templates"
  exit 0
fi

for tpl in "${templates[@]}"; do
  filename=$(basename "$tpl" .sh.tpl)
  output="$OUTPUT_DIR/$filename.sh"

  echo "Generando $output"

  envsubst < "$tpl" > "$output"

  # CRLF -> LF (IMPORTANTE para Docker Linux)
  sed -i 's/\r$//' "$output"

  chmod +x "$output"

  # Detectar caracteres basura al final (como tu 'w')
  last_line=$(tail -n 1 "$output" | tr -d '[:space:]')
  if [[ "$last_line" =~ ^[[:alpha:]]$ ]]; then
    echo "Advertencia: posible carácter basura al final: '$last_line'"
  fi
done

echo "Scripts Redis generados correctamente"
echo "=== Fin generación Redis: $(date) ==="