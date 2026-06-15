#!/bin/sh
echo "=== Inicializando Redis ==="

redis-cli -a "${REDIS_ROOT_PASSWORD}" ACL SETUSER \
  "${REDIS_USER_APP}" \
  on \
  ">${REDIS_PASSWORD_APP}" \
  ~* \
  +@all \
  -@dangerous

echo "=== Inicialización de Redis completada ==="