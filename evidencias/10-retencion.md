# Evidencia 10 — Política de retención

## Objetivo

Analizar la política propuesta "Conservar todos los datos de clientes indefinidamente porque podrían ser útiles en el futuro" y determinar si es compatible con los principios de privacidad.

## Procedimiento

1. Se evaluó la política frente a los principios de minimización, necesidad, proporcionalidad y finalidad.
2. Se identificaron los riesgos de conservar datos innecesarios.
3. Se definió qué debe determinar y documentar la organización para fijar un periodo de retención.

## Resultado

**Pregunta 1. ¿Es compatible con el principio de minimización?**
No. La conservación "por si sirve" no corresponde a una finalidad determinada ni a una necesidad concreta. Los datos deben conservarse solo mientras sean necesarios para la finalidad que justificó su obtención o por obligaciones legales.

**Pregunta 2. Riesgos de conservar información innecesaria**

- Mayor superficie de exposición ante filtraciones o accesos indebidos.
- Mayor impacto en caso de incidente de seguridad.
- Datos desactualizados o inexactos.
- Uso de datos para finalidades no informadas.
- Mayor costo de almacenamiento, respaldo y administración.
- Dificultad para atender derechos ARCO.
- Posible incumplimiento normativo y sanciones.
- Afectación a la reputación.

**Pregunta 3. Qué debe determinar la organización antes de fijar un periodo**

- La finalidad de cada dato.
- Obligaciones legales, fiscales, contractuales y regulatorias aplicables.
- Plazos de prescripción y posibles reclamaciones.
- Necesidad operativa real.
- Riesgo asociado a la conservación.
- Qué hacer al terminar el plazo (supresión, bloqueo, anonimización).
- Responsables de aprobar y ejecutar la política.

**Pregunta 4. Información que debe documentarse**

| Elemento | Descripción |
|---|---|
| Dato o categoría | Qué se conserva |
| Finalidad | Para qué se conserva |
| Fundamento | Ley, contrato o necesidad operativa |
| Periodo | Duración y desde cuándo se cuenta |
| Responsable | Propietario del dato |
| Acción final | Supresión, bloqueo o anonimización |
| Excepciones | Casos que suspenden la eliminación (litigios, auditorías) |
| Fecha de revisión | Revisión periódica de la política |

### Propuesta de política (a validar por jurídico y cumplimiento)

| Dato | Periodo | Fundamento | Acción al finalizar |
|---|---|---|---|
| Datos de contacto | Relación + 12 meses | Operación y posibles reclamaciones | Supresión |
| RFC y datos fiscales | Plazo fiscal aplicable (ref. 5 años) | Obligaciones fiscales | Bloqueo y supresión |
| Edad, ciudad, código postal | Vigencia de la relación | Estadística | Agregación o anonimización |
| Datos de soporte | 24 meses tras el cierre | Seguimiento de casos | Supresión |

Ejemplo técnico de identificación de registros vencidos:

```sql
SELECT id
FROM clientes
WHERE fecha_alta < now() - INTERVAL '12 years';
```

## Análisis

Conservar todo indefinidamente transforma la base de datos en un pasivo: crece el riesgo sin que exista un beneficio justificado. La retención debe definirse por dato y finalidad, y debe formar parte del ciclo de vida. El DBA puede automatizar la identificación y eliminación, pero el plazo lo definen jurídico, privacidad y el propietario del dato.

## Conclusión

La política propuesta no es compatible con la minimización ni con la limitación de finalidad. Se recomienda sustituirla por una política documentada con periodos, fundamentos y acciones finales, revisada periódicamente y respaldada por controles técnicos.
