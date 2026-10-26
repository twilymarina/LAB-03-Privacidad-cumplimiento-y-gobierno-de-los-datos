# Evidencia 12 — Privacidad por diseño

## Objetivo

Analizar el diseño propuesto por un desarrollador para una nueva tabla de clientes y evaluarlo desde los principios de privacidad por diseño y por defecto.

## Procedimiento

1. Se revisó la tabla propuesta (nombre, correo, teléfono, rfc, edad, dirección, ciudad, código postal, fecha de nacimiento, ocupación, salario, estado civil, entre otros).
2. Se evaluó la justificación: "Es mejor guardar todos los datos por si posteriormente necesitamos alguno".
3. Se identificaron problemas, principios ignorados, preguntas previas, datos a eliminar o justificar y medidas de privacidad por defecto.

## Resultado

**1. Problemas identificados**

- Recopilación excesiva sin finalidad definida.
- Datos sensibles o de alto riesgo (salario, estado civil, ocupación) sin justificación.
- Redundancia: `edad` y `fecha_nacimiento` almacenan información equivalente; la edad queda desactualizada.
- Tipos `TEXT` sin validación ni restricciones.
- Falta de llave primaria, `NOT NULL` y restricciones.
- Mayor impacto ante una filtración.
- Dificultad para atender solicitudes ARCO y definir retención.
- Posible incumplimiento del aviso de privacidad.

**2. Principio ignorado**
Minimización (necesidad y proporcionalidad), así como limitación de finalidad y privacidad por diseño.

**3. Preguntas antes de aprobar el diseño**

- ¿Para qué finalidad se necesita cada campo?
- ¿Qué proceso depende de él?
- ¿Es indispensable o solo "útil"?
- ¿Existe una base jurídica o se requiere consentimiento?
- ¿Quién será el propietario del dato?
- ¿Quién accederá y con qué rol?
- ¿Por cuánto tiempo se conservará?
- ¿Está incluido en el aviso de privacidad?
- ¿Puede obtenerse de forma menos invasiva (rango en lugar de valor exacto)?

**4. Datos que eliminaría**

| Dato | Motivo |
|---|---|
| salario | No hay finalidad; riesgo alto |
| estado_civil | No hay finalidad; riesgo alto |
| ocupacion | No hay finalidad |
| fecha_nacimiento | Redundante con edad; más identificable |
| direccion completa | Solo si hay envíos; no para el registro general |
| campos genéricos "..." | Cualquier campo sin finalidad definida |

**5. Datos que requerirían justificación adicional**

| Dato | Justificación requerida |
|---|---|
| rfc | Solo si el cliente solicita factura |
| direccion | Solo si hay entrega física |
| fecha_nacimiento | Solo si la ley o el servicio exige verificar edad |
| codigo_postal | Si se usa para domicilio fiscal o segmentación regional |

**6. Propuesta de diseño con privacidad por defecto**

```sql
CREATE TABLE clientes (
    id            BIGSERIAL PRIMARY KEY,
    nombre        VARCHAR(120) NOT NULL,
    correo        VARCHAR(150) NOT NULL UNIQUE,
    telefono      VARCHAR(20),
    ciudad        VARCHAR(80),
    fecha_alta    DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE clientes_facturacion (
    cliente_id    BIGINT PRIMARY KEY REFERENCES clientes(id),
    rfc           VARCHAR(13) NOT NULL,
    codigo_postal VARCHAR(10) NOT NULL
);

CREATE TABLE marketing_preferencias (
    cliente_id    BIGINT PRIMARY KEY REFERENCES clientes(id),
    acepta_promos BOOLEAN NOT NULL DEFAULT FALSE
);

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
```

Privacidad por defecto:

- Solo se recopilan datos necesarios; los opcionales son separados y voluntarios.
- Datos fiscales en tabla aparte con acceso restringido.
- Marketing desactivado por defecto (`acepta_promos = FALSE`).
- Sin permisos para `PUBLIC`; acceso otorgado por rol y finalidad.
- Retención definida desde el diseño.

## Análisis

El diseño propuesto prioriza una comodidad hipotética del desarrollo sobre los derechos del titular. Cada dato adicional implica una obligación de protección, justificación, retención y atención de derechos. Separar datos por finalidad reduce el riesgo y facilita el control de acceso.

## Conclusión

Un buen diseño de base de datos es una medida de privacidad. Guardar "todo por si acaso" contradice la minimización. La privacidad por diseño exige decidir qué datos se recopilan antes de crear la tabla, y la privacidad por defecto exige que la configuración inicial exponga el mínimo posible.
