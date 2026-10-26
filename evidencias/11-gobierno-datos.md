# Evidencia 11 — Matriz de gobierno de datos

## Objetivo

Construir una matriz que relacione cada dato con su finalidad, responsable, usuarios autorizados, protección, retención y acción al finalizar, demostrando que el acceso responde a una necesidad funcional.

## Procedimiento

1. Se tomaron los campos principales de `clientes`.
2. Se asignó la finalidad de cada uno.
3. Se definió un propietario del dato (decide) y usuarios autorizados (utilizan).
4. Se propusieron protecciones, retención y acción final.
5. Los roles considerados fueron: Atención al cliente, Facturación, Analítica, DBA y Dirección.

## Resultado

| Dato | Finalidad | Responsable | Usuarios autorizados | Protección | Retención | Acción al finalizar |
|---|---|---|---|---|---|---|
| nombre | Identificación para atención y facturación | Gerencia de Atención al Cliente | Atención, Facturación | Roles y vistas por función; auditoría de acceso | Relación + 12 meses | Supresión o anonimización |
| correo | Contacto y atención | Gerencia de Atención al Cliente | Atención | Vista restringida; auditoría; cifrado en tránsito | Relación + 12 meses | Supresión |
| telefono | Contacto y atención | Gerencia de Atención al Cliente | Atención | Vista restringida; auditoría | Relación + 12 meses | Supresión |
| rfc | Facturación | Gerencia de Finanzas | Facturación | Cifrado de columna; acceso mínimo; auditoría reforzada; enmascaramiento en consultas | Plazo fiscal aplicable (ref. 5 años) | Bloqueo y supresión |
| edad | Estadística | Dirección de Analítica | Analítica (solo rangos) | Vista con rangos; sin acceso a tabla base | Vigencia de la relación | Agregación |
| ciudad | Atención y estadística | Dirección de Analítica | Atención, Analítica | Vista agregada | Vigencia de la relación | Agregación |
| codigo_postal | Domicilio fiscal y estadística regional | Gerencia de Finanzas | Facturación; Analítica (región) | Generalización a región para analítica | Vigencia de la relación | Generalización o supresión |

### DBA y Dirección

| Rol | Función respecto a los datos | Límite |
|---|---|---|
| DBA (custodio) | Administra, respalda e implementa controles | No define finalidades ni usa los datos para fines propios |
| Dirección | Aprueba políticas y recursos | No requiere acceso a datos personales individuales |
| Responsable de privacidad | Supervisa el cumplimiento y las solicitudes ARCO | Coordina con jurídico |
| Jurídico | Determina bases jurídicas y plazos | Decide el marco legal aplicable |

## Análisis

Ningún rol tiene acceso a todos los datos sin justificación. Atención ve contacto, Facturación ve datos fiscales, Analítica solo recibe información agregada. El DBA tiene acceso técnico por su función, pero ello no autoriza el uso de los datos. Cada dato tiene un propietario que responde por su uso y retención.

## Conclusión

La matriz demuestra que el acceso debe derivar de una necesidad funcional documentada y no del cargo ni de la conveniencia. Un catálogo de este tipo facilita auditorías, atención de solicitudes ARCO y revisión periódica de permisos.
