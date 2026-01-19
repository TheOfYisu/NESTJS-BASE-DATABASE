-- ==================================================
-- Schema: CORE
-- ==================================================

-- ============================
-- Conectar a la base de datos
-- ============================
\c ${POSTGRES_DB};

-- ============================
-- Crear schema
-- ============================
CREATE SCHEMA IF NOT EXISTS ${POSTGRES_SCHEMA_CORE};

-- ============================
-- Rol owner del schema (NOLOGIN)
-- ============================
DO
$$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = '${POSTGRES_SCHEMA_CORE}'
  ) THEN
    CREATE ROLE ${POSTGRES_SCHEMA_CORE} NOLOGIN;
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
    SELECT 1 FROM pg_roles WHERE rolname = '${POSTGRES_USER_CORE}'
  ) THEN
    CREATE ROLE ${POSTGRES_USER_CORE}
      LOGIN
      PASSWORD '${POSTGRES_PASSWORD_CORE}'
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
TO ${POSTGRES_USER_CORE};

-- ============================
-- Seguridad sobre public
-- ============================
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM ${POSTGRES_USER_CORE};

-- ============================
-- Ownership del schema
-- ============================
ALTER SCHEMA ${POSTGRES_SCHEMA_CORE}
OWNER TO ${POSTGRES_SCHEMA_CORE};

-- ============================
-- Permisos sobre el schema
-- ============================
GRANT USAGE, CREATE
ON SCHEMA ${POSTGRES_SCHEMA_CORE}
TO ${POSTGRES_USER_CORE};

-- ============================
-- Permisos sobre objetos existentes
-- ============================
GRANT ALL PRIVILEGES
ON ALL TABLES IN SCHEMA ${POSTGRES_SCHEMA_CORE}
TO ${POSTGRES_USER_CORE};

GRANT ALL PRIVILEGES
ON ALL SEQUENCES IN SCHEMA ${POSTGRES_SCHEMA_CORE}
TO ${POSTGRES_USER_CORE};

GRANT ALL PRIVILEGES
ON ALL FUNCTIONS IN SCHEMA ${POSTGRES_SCHEMA_CORE}
TO ${POSTGRES_USER_CORE};

-- ============================
-- Permisos sobre objetos futuros
-- (IMPORTANTE: ejecuta como owner)
-- ============================
ALTER DEFAULT PRIVILEGES FOR ROLE ${POSTGRES_SCHEMA_CORE}
IN SCHEMA ${POSTGRES_SCHEMA_CORE}
GRANT ALL PRIVILEGES ON TABLES
TO ${POSTGRES_USER_CORE};

ALTER DEFAULT PRIVILEGES FOR ROLE ${POSTGRES_SCHEMA_CORE}
IN SCHEMA ${POSTGRES_SCHEMA_CORE}
GRANT ALL PRIVILEGES ON SEQUENCES
TO ${POSTGRES_USER_CORE};

ALTER DEFAULT PRIVILEGES FOR ROLE ${POSTGRES_SCHEMA_CORE}
IN SCHEMA ${POSTGRES_SCHEMA_CORE}
GRANT ALL PRIVILEGES ON FUNCTIONS
TO ${POSTGRES_USER_CORE};

-- ============================
-- Search path (CLAVE para ORM)
-- ============================
ALTER ROLE ${POSTGRES_USER_CORE}
SET search_path TO ${POSTGRES_SCHEMA_CORE}, public;
