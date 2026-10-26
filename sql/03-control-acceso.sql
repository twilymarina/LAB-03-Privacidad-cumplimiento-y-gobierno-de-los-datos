-- LAB-03 | Actividad 4: Control de acceso relacionado con la finalidad

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

-- No se otorga: GRANT SELECT ON clientes TO analista;

-- Verificación de privilegios
SELECT
    grantee,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'analista';

-- Prueba de acceso (debe fallar con "permission denied")
SET ROLE analista;
SELECT * FROM v_analitica_clientes LIMIT 5;
SELECT * FROM clientes LIMIT 5;
RESET ROLE;
