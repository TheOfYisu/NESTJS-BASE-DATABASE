-- ==================================================
-- Schema: AUDIT
-- ==================================================

-- ============================
-- Conectar a la base de datos
-- ============================
\c ${POSTGRES_DB};

-- ============================
-- Crear schema
-- ============================
CREATE SCHEMA IF NOT EXISTS ${POSTGRES_SCHEMA_AUDIT};

-- ============================
-- Rol owner del schema (NOLOGIN)
-- ============================
DO
$$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = '${POSTGRES_SCHEMA_AUDIT}'
  ) THEN
    CREATE ROLE ${POSTGRES_SCHEMA_AUDIT} NOLOGIN;
  END IF;
END
$$;

-- ============================
-- Usuario de la aplicación
-- ============================
DO
$$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = '${POSTGRES_USER_AUDIT}'
  ) THEN
    CREATE ROLE ${POSTGRES_USER_AUDIT}
      LOGIN
      PASSWORD '${POSTGRES_PASSWORD_AUDIT}'
      NOSUPERUSER
      NOCREATEDB
      NOCREATEROLE
      NOINHERIT;
  END IF;
END
$$;

-- ============================
-- Permitir conexión a la DB
-- ============================
GRANT CONNECT ON DATABASE ${POSTGRES_DB}
TO ${POSTGRES_USER_AUDIT};

-- ============================
-- Seguridad sobre public
-- ============================
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM ${POSTGRES_USER_AUDIT};

-- ============================
-- Ownership del schema
-- ============================
ALTER SCHEMA ${POSTGRES_SCHEMA_AUDIT}
OWNER TO ${POSTGRES_SCHEMA_AUDIT};

-- ============================
-- Permisos sobre el schema
-- ============================
GRANT USAGE, CREATE
ON SCHEMA ${POSTGRES_SCHEMA_AUDIT}
TO ${POSTGRES_USER_AUDIT};

-- ============================
-- Permisos sobre objetos existentes
-- ============================
GRANT ALL PRIVILEGES
ON ALL TABLES IN SCHEMA ${POSTGRES_SCHEMA_AUDIT}
TO ${POSTGRES_USER_AUDIT};

GRANT ALL PRIVILEGES
ON ALL SEQUENCES IN SCHEMA ${POSTGRES_SCHEMA_AUDIT}
TO ${POSTGRES_USER_AUDIT};

GRANT ALL PRIVILEGES
ON ALL FUNCTIONS IN SCHEMA ${POSTGRES_SCHEMA_AUDIT}
TO ${POSTGRES_USER_AUDIT};

-- ============================
-- Permisos sobre objetos futuros
-- (IMPORTANTE: ejecuta como owner)
-- ============================
ALTER DEFAULT PRIVILEGES FOR ROLE ${POSTGRES_SCHEMA_AUDIT}
IN SCHEMA ${POSTGRES_SCHEMA_AUDIT}
GRANT ALL PRIVILEGES ON TABLES
TO ${POSTGRES_USER_AUDIT};

ALTER DEFAULT PRIVILEGES FOR ROLE ${POSTGRES_SCHEMA_AUDIT}
IN SCHEMA ${POSTGRES_SCHEMA_AUDIT}
GRANT ALL PRIVILEGES ON SEQUENCES
TO ${POSTGRES_USER_AUDIT};

ALTER DEFAULT PRIVILEGES FOR ROLE ${POSTGRES_SCHEMA_AUDIT}
IN SCHEMA ${POSTGRES_SCHEMA_AUDIT}
GRANT ALL PRIVILEGES ON FUNCTIONS
TO ${POSTGRES_USER_AUDIT};

-- ============================
-- Search path (CLAVE para ORM)
-- ============================
ALTER ROLE ${POSTGRES_USER_AUDIT}
SET search_path TO ${POSTGRES_SCHEMA_AUDIT}, public;
