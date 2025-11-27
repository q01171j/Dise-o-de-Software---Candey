-- ============================================================
-- SCRIPT COMPLETO: CANDEY COSMÉTICOS (TRANSACCIONAL)
-- Motor: PostgreSQL 15
-- Autor: Equipo de Desarrollo Candey
-- ============================================================

-- 1. LIMPIEZA INICIAL (Borrar todo si existe para evitar errores)
DROP TABLE IF EXISTS Movimiento CASCADE;
DROP TABLE IF EXISTS Productos CASCADE;
DROP TABLE IF EXISTS Proveedores CASCADE;
DROP TABLE IF EXISTS Usuarios CASCADE;

-- 2. CREACIÓN DE TABLAS (DDL)

-- Tabla USUARIOS
CREATE TABLE Usuarios (
    id_usu SERIAL PRIMARY KEY,
    nombre_usu VARCHAR(100) NOT NULL,
    correo_usu VARCHAR(100) NOT NULL UNIQUE,
    contra_usu VARCHAR(100) NOT NULL
);

-- Tabla PROVEEDORES
CREATE TABLE Proveedores (
    id_prove SERIAL PRIMARY KEY,
    nombre_prove VARCHAR(100) NOT NULL,
    contacto_prove VARCHAR(100) NOT NULL,
    numero_prove VARCHAR(9) NOT NULL
);

-- Tabla PRODUCTOS
CREATE TABLE Productos (
    id_pro SERIAL PRIMARY KEY,
    cod_pro VARCHAR(10) NOT NULL UNIQUE,
    nombre_pro VARCHAR(100) NOT NULL,
    descripcion_pro VARCHAR(150) NOT NULL,
    costo_pro DECIMAL(10, 2) NOT NULL,
    precio_pro DECIMAL(10, 2) NOT NULL,
    stock_min_pro INTEGER NOT NULL,
    stock_act_pro INTEGER NOT NULL DEFAULT 0 -- Se actualizará con los movimientos
);

-- Tabla MOVIMIENTO
CREATE TABLE Movimiento (
    id_movi SERIAL PRIMARY KEY,
    id_pro INTEGER NOT NULL,
    id_prove INTEGER NULL, -- NULL si es Salida (Venta)
    id_usu INTEGER NOT NULL,
    fecha_hora_movi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_movi BOOLEAN NOT NULL, -- TRUE = Ingreso, FALSE = Salida
    cantidad INTEGER NOT NULL,
    costo_total_movi DECIMAL(10, 2) NOT NULL, -- En ingreso es costo compra, en salida es precio venta total
    nota VARCHAR(150),
    
    CONSTRAINT fk_producto FOREIGN KEY (id_pro) REFERENCES Productos(id_pro),
    CONSTRAINT fk_proveedor FOREIGN KEY (id_prove) REFERENCES Proveedores(id_prove),
    CONSTRAINT fk_usuario FOREIGN KEY (id_usu) REFERENCES Usuarios(id_usu)
);

-- ============================================================
-- CARGA DE DATOS (DML) - +50 REGISTROS
-- ============================================================

-- 1. USUARIO (Solo Maveth)
INSERT INTO Usuarios (nombre_usu, correo_usu, contra_usu) VALUES 
('Maveth Moran', 'maveth@candey.com', 'admin123');

-- 2. PROVEEDORES (5 Registros)
INSERT INTO Proveedores (nombre_prove, contacto_prove, numero_prove) VALUES 
('Cosméticos Perú S.A.C.', 'Juan Pérez', '999888777'),
('Importaciones Bella', 'Maria Lopez', '987654321'),
('Distribuidora Makeup Lima', 'Carlos Ruiz', '955444333'),
('Glow Suppliers', 'Ana Torres', '911222333'),
('Beauty Wholesalers', 'Luis Gomez', '966777888');

-- 3. PRODUCTOS (12 Registros)
-- Nota: Insertamos con stock inicial 0, la lógica es que los movimientos de ingreso llenan el stock real.
-- Aquí ponemos el stock FINAL calculado tras los movimientos de abajo para que coincida.
INSERT INTO Productos (cod_pro, nombre_pro, descripcion_pro, costo_pro, precio_pro, stock_min_pro, stock_act_pro) VALUES 
('LAB-R01', 'Labial Matte Rojo', 'Labial larga duración rojo intenso', 12.50, 25.00, 10, 41),
('LAB-N02', 'Labial Nude Velvet', 'Tono natural acabado aterciopelado', 12.50, 25.00, 10, 35),
('BAS-L01', 'Base Líquida Tono 1', 'Cobertura media piel clara', 25.00, 45.00, 5, 15),
('BAS-L02', 'Base Líquida Tono 2', 'Cobertura media piel media', 25.00, 45.00, 5, 4), -- STOCK BAJO (Alerta)
('RIM-X01', 'Rímel Volumen X', 'Máscara a prueba de agua', 18.00, 32.00, 8, 22),
('DEL-P01', 'Delineador Plumón', 'Punta fina negro intenso', 10.00, 20.00, 15, 48),
('SOM-P12', 'Paleta Sombras 12 Col', 'Tonos tierra y brillantes', 35.00, 65.00, 3, 7),
('POL-T01', 'Polvo Traslúcido', 'Matificante todo tipo piel', 15.00, 30.00, 5, 14),
('BRO-SET', 'Set Brochas Básico', 'Kit 5 brochas sintéticas', 20.00, 40.00, 4, 8),
('ILU-G01', 'Iluminador Gold', 'Polvo compacto dorado', 14.00, 28.00, 6, 18),
('COR-L01', 'Corrector Líquido', 'Alta cobertura ojeras', 12.00, 24.00, 8, 25),
('FIJ-M01', 'Fijador Maquillaje', 'Spray larga duración 100ml', 18.00, 35.00, 5, 10);

-- 4. MOVIMIENTOS (50 Registros: 15 Ingresos + 35 Salidas)

-- BLOQUE A: INGRESOS DE MERCADERÍA (COMPRAS) - Noviembre Inicio
INSERT INTO Movimiento (id_pro, id_prove, id_usu, fecha_hora_movi, tipo_movi, cantidad, costo_total_movi, nota) VALUES 
(1, 1, 1, '2025-11-01 09:00:00', TRUE, 50, 625.00, 'Compra inicial Labiales Rojos'),
(2, 1, 1, '2025-11-01 09:05:00', TRUE, 40, 500.00, 'Compra inicial Labiales Nude'),
(3, 2, 1, '2025-11-02 10:00:00', TRUE, 20, 500.00, 'Stock Bases T1'),
(4, 2, 1, '2025-11-02 10:05:00', TRUE, 15, 375.00, 'Stock Bases T2'),
(5, 3, 1, '2025-11-03 11:00:00', TRUE, 30, 540.00, 'Ingreso Rímel'),
(6, 3, 1, '2025-11-03 11:15:00', TRUE, 60, 600.00, 'Promo Delineadores'),
(7, 4, 1, '2025-11-04 14:00:00', TRUE, 10, 350.00, 'Paletas nuevas'),
(8, 4, 1, '2025-11-04 14:10:00', TRUE, 20, 300.00, 'Polvos compactos'),
(9, 5, 1, '2025-11-05 09:00:00', TRUE, 12, 240.00, 'Set Brochas'),
(10, 5, 1, '2025-11-05 09:15:00', TRUE, 20, 280.00, 'Iluminadores'),
(11, 1, 1, '2025-11-05 10:00:00', TRUE, 30, 360.00, 'Correctores'),
(12, 2, 1, '2025-11-05 10:30:00', TRUE, 15, 270.00, 'Fijadores'),
(4, 2, 1, '2025-11-20 08:00:00', TRUE, 5, 125.00, 'Reposición urgente Base T2'), -- Recompra
(7, 4, 1, '2025-11-22 15:00:00', TRUE, 5, 175.00, 'Reposición Paletas'),
(3, 2, 1, '2025-11-23 09:00:00', TRUE, 5, 125.00, 'Reposición Base T1');

-- BLOQUE B: SALIDAS (VENTAS DIARIAS) - A lo largo de Noviembre
-- id_prove es NULL porque es venta al público
INSERT INTO Movimiento (id_pro, id_prove, id_usu, fecha_hora_movi, tipo_movi, cantidad, costo_total_movi, nota) VALUES 
-- Semana 1
(1, NULL, 1, '2025-11-06 10:00:00', FALSE, 2, 50.00, 'Venta boleta 001'),
(2, NULL, 1, '2025-11-06 11:30:00', FALSE, 1, 25.00, 'Venta boleta 002'),
(5, NULL, 1, '2025-11-06 12:15:00', FALSE, 2, 64.00, 'Venta boleta 003'),
(6, NULL, 1, '2025-11-06 16:00:00', FALSE, 5, 100.00, 'Venta mayorista delineador'),
(3, NULL, 1, '2025-11-07 09:30:00', FALSE, 2, 90.00, 'Cliente frecuente'),
(4, NULL, 1, '2025-11-07 10:45:00', FALSE, 3, 135.00, 'Venta mostrador'),
(7, NULL, 1, '2025-11-07 15:20:00', FALSE, 1, 65.00, 'Regalo cumpleaños'),
(8, NULL, 1, '2025-11-08 11:00:00', FALSE, 2, 60.00, 'Venta boleta 008'),
(10, NULL, 1, '2025-11-08 14:30:00', FALSE, 1, 28.00, 'Venta rápida'),
(11, NULL, 1, '2025-11-08 17:00:00', FALSE, 2, 48.00, 'Corrector x2'),

-- Semana 2
(12, NULL, 1, '2025-11-10 10:00:00', FALSE, 3, 105.00, 'Promo fijadores'),
(1, NULL, 1, '2025-11-10 12:30:00', FALSE, 1, 25.00, 'Venta unitaria'),
(2, NULL, 1, '2025-11-11 16:00:00', FALSE, 2, 50.00, 'Venta boleta 012'),
(9, NULL, 1, '2025-11-12 09:45:00', FALSE, 1, 40.00, 'Set brochas'),
(4, NULL, 1, '2025-11-12 13:20:00', FALSE, 4, 180.00, 'Venta grande bases'),
(3, NULL, 1, '2025-11-13 11:00:00', FALSE, 1, 45.00, 'Venta boleta 015'),
(6, NULL, 1, '2025-11-13 15:40:00', FALSE, 3, 60.00, 'Delineadores'),
(5, NULL, 1, '2025-11-14 10:10:00', FALSE, 2, 64.00, 'Venta rímel'),
(7, NULL, 1, '2025-11-14 18:00:00', FALSE, 2, 130.00, 'Sombras x2'),
(8, NULL, 1, '2025-11-15 12:00:00', FALSE, 1, 30.00, 'Polvo traslúcido'),

-- Semana 3
(4, NULL, 1, '2025-11-17 09:15:00', FALSE, 5, 225.00, 'Venta bases stock antiguo'),
(1, NULL, 1, '2025-11-17 11:30:00', FALSE, 3, 75.00, 'Venta labiales rojos'),
(2, NULL, 1, '2025-11-18 14:00:00', FALSE, 1, 25.00, 'Venta boleta 022'),
(11, NULL, 1, '2025-11-18 16:45:00', FALSE, 2, 48.00, 'Corrector'),
(9, NULL, 1, '2025-11-19 10:00:00', FALSE, 2, 80.00, 'Brochas para curso'),
(12, NULL, 1, '2025-11-19 13:30:00', FALSE, 1, 35.00, 'Fijador'),
(3, NULL, 1, '2025-11-20 15:00:00', FALSE, 3, 135.00, 'Venta boleta 026'),
(6, NULL, 1, '2025-11-21 11:20:00', FALSE, 2, 40.00, 'Venta boleta 027'),
(5, NULL, 1, '2025-11-21 17:50:00', FALSE, 1, 32.00, 'Rímel'),
(10, NULL, 1, '2025-11-22 10:00:00', FALSE, 1, 28.00, 'Iluminador'),

-- Semana 4 (Cierre mes)
(7, NULL, 1, '2025-11-24 09:30:00', FALSE, 1, 65.00, 'Venta Paleta'),
(4, NULL, 1, '2025-11-24 12:00:00', FALSE, 2, 90.00, 'Venta Bases T2'),
(1, NULL, 1, '2025-11-25 14:15:00', FALSE, 2, 50.00, 'Venta Labiales'),
(9, NULL, 1, '2025-11-25 16:00:00', FALSE, 1, 40.00, 'Venta Brocha'),
(7, NULL, 1, '2025-11-26 10:00:00', FALSE, 4, 260.00, 'Venta Paletas (Black Friday)');

-- BLOQUE C: SALIDAS POR MERMA/USO INTERNO (3 Registros)
INSERT INTO Movimiento (id_pro, id_prove, id_usu, fecha_hora_movi, tipo_movi, cantidad, costo_total_movi, nota) VALUES 
(4, NULL, 1, '2025-11-15 09:00:00', FALSE, 2, 0.00, 'MERMA: Base rota en almacén'),
(6, NULL, 1, '2025-11-18 14:00:00', FALSE, 2, 0.00, 'USO INTERNO: Muestras mostrador'),
(8, NULL, 1, '2025-11-20 16:30:00', FALSE, 3, 0.00, 'MERMA: Polvos vencidos/dañados');

-- ============================================================
-- VERIFICACIÓN RÁPIDA
-- ============================================================
-- SELECT * FROM Productos; -- Revisar Stock final
-- SELECT COUNT(*) FROM Movimiento; -- Debería dar 53 registros