-- Vista para resumen de movimientos
CREATE OR REPLACE VIEW vista_resumen_movimientos AS
SELECT 
    m.idMovimiento,
    m.fecha,
    m.tipo,
    m.monto,
    m.descripcion,
    u.nombre AS nombreUsuario,
    c.nombre AS nombreCategoria,
    cu.nombre AS nombreCuenta,
    mp.nombre AS metodoPago
FROM Movimiento m
INNER JOIN Usuario u ON m.idUsuario = u.idUsuario
INNER JOIN Categoria c ON m.idCategoria = c.idCategoria
INNER JOIN Cuenta cu ON m.idCuenta = cu.idCuenta
INNER JOIN MetodoPago mp ON m.idMetodoPago = mp.idMetodoPago;

-- Vista para control de presupuestos
CREATE OR REPLACE VIEW vista_control_presupuestos AS
SELECT 
    p.idPresupuesto,
    p.nombre,
    p.montoMaximo,
    p.periodo,
    p.fechaInicio,
    p.fechaFin,
    c.nombre AS categoria,
    NVL(SUM(m.monto), 0) AS gastoActual,
    (p.montoMaximo - NVL(SUM(m.monto), 0)) AS disponible,
    ROUND((NVL(SUM(m.monto), 0) / p.montoMaximo * 100), 2) AS porcentajeUsado
FROM Presupuesto p
INNER JOIN Categoria c ON p.idCategoria = c.idCategoria
LEFT JOIN Movimiento m ON m.idCategoria = c.idCategoria 
    AND m.tipo = 'EGRESO'
    AND m.fecha BETWEEN p.fechaInicio AND p.fechaFin
GROUP BY p.idPresupuesto, p.nombre, p.montoMaximo, p.periodo, p.fechaInicio, p.fechaFin, c.nombre;
