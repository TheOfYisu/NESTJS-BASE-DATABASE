#!/bin/sh
# ================================
# Script de inicialización Redis
# ================================

echo "=== Inicializando Redis ==="

# Crear usuario de aplicación con ACL
redis-cli -a "${REDIS_ROOT_PASSWORD}" ACL SETUSER "${REDIS_USER_APP}" on ">${REDIS_PASSWORD_APP}" +@all -@dangerous ~* > /dev/null 2>&1 && \
  echo "✓ Usuario ${REDIS_USER_APP} creado" || \
  echo "✓ Usuario ${REDIS_USER_APP} ya existe o fue creado"

echo "=== Inicialización de Redis completada ==="
