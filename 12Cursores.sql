-- =====================================================
-- PAQUETE: PKG_CONSULTAS_FINANCIERAS
-- Contiene procedimientos para consultas desde apps externas
-- =====================================================

CREATE OR REPLACE PACKAGE PKG_CONSULTAS_FINANCIERAS AS
  
  -- Tipo de cursor de referencia para devolver resultados
  TYPE t_cursor IS REF CURSOR;
  
  -- Procedimiento: Obtener los 10 movimientos más recientes
  PROCEDURE sp_movimientos_recientes(
    p_cursor OUT t_cursor
  );
  
  -- Procedimiento: Obtener todos los movimientos de una cuenta
  PROCEDURE sp_movimientos_cuenta(
    p_idCuenta IN NUMBER,
    p_cursor OUT t_cursor
  );
  
  -- Procedimiento: Obtener categorías que exceden presupuesto
  PROCEDURE sp_categorias_excedidas(
    p_fecha IN DATE DEFAULT SYSDATE,
    p_cursor OUT t_cursor
  );
  
  -- Procedimiento: Resumen de egresos por mes
  PROCEDURE sp_resumen_egresos(
    p_mes IN NUMBER,
    p_anio IN NUMBER,
    p_cursor OUT t_cursor
  );
  
  -- Procedimiento: Cuentas con saldo negativo
  PROCEDURE sp_cuentas_negativas(
    p_cursor OUT t_cursor
  );
  
END PKG_CONSULTAS_FINANCIERAS;
/

-- =====================================================
-- CUERPO DEL PAQUETE
-- =====================================================

CREATE OR REPLACE PACKAGE BODY PKG_CONSULTAS_FINANCIERAS AS

  -- Obtener los 10 movimientos más recientes
  PROCEDURE sp_movimientos_recientes(
    p_cursor OUT t_cursor
  ) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT 
        m.idMovimiento,
        c.nombre AS cuenta,
        m.tipo,
        m.monto,
        m.fecha,
        m.descripcion
      FROM Movimiento m
      JOIN Cuenta c ON m.idCuenta = c.idCuenta
      ORDER BY m.fecha DESC 
      FETCH FIRST 10 ROWS ONLY;
  END sp_movimientos_recientes;

  -- Obtener todos los movimientos de una cuenta específica
  PROCEDURE sp_movimientos_cuenta(
    p_idCuenta IN NUMBER,
    p_cursor OUT t_cursor
  ) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT 
        m.idMovimiento,
        m.fecha,
        m.tipo,
        m.monto,
        m.descripcion,
        NVL(cat.nombre, '(Sin categoría)') AS categoria,
        NVL(mp.nombre, '(Sin método)') AS metodo
      FROM Movimiento m
      LEFT JOIN Categoria cat ON m.idCategoria = cat.idCategoria
      LEFT JOIN MetodoPago mp ON m.idMetodoPago = mp.idMetodoPago
      WHERE m.idCuenta = p_idCuenta
      ORDER BY m.fecha DESC;
  END sp_movimientos_cuenta;

  -- Obtener categorías que exceden su presupuesto
  PROCEDURE sp_categorias_excedidas(
    p_fecha IN DATE DEFAULT SYSDATE,
    p_cursor OUT t_cursor
  ) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT 
        p.idPresupuesto,
        c.nombre AS categoria,
        p.montoMaximo,
        NVL(SUM(m.monto), 0) AS totalGasto,
        ROUND((NVL(SUM(m.monto), 0) / p.montoMaximo) * 100, 2) AS porcentajeExcedido
      FROM Presupuesto p
      JOIN Categoria c ON p.idCategoria = c.idCategoria
      LEFT JOIN Movimiento m ON m.idCategoria = p.idCategoria 
           AND m.tipo = 'EGRESO'
           AND m.fecha BETWEEN p.fechaInicio AND NVL(p.fechaFin, p_fecha)
      WHERE p.fechaFin >= p_fecha
      GROUP BY p.idPresupuesto, c.nombre, p.montoMaximo
      HAVING NVL(SUM(m.monto), 0) > p.montoMaximo
      ORDER BY totalGasto DESC;
  END sp_categorias_excedidas;

  -- Obtener resumen de egresos por mes y año
  PROCEDURE sp_resumen_egresos(
    p_mes IN NUMBER,
    p_anio IN NUMBER,
    p_cursor OUT t_cursor
  ) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT 
        c.idCategoria,
        c.nombre AS categoria,
        SUM(m.monto) AS total,
        COUNT(*) AS cantidadMovimientos
      FROM Movimiento m
      JOIN Categoria c ON m.idCategoria = c.idCategoria
      WHERE m.tipo = 'EGRESO'
        AND EXTRACT(MONTH FROM m.fecha) = p_mes
        AND EXTRACT(YEAR FROM m.fecha) = p_anio
      GROUP BY c.idCategoria, c.nombre
      ORDER BY total DESC;
  END sp_resumen_egresos;

  -- Obtener cuentas con saldo negativo
  PROCEDURE sp_cuentas_negativas(
    p_cursor OUT t_cursor
  ) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT 
        idCuenta,
        nombre,
        tipo,
        saldoActual,
        ABS(saldoActual) AS deuda
      FROM Cuenta
      WHERE saldoActual < 0
      ORDER BY saldoActual ASC;
  END sp_cuentas_negativas;

END PKG_CONSULTAS_FINANCIERAS;
/