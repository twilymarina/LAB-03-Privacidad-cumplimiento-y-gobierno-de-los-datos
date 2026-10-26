# Evidencia 15 — Propuesta de arquitectura de datos protegidos

## Objetivo

Diseñar una propuesta conceptual que separe la información según su finalidad y traduzca los principios de privacidad en decisiones técnicas concretas.

## Procedimiento

1. Se definieron capas separadas: operación, analítica y auditoría.
2. Se asignaron roles y accesos a cada capa.
3. Se incorporaron controles de acceso, minimización, protección de datos sensibles, retención, trazabilidad, eliminación y atención de solicitudes.
4. Se incluyeron ejemplos de implementación en PostgreSQL (no es necesario implementar toda la arquitectura).

## Resultado

### Diagrama conceptual

```
                        BASE DE DATOS
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
   ESQUEMA operacion     ESQUEMA analitica     ESQUEMA auditoria
        │                     │                     │
        ▼                     ▼                     ▼
  Datos necesarios       Datos agregados /      Bitácora de accesos
  para operación         seudonimizados         y cambios
  (clientes,             (vistas de rangos,     (solo DBA/privacidad)
   facturacion,           sin identificadores)
   soporte)
```

### Roles y acceso

| Rol | Esquema / objeto | Permiso |
|---|---|---|
| atencion | `operacion.v_soporte` | SELECT (id, nombre, correo, teléfono) |
| facturacion | `operacion.clientes_facturacion` | SELECT (nombre, RFC, CP) |
| analista | `analitica.v_estadisticas` | SELECT (ciudad, rango_edad) |
| marketing | `operacion.v_marketing` | SELECT (solo clientes con consentimiento) |
| dba | Todos (técnico) | Administración; sin uso de datos para fines propios |
| privacidad | `auditoria.*` y consultas ARCO | SELECT en bitácora |

### Implementación de ejemplo

```sql
CREATE SCHEMA operacion;
CREATE SCHEMA analitica;
CREATE SCHEMA auditoria;

REVOKE ALL ON SCHEMA public FROM PUBLIC;

CREATE ROLE atencion NOLOGIN;
CREATE ROLE facturacion NOLOGIN;
CREATE ROLE analista NOLOGIN;
CREATE ROLE marketing NOLOGIN;

-- Minimización: vista para soporte
CREATE VIEW operacion.v_soporte AS
SELECT id, nombre, correo, telefono
FROM operacion.clientes;

-- Analítica: sin identificadores
CREATE VIEW analitica.v_estadisticas AS
SELECT ciudad,
       CASE
           WHEN edad < 18 THEN 'Menor de 18'
           WHEN edad BETWEEN 18 AND 29 THEN '18-29'
           WHEN edad BETWEEN 30 AND 44 THEN '30-44'
           WHEN edad BETWEEN 45 AND 59 THEN '45-59'
           ELSE '60 o más'
       END AS rango_edad
FROM operacion.clientes;

GRANT USAGE ON SCHEMA operacion TO atencion, facturacion, marketing;
GRANT USAGE ON SCHEMA analitica TO analista;
GRANT SELECT ON operacion.v_soporte TO atencion;
GRANT SELECT ON analitica.v_estadisticas TO analista;

-- Trazabilidad
CREATE TABLE auditoria.bitacora_cambios (
    id          BIGSERIAL PRIMARY KEY,
    tabla       TEXT NOT NULL,
    operacion   TEXT NOT NULL,
    registro_id BIGINT,
    usuario     TEXT NOT NULL DEFAULT current_user,
    fecha       TIMESTAMP NOT NULL DEFAULT now()
);

-- Retención: identificación de registros vencidos
SELECT id FROM operacion.clientes
WHERE fecha_alta < now() - INTERVAL '12 years';
```

### Controles por tema

| Tema | Control técnico | Control administrativo |
|---|---|---|
| **Acceso** | Roles por función, vistas, `REVOKE` a PUBLIC, mínimo privilegio | Política de control de acceso y revisión trimestral de permisos |
| **Minimización** | Tablas mínimas por finalidad; rangos en lugar de valores exactos | Aprobación de nuevos campos con justificación |
| **Datos sensibles** | Cifrado de columna para RFC (pgcrypto), TLS en tránsito, enmascaramiento | Clasificación de información |
| **Retención** | Consultas y tareas programadas (pg_cron) para identificar y depurar vencidos | Política de retención aprobada por jurídico y privacidad |
| **Trazabilidad** | pgAudit, triggers de bitácora, logs de conexión | Revisión periódica de bitácoras |
| **Eliminación** | Procedimiento de supresión o anonimización; depuración de respaldos expirados | Procedimiento de cancelación coordinado con privacidad |
| **Atención de solicitudes** | Consultas preparadas para localizar datos por titular; marcas de oposición | Procedimiento ARCO con responsables y tiempos |
| **Desarrollo y pruebas** | Datos sintéticos o anonimizados; sin copias reales | Política de ambientes no productivos |

### Flujo de atención de solicitudes ARCO

```
Solicitud → Privacidad valida identidad y procedencia
        → Jurídico evalúa obligación legal
        → DBA localiza y ejecuta (consulta / UPDATE / bloqueo / supresión)
        → Se registra en bitácora
        → Privacidad responde al titular
```

## Análisis

Separar la información por finalidad evita que un único acceso exponga todos los datos. Las vistas y los esquemas permiten aplicar mínimo privilegio sin duplicar innecesariamente la información. La auditoría separada garantiza trazabilidad. La arquitectura reconoce que los controles técnicos requieren políticas y responsables para ser efectivos.

## Conclusión

La arquitectura traduce los principios de privacidad en decisiones técnicas: esquemas separados, vistas mínimas, roles por función, protección reforzada de datos sensibles, retención automatizada y trazabilidad. El DBA implementa y mantiene los controles, mientras que privacidad, jurídico y los propietarios de los datos definen las finalidades, los plazos y los procedimientos.
