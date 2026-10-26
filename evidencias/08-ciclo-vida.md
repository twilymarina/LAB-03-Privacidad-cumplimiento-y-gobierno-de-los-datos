# Evidencia 08 — Derecho de cancelación y ciclo de vida

## Objetivo

Analizar por qué eliminar un registro de la tabla principal no implica la eliminación total de la información de una persona, e identificar los lugares donde pueden existir copias de sus datos.

## Procedimiento

1. Se supuso una solicitud de cancelación autorizada por el área responsable.
2. No se ejecutó `DELETE` sobre `clientes`.
3. Se identificaron las ubicaciones posibles de los datos en el ciclo de vida.
4. Se construyó un mapa de datos y se evaluó el impacto de cada ubicación.

## Resultado

### Mapa de datos

```
clientes
   │
   ├── tablas relacionadas (clientes_soporte, pedidos, facturas, marketing_preferencias)
   ├── respaldos (completos, incrementales, WAL archivado)
   ├── réplicas (standby, lectura)
   ├── registros de auditoría y logs
   ├── copias analíticas (data marts, tablas históricas)
   ├── reportes
   ├── exportaciones (CSV, hojas de cálculo, correos)
   ├── ambientes de desarrollo y pruebas
   └── sistemas externos (plataformas de correo, facturación, CRM, proveedores)
```

### Análisis por ubicación

| Ubicación | ¿Contiene datos de la persona? | Consideración |
|---|---|---|
| Tablas relacionadas | Sí | Revisar llaves foráneas y `ON DELETE`; evitar registros huérfanos |
| Respaldos | Sí | Son inmutables; se eliminan al expirar su ciclo de retención |
| Réplicas | Sí | Reciben el cambio, pero deben verificarse |
| Auditoría | Sí (identificadores) | Puede requerir conservación por obligación legal |
| Copias analíticas | Posiblemente | Revisar si están anonimizadas |
| Reportes y exportaciones | Sí | Difíciles de rastrear si no hay inventario |
| Desarrollo y pruebas | Posiblemente | Si hay datos reales, también deben depurarse |
| Sistemas externos | Sí | Requiere notificar a encargados o terceros |

### Consideraciones técnicas

- Algunos datos pueden tener obligación legal de conservación (p. ej. fiscales). En ese caso se bloquean y se limita su uso.
- Un `DELETE` en PostgreSQL deja tuplas muertas hasta `VACUUM`; los datos pueden persistir en WAL y respaldos.
- Una alternativa es la anonimización cuando la eliminación física no es posible.

## Análisis

Eliminar el registro de `clientes` solo elimina una copia. Los datos siguen existiendo en respaldos, réplicas, reportes, exportaciones, ambientes de prueba y sistemas externos. Sin un mapa de datos, la organización no puede garantizar que la cancelación sea efectiva. Además, algunas obligaciones legales exigen conservar parte de la información, por lo que la cancelación puede ser parcial o diferida mediante bloqueo. El DBA identifica y ejecuta lo técnico, pero la procedencia de la cancelación la decide el área responsable.

## Conclusión

El ciclo de vida del dato abarca todos los lugares donde vive la información. Para atender una cancelación se necesita un catálogo de datos, un inventario de copias y un procedimiento coordinado con privacidad, jurídico y los dueños de los sistemas externos. Eliminar una fila es solo una parte del proceso.
