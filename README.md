# LAB-03 — Privacidad, cumplimiento y gobierno de los datos

**Unidad:** II. Seguridad, privacidad y control de acceso
**Tema:** 2.5 Privacidad, cumplimiento y gobierno de los datos
**Motor:** PostgreSQL 16
**Modalidad:** Individual

---

## 1. Introducción

La empresa ficticia Comercializadora Norte S.A. de C.V. administra una base de datos de clientes con los campos `id`, `nombre`, `correo`, `telefono`, `rfc`, `edad`, `ciudad`, `codigo_postal` y `fecha_alta`.

Aunque la base pueda estar bien configurada técnicamente, pueden existir problemas de privacidad si:

- se recopilan datos innecesarios,
- los datos se usan para finalidades distintas a las informadas,
- se conservan por más tiempo del necesario,
- cualquier usuario puede consultar información personal,
- no hay responsables ni documentación del tratamiento,
- no se pueden atender solicitudes ARCO.

Este laboratorio traduce los principios de privacidad (finalidad, minimización, proporcionalidad, retención y responsabilidad) en decisiones concretas de diseño y administración en PostgreSQL. Se toma como referencia conceptual la LFPDPPP. Las decisiones jurídicas se escalan al área correspondiente.

---

## 2. Inventario de datos

| Campo | ¿Dato personal? | Clasificación | Finalidad principal | ¿Necesario? | Nivel de acceso |
|---|---|---|---|---|---|
| id | Indirecto (seudónimo) | Interno | Identificar el registro y relacionar tablas | Sí | Operación y DBA |
| nombre | Sí | Personal | Atención y facturación | Sí | Atención, Facturación |
| correo | Sí | Personal | Contacto y atención | Sí | Atención |
| telefono | Sí | Personal | Contacto y atención | Sí | Atención |
| rfc | Sí | Personal (fiscal), reforzado | Facturación | Solo para facturación | Facturación |
| edad | Sí | Personal | Estadística (en rangos) | Solo para analítica | Analítica (agregada) |
| ciudad | Sí (indirecto) | Personal de bajo riesgo | Atención y estadística | Sí | Atención, Analítica (agregada) |
| codigo_postal | Sí (indirecto) | Personal / cuasi-identificador | Facturación y estadística regional | Sí, con restricción | Facturación, Analítica (por región) |
| fecha_alta | Sí (indirecto) | Interno | Gestión de la relación y cálculo de retención | Sí | Operación |

Detalle en `evidencias/01-inventario-datos.md`.

---

## 3. Finalidades

| Finalidad | Datos que requiere | Datos que NO requiere |
|---|---|---|
| Atención al cliente | id, nombre, correo, teléfono | rfc, edad, código postal, fecha_alta |
| Facturación | id, nombre, rfc, código postal (domicilio fiscal) | correo y teléfono (salvo envío de CFDI), edad |
| Analítica | ciudad, rango de edad, región de código postal | nombre, correo, teléfono, rfc |
| Marketing (secundaria) | correo, ciudad, rango de edad, historial de compras | rfc, teléfono, nombre completo (salvo personalización justificada) |

La finalidad se define **antes** de otorgar acceso. Que la organización ya tenga un dato no la autoriza a usarlo para cualquier propósito.

---

## 4. Minimización

### 4.1 Análisis de la solicitud de `clientes_soporte`

| Pregunta | Respuesta |
|---|---|
| ¿Todos los campos son necesarios para soporte? | No. Solo necesita identificar y contactar al cliente. |
| ¿Por qué soporte necesitaría el RFC? | No lo necesita. Es un dato fiscal propio de facturación y su exposición aumenta el riesgo sin aportar a la finalidad. |
| ¿Necesita la edad? | No. Resolver una solicitud de soporte no depende de la edad. |
| ¿Necesita el código postal? | No, salvo que un caso específico (envíos) lo justifique. |
| ¿Qué principio se aplica? | Minimización (con necesidad y proporcionalidad): solo datos adecuados, relevantes y necesarios. |

### 4.2 Implementación

```sql
CREATE TABLE clientes_soporte (
    id       BIGINT PRIMARY KEY,
    nombre   VARCHAR(120) NOT NULL,
    correo   VARCHAR(150) NOT NULL,
    telefono VARCHAR(20)
);

INSERT INTO clientes_soporte (id, nombre, correo, telefono)
SELECT id, nombre, correo, telefono
FROM clientes;

SELECT * FROM clientes_soporte;
```

### 4.3 Agregación para analítica

```sql
SELECT ciudad, COUNT(*) AS cantidad_clientes
FROM clientes
GROUP BY ciudad
ORDER BY cantidad_clientes DESC;

SELECT
    CASE
        WHEN edad < 18 THEN 'Menor de 18'
        WHEN edad BETWEEN 18 AND 29 THEN '18-29'
        WHEN edad BETWEEN 30 AND 44 THEN '30-44'
        WHEN edad BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60 o más'
    END AS rango_edad,
    COUNT(*) AS cantidad
FROM clientes
GROUP BY 1
ORDER BY rango_edad;
```

**¿Por qué es más apropiado para analítica que entregar la tabla completa?** Porque analítica solo necesita estadísticas, no identificar personas. Los datos agregados eliminan identificadores directos, reducen el riesgo en caso de filtración o mal uso, y respetan la limitación de finalidad.

### 4.4 Datos que pueden eliminarse o limitarse

- **Eliminar de soporte:** rfc, edad, ciudad, código postal y fecha_alta.
- **Limitar en analítica:** nombre, correo, teléfono y rfc (no se entregan).
- **Generalizar:** edad en rangos y código postal en región.
- **Revisar:** conservar `edad` implica actualizarla constantemente. Evaluar si conviene almacenar solo un rango o la fecha de nacimiento, solo si existe justificación.

---

## 5. Control de acceso

El acceso se relaciona con la función, no con el cargo ni con la comodidad.

```sql
CREATE ROLE analista NOLOGIN;

CREATE VIEW v_analitica_clientes AS
SELECT
    ciudad,
    CASE
        WHEN edad < 18 THEN 'Menor de 18'
        WHEN edad BETWEEN 18 AND 29 THEN '18-29'
        WHEN edad BETWEEN 30 AND 44 THEN '30-44'
        WHEN edad BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60 o más'
    END AS rango_edad
FROM clientes;

GRANT USAGE ON SCHEMA public TO analista;
GRANT SELECT ON v_analitica_clientes TO analista;
-- NO se otorga: GRANT SELECT ON clientes TO analista;
```

Verificación:

```sql
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'analista';
```

| grantee | table_name | privilege_type |
|---|---|---|
| analista | v_analitica_clientes | SELECT |

| Pregunta | Respuesta |
|---|---|
| ¿Qué información puede consultar el rol? | Solo `ciudad` y `rango_edad` a través de la vista. |
| ¿Puede consultar directamente `clientes`? | No. Obtendría `permission denied for table clientes`. |
| ¿Puede obtener nombre, correo y RFC? | No, esas columnas no existen en la vista y no tiene permiso sobre la tabla base. |
| ¿Qué principio de privacidad se aplica? | Minimización y limitación de finalidad. |
| ¿Qué principio de seguridad se aplica? | Mínimo privilegio (y need-to-know). |

---

## 6. Derechos ARCO

| Derecho | Implicación técnica |
|---|---|
| **Acceso** | Ubicar todos los datos de la persona (tablas, vistas, respaldos, reportes) con un identificador confiable. Además del resultado de la consulta, informar finalidades, origen, destinatarios o transferencias, plazo de conservación y cómo ejercer los demás derechos. |
| **Rectificación** | `UPDATE` acotado por clave primaria, validación de identidad y autorización previa, y registro de quién, cuándo y qué valor se cambió. Propagar el cambio a copias y sistemas dependientes. |
| **Cancelación** | Antes de borrar, mapear tablas relacionadas, respaldos, réplicas, auditoría, copias analíticas, exportaciones y sistemas externos. Verificar obligaciones legales de conservación (p. ej. fiscales). Puede requerir bloqueo antes de supresión. |
| **Oposición** | No implica borrar todo. Requiere separar finalidades (marcas de oposición, exclusión de listas de marketing, vistas filtradas) y conservar lo necesario para la relación o por ley. |

Consulta de ejemplo (acceso):

```sql
SELECT id, nombre, correo, telefono, rfc, edad, ciudad, codigo_postal, fecha_alta
FROM clientes
WHERE correo = 'ana@example.com';
```

Rectificación:

```sql
UPDATE clientes
SET correo = 'nuevo-correo@example.com'
WHERE id = 1;

SELECT id, nombre, correo FROM clientes WHERE id = 1;
```

El DBA identifica las implicaciones técnicas. La resolución jurídica y administrativa corresponde a privacidad, cumplimiento y jurídico.

---

## 7. Retención

El periodo de conservación no se fija por conveniencia técnica ni por "utilidad futura". Debe determinarse con:

1. La finalidad de cada dato.
2. Obligaciones legales, fiscales y contractuales (p. ej. conservación de información fiscal).
3. Plazos de prescripción y posibles reclamaciones.
4. Necesidad operativa real.
5. Riesgo de conservar el dato frente a su valor.
6. Aprobación del propietario del dato y de jurídico/privacidad.

Propuesta de referencia (a validar por jurídico y cumplimiento):

| Dato | Retención propuesta | Acción al finalizar |
|---|---|---|
| Datos de contacto (nombre, correo, teléfono) | Vigencia de la relación + 12 meses | Supresión o anonimización |
| RFC y datos fiscales | Plazo fiscal aplicable (referencia: 5 años) | Bloqueo y supresión |
| Edad, ciudad, código postal | Vigencia de la relación | Agregación o anonimización |
| Datos de soporte | 24 meses tras el cierre del caso | Supresión |

La conservación indefinida "por si sirve en el futuro" contradice la minimización y aumenta el riesgo y la superficie de ataque.

---

## 8. Gobierno de datos

| Dato | Finalidad | Responsable (data owner) | Usuarios autorizados | Protección | Retención | Acción al finalizar |
|---|---|---|---|---|---|---|
| nombre | Atención y facturación | Gerencia de Atención al Cliente | Atención, Facturación | Rol + vista, auditoría | Relación + 12 meses | Supresión/anonimización |
| correo | Contacto y atención | Gerencia de Atención al Cliente | Atención | Rol + vista, auditoría | Relación + 12 meses | Supresión |
| telefono | Contacto | Gerencia de Atención al Cliente | Atención | Rol + vista, auditoría | Relación + 12 meses | Supresión |
| rfc | Facturación | Gerencia de Finanzas/Facturación | Facturación | Cifrado de columna, acceso restringido, auditoría | Plazo fiscal (ref. 5 años) | Bloqueo y supresión |
| edad | Estadística | Dirección de Analítica | Analítica (rangos) | Vista con rangos | Vigencia de la relación | Agregación |
| ciudad | Atención y estadística | Dirección de Analítica | Atención, Analítica | Vista agregada | Vigencia de la relación | Agregación |
| codigo_postal | Facturación y región | Gerencia de Finanzas | Facturación, Analítica (región) | Vista con generalización | Vigencia de la relación | Generalización/supresión |

Roles:

- **Propietario de datos:** decide uso y controles de cada dato.
- **DBA / custodio:** implementa y mantiene controles técnicos; no define finalidades.
- **Responsable de privacidad:** supervisa el cumplimiento y atiende solicitudes ARCO.
- **Jurídico:** determina bases jurídicas y plazos legales.
- **Dirección:** aprueba políticas y asigna recursos.

### Controles técnicos vs. administrativos

| Medida | Técnico | Administrativo | Justificación |
|---|---|---|---|
| Crear roles de PostgreSQL | X | | Se implementa en el motor. |
| Política de retención | | X | Es una regla organizacional; su ejecución puede automatizarse (parte técnica). |
| Cifrado de datos | X | | Medida tecnológica. La gestión de llaves requiere procedimientos administrativos. |
| Procedimiento para solicitudes ARCO | | X | Es un proceso organizacional con apoyo técnico del DBA. |
| Vista con información limitada | X | | Restringe la información expuesta. |
| Clasificación de información | | X | Es una decisión de política que luego se refleja en controles técnicos. |
| Registro de auditoría | X | | Mecanismo técnico, pero su revisión es administrativa. |
| Política de control de acceso | | X | Define quién accede a qué; se implementa con roles y permisos (técnico). |

---

## 9. Evaluación integral

Principales riesgos identificados (detalle en `evidencias/14-evaluacion-integral.md`):

1. Analítica consulta directamente la tabla `clientes` (acceso excesivo).
2. Datos conservados 12 años sin política de retención.
3. Copias completas de producción entregadas a desarrolladores.
4. Datos reales en ambientes de desarrollo y pruebas.
5. Marketing usa correos sin finalidad ni base jurídica documentadas.
6. No existe documentación de finalidades por dato.
7. Datos identificables usados para una finalidad que solo requiere estadísticas.
8. No hay responsables definidos ni catálogo de datos.
9. No hay trazabilidad del acceso a datos personales.
10. No hay procedimiento para atender solicitudes ARCO.

---

## 10. Conclusiones

La seguridad técnica protege los datos, pero no decide si deben existir, para qué se usan ni cuánto tiempo se conservan. La privacidad exige responder primero por qué se tiene el dato, quién lo necesita, para qué y por cuánto tiempo.

El DBA traduce estos principios a controles concretos (tablas mínimas, vistas, roles, mínimo privilegio, cifrado, auditoría, retención automatizada) y escala las decisiones jurídicas y de finalidad a los responsables correspondientes. Aprendí que el diseño de la base de datos es la primera línea de privacidad: lo que no se recopila no puede filtrarse ni mal utilizarse.

---

## 11. Preguntas de reflexión

**1. ¿Una base de datos técnicamente segura cumple necesariamente con todos los requisitos de privacidad?**
No. Puede estar cifrada y bien configurada y aun así recopilar datos innecesarios, usarlos para fines no informados o conservarlos indefinidamente.

**2. ¿Por qué el mínimo privilegio contribuye a la privacidad?**
Porque limita quién puede ver datos personales a lo estrictamente necesario, reduce exposición, usos indebidos y el impacto de credenciales comprometidas.

**3. ¿Por qué el DBA no debería decidir por sí solo la finalidad?**
Porque la finalidad es una decisión de negocio y jurídica (bases jurídicas, aviso de privacidad, consentimiento). El DBA tiene acceso técnico, pero eso no le da autoridad sobre el uso de los datos.

**4. ¿Por qué los desarrolladores no deberían recibir copias completas de producción?**
Porque no necesitan datos reales para desarrollar, se amplía el número de personas con acceso y los ambientes de desarrollo suelen tener menos controles.

**5. ¿Por qué una copia de desarrollo también es un riesgo de privacidad?**
Porque contiene datos personales reales fuera del entorno protegido, con controles más débiles, y está sujeta a las mismas obligaciones de ciclo de vida, retención y atención de derechos.

**6. ¿Por qué la retención forma parte del ciclo de vida?**
Porque todo dato tiene etapas (obtención, uso, conservación, eliminación). Sin retención definida, el dato nunca llega a la etapa de eliminación y el riesgo crece con el tiempo.

**7. ¿Relación entre privacidad por diseño y diseño de bases de datos?**
El esquema define qué se recopila. Diseñar tablas mínimas, vistas, roles y valores por defecto restrictivos incorpora la privacidad desde el inicio en lugar de corregirla después.

**8. ¿Qué controles técnicos implementaría?**
Mínimo privilegio con roles, vistas y esquemas separados, seguridad a nivel de fila cuando aplique, cifrado de columnas sensibles (p. ej. RFC) y en tránsito, enmascaramiento y datos sintéticos o anonimizados en desarrollo, auditoría, retención automatizada y revisión periódica de permisos.

**9. ¿Qué debe conocer un DBA para responder técnicamente a una solicitud ARCO?**
Dónde residen los datos de la persona (tablas, respaldos, réplicas, reportes, exportaciones, sistemas externos), cómo identificarla de forma única, cómo modificar o eliminar sin romper integridad, qué obligaciones de conservación existen y cómo dejar evidencia.

**10. ¿Responsabilidades por rol?**

| Rol | Responsabilidad |
|---|---|
| DBA | Implementar controles técnicos, ejecutar cambios autorizados, mantener trazabilidad e informar implicaciones técnicas. |
| Responsable de privacidad | Coordinar el cumplimiento, el aviso de privacidad y la atención de solicitudes. |
| Área jurídica | Determinar bases jurídicas, plazos legales y obligaciones aplicables. |
| Propietario de los datos | Definir la finalidad, quién puede usar los datos y aprobar controles. |
