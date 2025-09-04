USE proyectoLlaveros
GO

-------------------------------------------------
-- BLOQUE 1: CREACIÓN DE TABLA Y CARGA DE DATOS
-------------------------------------------------

CREATE TABLE VentasLlaveros (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE,
    Producto VARCHAR(50),
    Cantidad INT,
    Precio_Unitario DECIMAL(10,2),
    Costo_Unitario DECIMAL(10,2),
    IdCliente INT,  -- columna agregada para el JOIN
    Total AS (Cantidad * Precio_Unitario) PERSISTED,
    Margen AS ((Cantidad * Precio_Unitario) - (Cantidad * Costo_Unitario)) PERSISTED
);

-- Insertamos datos de ejemplo

INSERT INTO VentasLlaveros (Fecha, Producto, Cantidad, Precio_Unitario, Costo_Unitario)
VALUES
('2024-07-01', 'Pollo', 5, 3, 1.5),
('2024-07-01', 'Ballena', 3, 4, 2),
('2024-07-02', 'Pollo', 4, 3, 1.5),
('2024-07-02', 'Ballena', 2, 4, 2),
('2024-07-03', 'Gato', 6, 5, 2.5),
('2024-07-03', 'Pollo', 3, 3, 1.5);

-------------------------------------------------
-- BLOQUE 2: CONSULTAS DE ANÁLISIS
-------------------------------------------------

-- Ventas totales por producto
SELECT 
    Producto,
    SUM(Cantidad) AS Total_Cantidad,
    SUM(Total) AS Total_Ventas,
    SUM(Margen) AS Total_Margen
FROM VentasLlaveros
GROUP BY Producto
ORDER BY Total_Ventas DESC;

-- Días con mayor cantidad de ventas
SELECT Fecha,
       SUM(Cantidad) AS Total_Cantidad,
       SUM(Total) AS Total_Ventas
FROM VentasLlaveros
GROUP BY Fecha
ORDER BY Total_Ventas DESC;

-- Producto más rentable
SELECT TOP 1 Producto,
       SUM(Margen) AS Margen_Total
FROM VentasLlaveros
GROUP BY Producto
ORDER BY Margen_Total DESC;

-- Ticket promedio de venta
SELECT AVG(Total) AS Ticket_Promedio
FROM VentasLlaveros;

-------------------------------------------------
-- BLOQUE 3: CREACIÓN TABLA CLIENTES PARA JOIN
-------------------------------------------------

CREATE TABLE Clientes (
    IdCliente INT PRIMARY KEY,
    Nombre VARCHAR(50)
);

-- Insertamos datos de ejemplo
INSERT INTO Clientes (IdCliente, Nombre)
VALUES
(1, 'Cliente A'),
(2, 'Cliente B'),
(3, 'Cliente C');

-------------------------------------------------
-- BLOQUE 4: ASIGNAR IdCliente EN VENTASLLAVEROS
-------------------------------------------------

UPDATE VentasLlaveros
SET IdCliente = CASE 
    WHEN Producto = 'Pollo' THEN 1
    WHEN Producto = 'Ballena' THEN 2
    WHEN Producto = 'Gato' THEN 3
END;

-------------------------------------------------
-- BLOQUE 5: JOIN ENTRE VENTAS Y CLIENTES
-------------------------------------------------

SELECT 
    V.Fecha,
    V.Producto,
    V.Cantidad,
    V.Precio_Unitario,
    V.Total,
    V.Margen,
    C.Nombre AS Cliente
FROM VentasLlaveros V
INNER JOIN Clientes C
    ON V.IdCliente = C.IdCliente
ORDER BY V.Total DESC;
