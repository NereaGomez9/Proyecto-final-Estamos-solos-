CREATE DATABASE Espacio; 

USE Espacio;

SELECT *
FROM estrellas_exoplanetas;

SELECT 
    nombre_estrella,
    ROUND(masa_estrella_m_solar, 2) AS masa_estrella_m_solar,
    ROUND(radio_estrella_r_solar, 2) AS radio_estrella_r_solar,
    ROUND(temperatura_estrella_k, 2) AS temperatura_estrella_k,
    ROUND(distancia_estrella_pc, 2) AS distancia_estrella_pc,
    ROUND(masa_rel_solar, 2) AS masa_rel_solar,
    ROUND(radio_rel_solar, 2) AS radio_rel_solar,
    ROUND(temperatura_rel_solar, 2) AS temperatura_rel_solar
FROM estrellas_exoplanetas;

SELECT *
FROM exoplanetas_final;

SELECT
	nombre_exoplaneta,
    estado_exoplaneta,
    ROUND(masa_exoplaneta_m_tierra, 2) AS masa_exoplaneta_m_tierra,
    ROUND(radio_exoplaneta_r_tierra, 2) As radio_exoplaneta_r_tierra,
    ROUND(periodo_orbital_dias, 2) AS periodo_orbital_dias,
    ROUND(semi_eje_mayor_ua, 2) AS semi_eje_mayor_ua,
    ROUND(excentricidad_orbital, 2) AS excentricidad_orbital,
    ROUND(temperatura_media_k, 2) AS temperatura_media_k,
    ROUND(insolacion, 2) AS insolacion,
    nombre_estrella,
    tipo_espectral
FROM exoplanetas_final;

-- Añadir más relaciones entre las diferentes tablas
-- Sol - Tierra

ALTER TABLE tierra
ADD COLUMN sol_id INT;

UPDATE tierra
SET sol_id = 1;

ALTER TABLE tierra
ADD CONSTRAINT fk_tierra_sol
FOREIGN KEY (sol_id) REFERENCES sol(sol_id);

-- Estrellas - exoplanetas
ALTER TABLE exoplanetas_final
MODIFY COLUMN nombre_estrella VARCHAR(100);

ALTER TABLE estrellas_exoplanetas
MODIFY COLUMN nombre_estrella VARCHAR(100);

ALTER TABLE estrellas_exoplanetas
ADD UNIQUE (nombre_estrella);

ALTER TABLE exoplanetas_final
ADD CONSTRAINT fk_exoplanetas_estrellas_nombre
FOREIGN KEY (nombre_estrella) REFERENCES estrellas_exoplanetas(nombre_estrella);


-- Unión de Tierra y Sol 
ALTER TABLE tierra
DROP COLUMN sol_id;

ALTER TABLE sol
MODIFY COLUMN Nombre VARCHAR(100);

ALTER TABLE tierra
MODIFY COLUMN nombre_estrella VARCHAR(100);

ALTER TABLE tierra
ADD CONSTRAINT fk_tierra_sol_nombre
FOREIGN KEY (nombre_estrella) REFERENCES sol(Nombre);


-- Lunas - Tierra

ALTER TABLE tierra
ADD COLUMN luna VARCHAR(50);

UPDATE tierra
SET luna = 'Luna';

ALTER TABLE tierra MODIFY COLUMN luna VARCHAR(50);
ALTER TABLE lunas_sistema_solar_completo MODIFY COLUMN Nombre_Luna VARCHAR(50);

ALTER TABLE lunas_sistema_solar_completo
ADD UNIQUE (Nombre_Luna);

ALTER TABLE tierra
ADD CONSTRAINT fk_tierra_luna_nombre
FOREIGN KEY (luna) REFERENCES lunas_sistema_solar_completo(Nombre_Luna);

SELECT t.*, l.*
FROM tierra t
JOIN lunas_sistema_solar_completo l
  ON t.luna = l.Nombre_Luna;

-- Unión Sol con Planetas Sistema Solar
ALTER TABLE planetas_sistema_solar_limpio
ADD COLUMN estrella VARCHAR(50);

UPDATE planetas_sistema_solar_limpio
SET estrella = 'Sol';

ALTER TABLE planetas_sistema_solar_limpio
ADD CONSTRAINT fk_planetas_sol
FOREIGN KEY (estrella) REFERENCES sol(Nombre);

-- Unión Planetas del Sistema Solar con las Lunas

ALTER TABLE tierra DROP FOREIGN KEY fk_tierra_luna;

ALTER TABLE lunas_sistema_solar_completo
MODIFY COLUMN Nombre_Luna VARCHAR(100);

ALTER TABLE tierra
MODIFY COLUMN luna VARCHAR(100);

SELECT TABLE_NAME, CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'Espacio';

-- 1. Eliminar FK innecesarias
ALTER TABLE estrellas_exoplanetas DROP FOREIGN KEY fk_estrella_sol;
ALTER TABLE exoplanetas_final DROP FOREIGN KEY fk_exoplaneta_tierra;
ALTER TABLE lunas_sistema_solar_completo DROP FOREIGN KEY fk_luna_planeta;
ALTER TABLE planetas_sistema_solar_limpio DROP FOREIGN KEY fk_planeta_tierra;
ALTER TABLE tierra DROP FOREIGN KEY fk_tierra_sol;

-- 2. Eliminar columnas ID innecesarias
ALTER TABLE estrellas_exoplanetas DROP COLUMN star_id;
ALTER TABLE exoplanetas_final DROP COLUMN planet_id, DROP COLUMN tierra_id;
ALTER TABLE lunas_sistema_solar_completo DROP COLUMN moon_id, DROP COLUMN planet_id;
ALTER TABLE planetas_sistema_solar_limpio DROP COLUMN planet_id, DROP COLUMN tierra_id;

-- Unión de exoplanetas con la tierra, con las características de la tierra

SELECT 
    exo.nombre_exoplaneta,
    exo.masa_exoplaneta_m_tierra AS masa_exo_en_Tierras,
    exo.radio_exoplaneta_r_tierra AS radio_exo_en_Tierras,
    t.masa_planeta_m_tierra AS masa_Tierra_ref,
    t.radio_planeta_r_tierra AS radio_Tierra_ref
FROM exoplanetas_final AS exo
CROSS JOIN tierra AS t;

-- Unión de las estrellas de los exoplanetas con el sol

SELECT 
    nombre AS nombre_estrella,
    masa_rel_solar,
    radio_rel_solar,
    temperatura_rel_solar,
    sol.Masa_kg AS masa_sol,
    sol.Radio_km AS radio_sol,
    sol.Temperatura_superficial_K AS temperatura_sol
FROM estrellas_exoplanetas
CROSS JOIN sol;

CREATE OR REPLACE VIEW exoplanetas_con_tierra AS
SELECT 
    exo.nombre_exoplaneta,
    exo.masa_exoplaneta_m_tierra,
    exo.radio_exoplaneta_r_tierra,
    t.masa_planeta_m_tierra AS masa_Tierra,
    t.radio_planeta_r_tierra AS radio_Tierra
FROM exoplanetas_final AS exo
CROSS JOIN tierra AS t;

CREATE OR REPLACE VIEW estrellas_con_sol AS
SELECT 
    nombre_estrella,
    masa_rel_solar,
    radio_rel_solar,
    temperatura_rel_solar,
    sol.Masa_kg AS masa_sol,
    sol.Radio_km AS radio_sol,
    sol.Temperatura_superficial_K AS temperatura_sol,
    -- Proporciones respecto al Sol
    masa_rel_solar / sol.Masa_kg AS proporcion_masa,
    radio_rel_solar / sol.Radio_km AS proporcion_radio,
    temperatura_rel_solar / sol.Temperatura_superficial_K AS proporcion_temperatura
FROM estrellas_exoplanetas
CROSS JOIN sol;

-- Unión Lunas y Planetas del Sistema Solar

ALTER TABLE planetas_sistema_solar_limpio
MODIFY COLUMN nombre_planeta VARCHAR(255) NOT NULL;

ALTER TABLE planetas_sistema_solar_limpio
ADD PRIMARY KEY (nombre_planeta);

-- Luego rellenas esta columna con el planeta correspondiente
-- Finalmente creas la FK
ALTER TABLE lunas_sistema_solar_completo
ADD CONSTRAINT fk_luna_planeta
FOREIGN KEY (nombre_planeta) REFERENCES planetas_sistema_solar_limpio(nombre_planeta);

-- Si no existe la columna tierra_id, la creas
ALTER TABLE planetas_sistema_solar_limpio
ADD COLUMN tierra_id INT;

-- Asignar valor 1 a todos (referencia a la Tierra)
UPDATE planetas_sistema_solar_limpio
SET tierra_id = 1;

-- Crear la FK
ALTER TABLE planetas_sistema_solar_limpio
ADD CONSTRAINT fk_planeta_tierra
FOREIGN KEY (tierra_id) REFERENCES referencia_tierra(id);

-- Unión de la Tierra con los Planetas del Sistema Solar

ALTER TABLE tierra
ADD COLUMN id_tierra INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE planetas_sistema_solar_limpio
ADD COLUMN tierra_id INT;

UPDATE planetas_sistema_solar_limpio
SET tierra_id = 1;

-- Crear la relación Planetas ↔ Tierra
ALTER TABLE planetas_sistema_solar_limpio
ADD CONSTRAINT fk_planeta_tierra
FOREIGN KEY (tierra_id) REFERENCES tierra(id_tierra);

-- Exoplanetas - Tierra

ALTER TABLE exoplanetas_final
ADD COLUMN tierra_id INT;

-- Asignar valor de la Tierra (suponiendo un único registro)
UPDATE exoplanetas_final
SET tierra_id = 1;

-- Crear FK
ALTER TABLE exoplanetas_final
ADD CONSTRAINT fk_exo_tierra
FOREIGN KEY (tierra_id) REFERENCES tierra(id_tierra);

-- Unión Estrellas - Sol

ALTER TABLE estrellas_exoplanetas
ADD CONSTRAINT fk_star_sol
FOREIGN KEY (sol_id) REFERENCES sol(sol_id);

ALTER TABLE sol
ADD UNIQUE (sol_id);

UPDATE estrellas_exoplanetas
SET sol_id = 1;

SELECT
    CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE
    TABLE_SCHEMA = 'espacio' -- cambia al nombre de tu base de datos
    AND TABLE_NAME = 'exoplanetas_final';

ALTER TABLE exoplanetas_final
DROP FOREIGN KEY fk_exo_star;
