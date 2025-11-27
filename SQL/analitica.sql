-- ============================================================
-- SCRIPT DDL/DML - CANDEY ANALÍTICA (DATA WAREHOUSE)
-- Modelo: Esquema Estrella
-- Motor: PostgreSQL 15
-- ============================================================

-- 1. LIMPIEZA (Borrar tablas en orden inverso)
DROP TABLE IF EXISTS Hecho_Movimientos CASCADE;
DROP TABLE IF EXISTS Dim_Tiempo CASCADE;
DROP TABLE IF EXISTS Dim_Producto CASCADE;
DROP TABLE IF EXISTS Dim_Proveedor CASCADE;
DROP TABLE IF EXISTS Dim_Usuario CASCADE;
DROP TABLE IF EXISTS Dim_Tipo_Movimiento CASCADE;

-- ============================================================
-- 2. CREACIÓN Y CARGA DE DIMENSIONES
-- ============================================================

-- --- DIMENSIÓN TIEMPO ---
CREATE TABLE Dim_Tiempo (
    sk_tiempo SERIAL PRIMARY KEY,
    fecha_completa DATE NOT NULL,
    anio INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    nombre_mes VARCHAR(20) NOT NULL,
    dia_semana VARCHAR(20) NOT NULL,
    es_fin_semana BOOLEAN NOT NULL
);

-- Carga masiva de fechas para todo el año 2025 (Usando función de Postgres)
INSERT INTO Dim_Tiempo (fecha_completa, anio, mes, nombre_mes, dia_semana, es_fin_semana)
SELECT
    datum as fecha_completa,
    EXTRACT(YEAR FROM datum) as anio,
    EXTRACT(MONTH FROM datum) as mes,
    TO_CHAR(datum, 'TMMonth') as nombre_mes,
    TO_CHAR(datum, 'TMDay') as dia_semana,
    CASE WHEN EXTRACT(ISODOW FROM datum) IN (6, 7) THEN TRUE ELSE FALSE END as es_fin_semana
FROM generate_series('2025-01-01'::DATE, '2025-12-31'::DATE, '1 day'::interval) as datum;


-- --- DIMENSIÓN USUARIO ---
CREATE TABLE Dim_Usuario (
    sk_usuario SERIAL PRIMARY KEY,
    id_usuario_original INTEGER, -- ID del sistema transaccional
    nombre_completo VARCHAR(100),
    rol VARCHAR(50)
);

INSERT INTO Dim_Usuario (id_usuario_original, nombre_completo, rol) VALUES
(1, 'Maveth Moran', 'Administrador');


-- --- DIMENSIÓN PROVEEDOR ---
CREATE TABLE Dim_Proveedor (
    sk_proveedor SERIAL PRIMARY KEY,
    id_proveedor_original INTEGER,
    nombre_empresa VARCHAR(100)
);

-- Insertamos el registro "0" para manejar las Ventas (donde no hay proveedor)
INSERT INTO Dim_Proveedor (sk_proveedor, id_proveedor_original, nombre_empresa) VALUES
(0, 0, 'No Aplica / Cliente Final'); -- ID 0

-- Insertamos los proveedores reales
INSERT INTO Dim_Proveedor (id_proveedor_original, nombre_empresa) VALUES
(1, 'Cosméticos Perú S.A.C.'),
(2, 'Importaciones Bella'),
(3, 'Distribuidora Makeup Lima'),
(4, 'Glow Suppliers'),
(5, 'Beauty Wholesalers');


-- --- DIMENSIÓN PRODUCTO ---
CREATE TABLE Dim_Producto (
    sk_producto SERIAL PRIMARY KEY,
    id_producto_original INTEGER,
    nombre_producto VARCHAR(100),
    categoria_simulada VARCHAR(50), -- Agregado para Power BI
    precio_actual DECIMAL(10, 2)
);

INSERT INTO Dim_Producto (id_producto_original, nombre_producto, categoria_simulada, precio_actual) VALUES
(1, 'Labial Matte Rojo', 'Labios', 25.00),
(2, 'Labial Nude Velvet', 'Labios', 25.00),
(3, 'Base Líquida Tono 1', 'Rostro', 45.00),
(4, 'Base Líquida Tono 2', 'Rostro', 45.00),
(5, 'Rímel Volumen X', 'Ojos', 32.00),
(6, 'Delineador Plumón', 'Ojos', 20.00),
(7, 'Paleta Sombras 12 Col', 'Ojos', 65.00),
(8, 'Polvo Traslúcido', 'Rostro', 30.00),
(9, 'Set Brochas Básico', 'Accesorios', 40.00),
(10, 'Iluminador Gold', 'Rostro', 28.00),
(11, 'Corrector Líquido', 'Rostro', 24.00),
(12, 'Fijador Maquillaje', 'Rostro', 35.00);


-- --- DIMENSIÓN TIPO MOVIMIENTO ---
CREATE TABLE Dim_Tipo_Movimiento (
    sk_tipo SERIAL PRIMARY KEY,
    descripcion VARCHAR(20) -- 'INGRESO' o 'SALIDA'
);

INSERT INTO Dim_Tipo_Movimiento (descripcion) VALUES ('INGRESO'), ('SALIDA'), ('MERMA');


-- ============================================================
-- 3. CREACIÓN Y CARGA DE LA TABLA DE HECHOS
-- ============================================================

CREATE TABLE Hecho_Movimientos (
    id_hecho SERIAL PRIMARY KEY,
    sk_tiempo INTEGER REFERENCES Dim_Tiempo(sk_tiempo),
    sk_producto INTEGER REFERENCES Dim_Producto(sk_producto),
    sk_proveedor INTEGER REFERENCES Dim_Proveedor(sk_proveedor),
    sk_usuario INTEGER REFERENCES Dim_Usuario(sk_usuario),
    sk_tipo INTEGER REFERENCES Dim_Tipo_Movimiento(sk_tipo),
    cantidad INTEGER,
    monto_total DECIMAL(10,2)
);

-- ============================================================
-- CORRECCIÓN: CARGA DE LA TABLA DE HECHOS (Hecho_Movimientos)
-- ============================================================

-- Limpiamos la tabla de hechos por si quedó algo a medias
TRUNCATE TABLE Hecho_Movimientos RESTART IDENTITY;

-- A. CARGA DE COMPRAS (INGRESOS)
-- Corrección: En la línea de 'Brochas', cambié el proveedor 6 por 5.
INSERT INTO Hecho_Movimientos (sk_tiempo, sk_producto, sk_proveedor, sk_usuario, sk_tipo, cantidad, monto_total) VALUES
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-01'), 1, 2, 1, 1, 50, 625.00), -- Labial Rojo
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-01'), 2, 2, 1, 1, 40, 500.00), -- Labial Nude
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-02'), 3, 3, 1, 1, 20, 500.00), -- Base 1
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-02'), 4, 3, 1, 1, 15, 375.00), -- Base 2
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-03'), 5, 4, 1, 1, 30, 540.00), -- Rimel
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-03'), 6, 4, 1, 1, 60, 600.00), -- Delineador
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-04'), 7, 5, 1, 1, 10, 350.00), -- Paleta
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-05'), 9, 5, 1, 1, 12, 240.00), -- Brochas (CORREGIDO: Proveedor 5)
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-05'), 11, 2, 1, 1, 30, 360.00), -- Corrector
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-20'), 4, 3, 1, 1, 5, 125.00);  -- Reposición Base

-- B. CARGA DE VENTAS (SALIDAS)
INSERT INTO Hecho_Movimientos (sk_tiempo, sk_producto, sk_proveedor, sk_usuario, sk_tipo, cantidad, monto_total) VALUES
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-06'), 1, 0, 1, 2, 2, 50.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-06'), 2, 0, 1, 2, 1, 25.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-06'), 6, 0, 1, 2, 5, 100.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-07'), 3, 0, 1, 2, 2, 90.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-07'), 4, 0, 1, 2, 3, 135.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-07'), 7, 0, 1, 2, 1, 65.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-08'), 8, 0, 1, 2, 2, 60.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-08'), 11, 0, 1, 2, 2, 48.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-10'), 12, 0, 1, 2, 3, 105.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-12'), 9, 0, 1, 2, 1, 40.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-12'), 4, 0, 1, 2, 4, 180.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-13'), 6, 0, 1, 2, 3, 60.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-14'), 7, 0, 1, 2, 2, 130.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-17'), 4, 0, 1, 2, 5, 225.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-18'), 1, 0, 1, 2, 3, 75.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-24'), 7, 0, 1, 2, 1, 65.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-26'), 7, 0, 1, 2, 4, 260.00);

-- C. CARGA DE MERMAS (SALIDAS)
INSERT INTO Hecho_Movimientos (sk_tiempo, sk_producto, sk_proveedor, sk_usuario, sk_tipo, cantidad, monto_total) VALUES
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-15'), 4, 0, 1, 3, 2, 0.00),
((SELECT sk_tiempo FROM Dim_Tiempo WHERE fecha_completa = '2025-11-20'), 8, 0, 1, 3, 3, 0.00);

-- ============================================================
-- VERIFICACIÓN
-- ============================================================
-- SELECT * FROM Hecho_Movimientos;