# Evidencia 05 — Análisis de una finalidad secundaria

## Objetivo

Analizar si la organización puede utilizar los datos de clientes para una nueva finalidad: "Enviar promociones personalizadas basadas en edad, ciudad y comportamiento de compra".

## Procedimiento

1. Se identificó la finalidad original con la que se obtuvieron los datos (atención, facturación, analítica).
2. Se comparó con la nueva finalidad (marketing personalizado).
3. Se evaluó la compatibilidad, las preguntas previas, los datos necesarios, el acceso y los controles técnicos.

## Resultado

**1. ¿Tener los datos significa poder usarlos para cualquier finalidad?**
No. Los datos se obtienen para finalidades determinadas informadas al titular en el aviso de privacidad. Usarlos para fines distintos puede requerir una nueva base jurídica, actualización del aviso y, según el caso, consentimiento. La disponibilidad técnica no equivale a autorización.

**2. Preguntas que debe hacerse la organización antes de implementarlo**

- ¿La finalidad está incluida en el aviso de privacidad?
- ¿Es compatible con la finalidad original?
- ¿Cuál es la base jurídica? ¿Se requiere consentimiento?
- ¿Se dio al titular la opción de oponerse?
- ¿Qué datos son estrictamente necesarios?
- ¿Quién será el propietario del tratamiento?
- ¿Se transferirán datos a terceros (plataformas de envío)?
- ¿Cómo se atenderá la oposición o revocación?
- ¿Por cuánto tiempo se usarán los datos con este fin?

**3. Datos realmente necesarios**

| Dato | ¿Necesario? | Observación |
|---|---|---|
| correo | Sí | Canal de envío |
| ciudad | Sí | Segmentación geográfica |
| rango de edad | Sí | Se usa el rango, no la edad exacta |
| historial de compras | Sí (resumido) | Solo categorías o frecuencia, no detalle innecesario |
| rfc | No | No aporta a promociones |
| telefono | No | Salvo que se autorice ese canal |
| nombre | Opcional | Solo si se personaliza el saludo |
| codigo_postal | No | Basta con ciudad o región |

**4. ¿Marketing necesita acceso directo a `clientes`?**
No. Debe recibir una vista o tabla preparada con solo los campos necesarios y únicamente de clientes que no se hayan opuesto.

**5. Controles técnicos para limitar la información**

```sql
CREATE ROLE marketing NOLOGIN;

CREATE TABLE marketing_preferencias (
    cliente_id      BIGINT PRIMARY KEY REFERENCES clientes(id),
    acepta_promos   BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_registro  TIMESTAMP NOT NULL DEFAULT now()
);

CREATE VIEW v_marketing_clientes AS
SELECT
    c.id,
    c.correo,
    c.ciudad,
    CASE
        WHEN c.edad < 18 THEN 'Menor de 18'
        WHEN c.edad BETWEEN 18 AND 29 THEN '18-29'
        WHEN c.edad BETWEEN 30 AND 44 THEN '30-44'
        WHEN c.edad BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60 o más'
    END AS rango_edad
FROM clientes c
JOIN marketing_preferencias p ON p.cliente_id = c.id
WHERE p.acepta_promos = TRUE;

GRANT USAGE ON SCHEMA public TO marketing;
GRANT SELECT ON v_marketing_clientes TO marketing;
```

Otros controles: auditoría de consultas, exportaciones controladas, retiro automático de quienes se opongan y revisión periódica de permisos.

## Análisis

El uso de datos con fines de marketing es una finalidad secundaria que no puede asumirse compatible. Debe evaluarse jurídicamente y comunicarse al titular. Técnicamente, la forma correcta de limitar el uso es entregar solo la información necesaria mediante vistas y registrar las preferencias y oposiciones de los clientes. Además, los menores de edad requieren especial cuidado, por lo que la vista podría excluirlos.

## Conclusión

La organización no puede usar libremente los datos que posee. Antes de implementar la campaña debe validar la finalidad, la base jurídica y el aviso de privacidad. El DBA implementa los controles técnicos (vistas, roles, marcas de oposición), pero la decisión sobre la finalidad corresponde al propietario de los datos, a privacidad y a jurídico.
