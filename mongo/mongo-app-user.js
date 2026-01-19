// ================================
// Variables de entorno
// ================================
const LOGS_DB = process.env.MONGO_BD_LOGS;
const LOGS_USER = process.env.MONGO_USER_LOGS;
const LOGS_PASSWORD = process.env.MONGO_PASSWORD_LOGS;

// ================================
// Seleccionar DB de logs
// ================================
const dbLogs = db.getSiblingDB(LOGS_DB);

// ================================
// Crear usuario si no existe
// ================================
const existingUsers = dbLogs.getUsers().users.map((u) => u.user);

if (!existingUsers.includes(LOGS_USER)) {
  dbLogs.createUser({
    user: LOGS_USER,
    pwd: LOGS_PASSWORD,
    roles: [
      {
        role: "readWrite",
        db: LOGS_DB,
      },
    ],
  });

  print(`Usuario ${LOGS_USER} creado en DB ${LOGS_DB}`);
} else {
  print(`Usuario ${LOGS_USER} ya existe en DB ${LOGS_DB}`);
}
