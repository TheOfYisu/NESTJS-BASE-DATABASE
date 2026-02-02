// ================================
// Script de inicialización MongoDB
// Base de datos: ${MONGO_DB}
// ================================

// ================================
// Seleccionar base de datos
// ================================
const dbMain = db.getSiblingDB("${MONGO_DB}");

// ================================
// Crear usuario de aplicación
// ================================
const existingUsers = dbMain.getUsers().users.map((u) => u.user);

if (!existingUsers.includes("${MONGO_USER_APP}")) {
  dbMain.createUser({
    user: "${MONGO_USER_APP}",
    pwd: "${MONGO_PASSWORD_APP}",
    roles: [
      {
        role: "readWrite",
        db: "${MONGO_DB}",
      },
    ],
  });

  print("✓ Usuario ${MONGO_USER_APP} creado en DB ${MONGO_DB}");
} else {
  print("✓ Usuario ${MONGO_USER_APP} ya existe en DB ${MONGO_DB}");
}

// ================================
// Crear colecciones iniciales
// ================================
dbMain.createCollection("logs");
print("✓ Colección 'logs' creada en DB ${MONGO_DB}");

print("=== Inicialización de MongoDB completada ===");
