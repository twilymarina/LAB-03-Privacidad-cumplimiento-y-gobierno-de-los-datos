# Evidencia 01 — Inventario y finalidad de los datos

## Objetivo

Identificar los datos personales de la tabla `clientes`, relacionarlos con una finalidad, determinar su necesidad, el nivel de acceso y la retención, justificando cada decisión.

## Procedimiento

1. Se revisó la estructura de la tabla `clientes` (id, nombre, correo, telefono, rfc, edad, ciudad, codigo_postal, fecha_alta).
2. Se analizaron los procesos de la organización: atención al cliente, facturación, analítica y administración (DBA).
3. Para cada campo se evaluó si es dato personal, para qué se usa, si es necesario, quién debe acceder y por cuánto tiempo conservarlo.
4. Las retenciones son propuestas de referencia y deben validarse con jurídico y cumplimiento.

## Resultado

| Campo | ¿Es dato personal? | Finalidad | ¿Es necesario? | Nivel de acceso | Retención |
|---|---|---|---|---|---|
| id | Indirecto (seudónimo) | Identificar el registro y relacionar tablas | Sí | Operación y DBA (técnico) | Mientras exista el registro |
| nombre | Sí | Atención al cliente y facturación | Sí | Atención, Facturación | Relación + 12 meses |
| correo | Sí | Contacto y atención al cliente | Sí | Atención | Relación + 12 meses |
| telefono | Sí | Contacto y atención al cliente | Sí | Atención | Relación + 12 meses |
| rfc | Sí (dato fiscal) | Facturación | Solo para facturación | Facturación (restringido) | Plazo fiscal aplicable (ref. 5 años) |
| edad | Sí | Estadística (rangos de edad) | Solo para analítica | Analítica, solo agregada | Vigencia de la relación |
| ciudad | Sí (indirecto) | Atención y estadística | Sí | Atención; Analítica agregada | Vigencia de la relación |
| codigo_postal | Sí (indirecto, cuasi-identificador) | Domicilio fiscal y estadística regional | Sí, con restricción | Facturación; Analítica por región | Vigencia de la relación |
| fecha_alta | Sí (indirecto) | Gestión de la relación y cálculo de plazos de retención | Sí | Operación | Vigencia de la relación + plazo |

### Justificaciones

- **id:** por sí solo no identifica a nadie, pero vinculado a otras tablas permite identificar a la persona. Es necesario como llave primaria.
- **nombre:** identifica directamente a la persona. Es necesario para atender y facturar.
- **correo:** identifica directamente y es el canal de contacto. Su uso para marketing requeriría una finalidad adicional informada.
- **telefono:** identifica y permite contacto. Solo lo requiere atención.
- **rfc:** dato fiscal vinculado a una persona. Es necesario solo para facturación. Atención y analítica no deben verlo. Requiere protección reforzada.
- **edad:** relacionada con la persona. Analítica solo necesita rangos. Se debe evaluar si conservarla es proporcional.
- **ciudad:** por sí sola tiene bajo poder identificativo, pero combinada con otros datos puede identificar.
- **codigo_postal:** combinado con edad y ciudad permite reidentificar. Se generaliza a región para analítica.
- **fecha_alta:** permite calcular la antigüedad de la relación y los plazos de retención.

## Análisis

No todos los datos son necesarios para todos los procesos. Cada dato tiene una finalidad principal y solo debe ser accesible por quien la requiere. El acceso administrativo del DBA no implica autorización para usar los datos con cualquier fin. Los datos sensibles desde el punto de vista fiscal (RFC) y los cuasi-identificadores (código postal, edad, ciudad) merecen controles adicionales.

## Conclusión

El inventario demuestra que la mayor parte de los campos solo se justifica para una o dos finalidades. Esto permite aplicar minimización y mínimo privilegio, y es la base para diseñar vistas, roles y políticas de retención. Documentar la finalidad antes de otorgar acceso es el primer paso del gobierno de datos.
