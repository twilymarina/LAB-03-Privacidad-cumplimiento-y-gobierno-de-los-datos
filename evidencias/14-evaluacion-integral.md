# Evidencia 14 — Evaluación integral de riesgos

## Objetivo

Identificar al menos 10 problemas de privacidad en un escenario con 50,000 clientes y proponer controles para cada uno.

## Procedimiento

1. Se analizó el escenario: analítica con acceso directo a `clientes`, datos con 12 años de antigüedad, sin política de retención, copias reales para desarrollo, uso de correos por marketing y sin documentación de finalidades.
2. Se identificó el principio de privacidad afectado, el riesgo y un control propuesto por cada hallazgo.

## Resultado

| # | Problema | Principio afectado | Riesgo | Control propuesto |
|---|---|---|---|---|
| 1 | Analítica consulta directamente la tabla `clientes` | Mínimo privilegio; minimización | Acceso a nombre, correo, RFC y teléfono sin necesidad | Revocar `SELECT` sobre `clientes`; entregar vista agregada `v_analitica_clientes` |
| 2 | Analítica solo genera estadísticas mensuales pero ve datos identificables | Limitación de finalidad; proporcionalidad | Uso o filtración de datos identificables sin necesidad | Vistas materializadas con datos agregados o rangos |
| 3 | Datos conservados 12 años | Minimización; retención | Mayor exposición y datos obsoletos | Definir plazos y depurar o anonimizar los registros vencidos |
| 4 | No existe política de retención documentada | Responsabilidad; ciclo de vida | Conservación indefinida e incumplimiento | Política de retención por dato aprobada por jurídico y privacidad |
| 5 | Desarrolladores reciben copias completas de producción | Mínimo privilegio; seguridad | Ampliación del acceso a datos reales | Entregar datos sintéticos o anonimizados |
| 6 | Copias de desarrollo contienen datos reales | Seguridad; ciclo de vida | Filtración desde ambientes menos protegidos | Enmascaramiento y anonimización antes de clonar; eliminación periódica |
| 7 | Marketing usa los correos para campañas | Limitación de finalidad; base jurídica | Uso no informado; posible incumplimiento y oposición ignorada | Validar aviso y base jurídica; tabla de preferencias y vista filtrada |
| 8 | No hay documentación de finalidad por dato | Responsabilidad; transparencia | Imposible justificar el tratamiento | Catálogo de datos y matriz de gobierno |
| 9 | No hay responsables (data owners) definidos | Responsabilidad; gobierno | Nadie decide ni responde por el uso de los datos | Asignar propietarios y custodios formales |
| 10 | No hay trazabilidad de accesos a datos personales | Trazabilidad; seguridad | No se puede detectar ni investigar usos indebidos | Auditoría (p. ej. pgAudit) y revisión periódica |
| 11 | Sin procedimiento para solicitudes ARCO | Derechos del titular | No se atienden solicitudes en tiempo y forma | Procedimiento formal y consultas preparadas para localizar datos |
| 12 | Probables respaldos y exportaciones sin control | Ciclo de vida; seguridad | Copias no controladas de datos personales | Inventario de copias, cifrado y retención de respaldos |
| 13 | RFC y datos fiscales sin protección reforzada | Seguridad; proporcionalidad | Exposición de datos de alto valor | Cifrado de columna, acceso restringido a Facturación |
| 14 | Datos mezclados en una sola tabla para todos los procesos | Privacidad por diseño | Imposibilidad de separar finalidades | Separar en tablas o esquemas por finalidad |

## Análisis

Los problemas no son únicamente técnicos. Muchos son de gobierno: ausencia de finalidades, responsables y políticas. Otros son de diseño (tabla única para todos), de acceso (analítica con acceso total) y de ciclo de vida (12 años de datos y copias en desarrollo). Combinados, aumentan la probabilidad y el impacto de un incidente con 50,000 titulares.

## Conclusión

La organización puede tener una base técnicamente operativa y aun así incumplir principios de privacidad. La mitigación requiere controles técnicos (roles, vistas, enmascaramiento, auditoría, retención automatizada) y administrativos (políticas, responsables, procedimientos). Las prioridades inmediatas son restringir el acceso de analítica, eliminar datos reales de desarrollo y definir la política de retención.
