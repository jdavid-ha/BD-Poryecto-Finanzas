
-- =====================================================
-- SCRIPT DE PRUEBAS COMPLETO
-- Sistema de Gestión Financiera Personal
-- =====================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;

PROMPT ═════════════════════════════════════════════════════════
PROMPT     INICIANDO PRUEBAS DEL SISTEMA
PROMPT ═════════════════════════════════════════════════════════

-- =====================================================
-- SECCIÓN 1: PRUEBAS DE FUNCIONES
-- =====================================================

PROMPT 
PROMPT ══════════════════════════════════════════════════════════
PROMPT SECCIÓN 1: PRUEBAS DE FUNCIONES
PROMPT ══════════════════════════════════════════════════════════

PROMPT 
PROMPT ► Prueba 1.1: Obtener saldo de cuenta
PROMPT ────────────────────────────────────────

DECLARE
    v_saldo NUMBER;
BEGIN
    v_saldo := FN_OBTENER_SALDO_CUENTA(1);
    DBMS_OUTPUT.PUT_LINE('Saldo de cuenta ID 1: $' || TO_CHAR(v_saldo, '999,999,999.99'));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

PROMPT 
PROMPT ► Prueba 1.2: Calcular total gastado en categoría
PROMPT ────────────────────────────────────────

DECLARE
    v_total NUMBER;
    v_fecha_inicio DATE := TRUNC(SYSDATE, 'MM');
    v_fecha_fin DATE := LAST_DAY(SYSDATE);
BEGIN
    v_total := FN_TOTAL_GASTADO_CATEGORIA(1, v_fecha_inicio, v_fecha_fin);
    DBMS_OUTPUT.PUT_LINE('Total gastado en categoría ID 1 este mes: $' || 
        TO_CHAR(v_total, '999,999,999.99'));
END;
/

PROMPT 
PROMPT ► Prueba 1.3: Balance mensual de cuenta
PROMPT ────────────────────────────────────────

DECLARE
    v_balance NUMBER;
    v_mes NUMBER := EXTRACT(MONTH FROM SYSDATE);
    v_anio NUMBER := EXTRACT(YEAR FROM SYSDATE);
BEGIN
    v_balance := FN_BALANCE_MENSUAL(1, v_mes, v_anio);
    DBMS_OUTPUT.PUT_LINE('Balance mensual de cuenta ID 1: $' || 
        TO_CHAR(v_balance, '999,999,999.99'));
END;
/

-- =====================================================
-- SECCIÓN 2: PRUEBAS DE PROCEDIMIENTOS
-- =====================================================

PROMPT 
PROMPT ══════════════════════════════════════════════════════════
PROMPT SECCIÓN 2: PRUEBAS DE PROCEDIMIENTOS
PROMPT ══════════════════════════════════════════════════════════

PROMPT 
PROMPT ► Prueba 2.1: Crear nuevo usuario
PROMPT ────────────────────────────────────────

BEGIN
    SP_CREAR_USUARIO(
        p_nombre => 'Juan Pérez',
        p_email => 'juan.perez@email.com',
        p_password => 'password123'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

PROMPT 
PROMPT ► Prueba 2.2: Registrar movimiento - INGRESO
PROMPT ────────────────────────────────────────

BEGIN
    SP_REGISTRAR_MOVIMIENTO(
        p_id_usuario => 1,
        p_id_categoria => 3,  -- Salario
        p_id_cuenta => 1,
        p_id_metodo_pago => 4,  -- Transferencia
        p_monto => 5000000,
        p_tipo => 'INGRESO',
        p_descripcion => 'Salario mensual - Noviembre 2024'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

PROMPT 
PROMPT ► Prueba 2.3: Registrar movimiento - EGRESO
PROMPT ────────────────────────────────────────

BEGIN
    SP_REGISTRAR_MOVIMIENTO(
        p_id_usuario => 1,
        p_id_categoria => 1,  -- Alimentación
        p_id_cuenta => 1,
        p_id_metodo_pago => 2,  -- Tarjeta Débito
        p_monto => 350000,
        p_tipo => 'EGRESO',
        p_descripcion => 'Compra supermercado'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

PROMPT 
PROMPT ► Prueba 2.4: Crear presupuesto
PROMPT ────────────────────────────────────────

BEGIN
    SP_CREAR_PRESUPUESTO(
        p_id_categoria => 1,  -- Alimentación
        p_nombre => 'Presupuesto Alimentación Noviembre',
        p_monto_maximo => 800000,
        p_periodo => 'MENSUAL',
        p_fecha_inicio => TRUNC(SYSDATE, 'MM'),
        p_fecha_fin => LAST_DAY(SYSDATE)
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

PROMPT 
PROMPT ► Prueba 2.5: Transferencia entre cuentas
PROMPT ────────────────────────────────────────

BEGIN
    SP_TRANSFERIR_ENTRE_CUENTAS(
        p_id_usuario => 1,
        p_cuenta_origen => 1,
        p_cuenta_destino => 2,
        p_monto => 500000,
        p_id_categoria => 1,
        p_id_metodo_pago => 4,
        p_descripcion => 'Pago tarjeta de crédito'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

PROMPT 
PROMPT ► Prueba 2.6: Reporte por categoría
PROMPT ────────────────────────────────────────

BEGIN
    SP_REPORTE_POR_CATEGORIA(
        p_fecha_inicio => TRUNC(SYSDATE, 'MM'),
        p_fecha_fin => SYSDATE
    );
END;
/

-- =====================================================
-- SECCIÓN 3: PRUEBAS DE EXCEPCIONES
-- =====================================================

PROMPT 
PROMPT ══════════════════════════════════════════════════════════
PROMPT SECCIÓN 3: PRUEBAS DE EXCEPCIONES
PROMPT ══════════════════════════════════════════════════════════

PROMPT 
PROMPT ► Prueba 3.1: Excepción - Saldo insuficiente
PROMPT ────────────────────────────────────────

BEGIN
    SP_REGISTRAR_MOVIMIENTO(
        p_id_usuario => 1,
        p_id_categoria => 1,
        p_id_cuenta => 1,
        p_id_metodo_pago => 1,
        p_monto => 999999999,
        p_tipo => 'EGRESO',
        p_descripcion => 'Intento de gasto excesivo'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✓ Excepción capturada correctamente:');
        DBMS_OUTPUT.PUT_LINE('  ' || SQLERRM);
END;
/

PROMPT 
PROMPT ► Prueba 3.2: Excepción - Monto negativo
PROMPT ────────────────────────────────────────

BEGIN
    SP_REGISTRAR_MOVIMIENTO(
        p_id_usuario => 1,
        p_id_categoria => 1,
        p_id_cuenta => 1,
        p_id_metodo_pago => 1,
        p_monto => -100,
        p_tipo => 'INGRESO',
        p_descripcion => 'Monto negativo'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✓ Excepción capturada correctamente:');
        DBMS_OUTPUT.PUT_LINE('  ' || SQLERRM);
END;
/

PROMPT 
PROMPT ► Prueba 3.3: Excepción - Usuario inexistente
PROMPT ────────────────────────────────────────

BEGIN
    SP_REGISTRAR_MOVIMIENTO(
        p_id_usuario => 9999,
        p_id_categoria => 1,
        p_id_cuenta => 1,
        p_id_metodo_pago => 1,
        p_monto => 100,
        p_tipo => 'INGRESO',
        p_descripcion => 'Usuario inexistente'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✓ Excepción capturada correctamente:');
        DBMS_OUTPUT.PUT_LINE('  ' || SQLERRM);
END;
/

PROMPT 
PROMPT ► Prueba 3.4: Excepción - Categoría inexistente
PROMPT ────────────────────────────────────────

BEGIN
    SP_REGISTRAR_MOVIMIENTO(
        p_id_usuario => 1,
        p_id_categoria => 9999,
        p_id_cuenta => 1,
        p_id_metodo_pago => 1,
        p_monto => 100,
        p_tipo => 'INGRESO',
        p_descripcion => 'Categoría inexistente'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✓ Excepción capturada correctamente:');
        DBMS_OUTPUT.PUT_LINE('  ' || SQLERRM);
END;
/

PROMPT 
PROMPT ► Prueba 3.5: Excepción - Email duplicado
PROMPT ────────────────────────────────────────

BEGIN
    SP_CREAR_USUARIO(
        p_nombre => 'Pedro Gómez',
        p_email => 'juan.perez@email.com',  -- Email ya existente
        p_password => 'password456'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✓ Excepción capturada correctamente:');
        DBMS_OUTPUT.PUT_LINE('  ' || SQLERRM);
END;
/

PROMPT 
PROMPT ► Prueba 3.6: Excepción - Período inválido
PROMPT ────────────────────────────────────────

BEGIN
    SP_CREAR_PRESUPUESTO(
        p_id_categoria => 1,
        p_nombre => 'Presupuesto con fechas inválidas',
        p_monto_maximo => 1000000,
        p_periodo => 'MENSUAL',
        p_fecha_inicio => SYSDATE,
        p_fecha_fin => SYSDATE - 10  -- Fecha fin anterior a inicio
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✓ Excepción capturada correctamente:');
        DBMS_OUTPUT.PUT_LINE('  ' || SQLERRM);
END;
/

-- =====================================================
-- SECCIÓN 4: PRUEBAS DE TRIGGERS
-- =====================================================

PROMPT 
PROMPT ══════════════════════════════════════════════════════════
PROMPT SECCIÓN 4: PRUEBAS DE TRIGGERS
PROMPT ══════════════════════════════════════════════════════════

PROMPT 
PROMPT ► Prueba 4.1: Trigger - Actualización automática de saldo
PROMPT ────────────────────────────────────────

DECLARE
    v_saldo_inicial NUMBER;
    v_saldo_final NUMBER;
    v_monto_test NUMBER := 250000;
BEGIN
    -- Obtener saldo inicial
    SELECT saldoActual INTO v_saldo_inicial FROM Cuenta WHERE idCuenta = 1;
    DBMS_OUTPUT.PUT_LINE('Saldo inicial: $' || TO_CHAR(v_saldo_inicial, '999,999,999.99'));
    
    -- Insertar movimiento de ingreso
    INSERT INTO Movimiento (idMovimiento, idUsuario, idCategoria, idCuenta, idMetodoPago, monto, tipo)
    VALUES (seq_movimiento.NEXTVAL, 1, 3, 1, 4, v_monto_test, 'INGRESO');
    COMMIT;
    
    -- Obtener saldo final
    SELECT saldoActual INTO v_saldo_final FROM Cuenta WHERE idCuenta = 1;
    DBMS_OUTPUT.PUT_LINE('Saldo final: $' || TO_CHAR(v_saldo_final, '999,999,999.99'));
    DBMS_OUTPUT.PUT_LINE('Diferencia: $' || TO_CHAR(v_saldo_final - v_saldo_inicial, '999,999,999.99'));
    
    IF (v_saldo_final - v_saldo_inicial) = v_monto_test THEN
        DBMS_OUTPUT.PUT_LINE('✓ Trigger funcionó correctamente');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✗ Error en el trigger');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

PROMPT 
PROMPT ► Prueba 4.2: Trigger - Validación de datos
PROMPT ────────────────────────────────────────

BEGIN
    -- Intentar insertar movimiento con tipo inválido
    INSERT INTO Movimiento (idMovimiento, idUsuario, idCategoria, idCuenta, idMetodoPago, monto, tipo)
    VALUES (seq_movimiento.NEXTVAL, 1, 1, 1, 1, 100, 'INVALIDO');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✓ Trigger de validación funcionó correctamente:');
        DBMS_OUTPUT.PUT_LINE('  ' || SQLERRM);
        ROLLBACK;
END;
/

PROMPT 
PROMPT ► Prueba 4.3: Trigger - Prevenir eliminación de categoría
PROMPT ────────────────────────────────────────

BEGIN
    -- Intentar eliminar categoría con movimientos
    DELETE FROM Categoria WHERE idCategoria = 1;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✓ Trigger de prevención funcionó correctamente:');
        DBMS_OUTPUT.PUT_LINE('  ' || SQLERRM);
        ROLLBACK;
END;
/

-- =====================================================
-- SECCIÓN 5: CONSULTAS A VISTAS
-- =====================================================

PROMPT 
PROMPT ══════════════════════════════════════════════════════════
PROMPT SECCIÓN 5: CONSULTAS A VISTAS
PROMPT ══════════════════════════════════════════════════════════

PROMPT 
PROMPT ► Consulta 5.1: Vista de Resumen de Cuentas
PROMPT ────────────────────────────────────────

SELECT 
    idCuenta,
    nombre,
    tipoCuenta,
    TO_CHAR(saldoActual, '999,999,999.99') as saldo,
    total_movimientos,
    TO_CHAR(total_ingresos, '999,999,999.99') as ingresos,
    TO_CHAR(total_egresos, '999,999,999.99') as egresos
FROM VW_RESUMEN_CUENTAS
ORDER BY idCuenta;

PROMPT 
PROMPT ► Consulta 5.2: Vista de Movimientos Detallados (últimos 5)
PROMPT ────────────────────────────────────────

SELECT 
    idMovimiento,
    TO_CHAR(fecha, 'DD/MM/YYYY HH24:MI') as fecha,
    tipo,
    TO_CHAR(monto, '999,999,999.99') as monto,
    categoria,
    cuenta
FROM VW_MOVIMIENTOS_DETALLE
WHERE ROWNUM <= 5
ORDER BY fecha DESC;

-- =====================================================
-- SECCIÓN 6: VERIFICACIÓN DE PRESUPUESTOS
-- =====================================================

PROMPT 
PROMPT ══════════════════════════════════════════════════════════
PROMPT SECCIÓN 6: VERIFICACIÓN DE PRESUPUESTOS
PROMPT ══════════════════════════════════════════════════════════

PROMPT 
PROMPT ► Consulta 6.1: Estado de presupuestos activos
PROMPT ────────────────────────────────────────

SELECT 
    p.idPresupuesto,
    p.nombre,
    c.nombre as categoria,
    TO_CHAR(p.montoMaximo, '999,999,999.99') as limite,
    TO_CHAR(FN_TOTAL_GASTADO_CATEGORIA(p.idCategoria, p.fechaInicio, p.fechaFin), '999,999,999.99') as gastado,
    FN_VERIFICAR_PRESUPUESTO(p.idPresupuesto) as estado,
    TO_CHAR(p.fechaInicio, 'DD/MM/YYYY') as inicio,
    TO_CHAR(p.fechaFin, 'DD/MM/YYYY') as fin
FROM Presupuesto p
INNER JOIN Categoria c ON p.idCategoria = c.idCategoria
WHERE TRUNC(SYSDATE) BETWEEN TRUNC(p.fechaInicio) AND TRUNC(p.fechaFin)
ORDER BY p.idPresupuesto;

-- =====================================================
-- SECCIÓN 7: ESTADÍSTICAS GENERALES
-- =====================================================

PROMPT 
PROMPT ══════════════════════════════════════════════════════════
PROMPT SECCIÓN 7: ESTADÍSTICAS GENERALES
PROMPT ══════════════════════════════════════════════════════════

PROMPT 
PROMPT ► Estadísticas del sistema
PROMPT ────────────────────────────────────────

SELECT 
    'Total Usuarios' as concepto,
    TO_CHAR(COUNT(*)) as cantidad
FROM Usuario
UNION ALL
SELECT 
    'Total Cuentas',
    TO_CHAR(COUNT(*))
FROM Cuenta
UNION ALL
SELECT 
    'Total Movimientos',
    TO_CHAR(COUNT(*))
FROM Movimiento
UNION ALL
SELECT 
    'Total Categorías',
    TO_CHAR(COUNT(*))
FROM Categoria
UNION ALL
SELECT 
    'Total Presupuestos',
    TO_CHAR(COUNT(*))
FROM Presupuesto;

PROMPT 
PROMPT ► Top 3 Categorías con más gastos este mes
PROMPT ────────────────────────────────────────

SELECT 
    c.nombre as categoria,
    COUNT(m.idMovimiento) as num_movimientos,
    TO_CHAR(SUM(m.monto), '999,999,999.99') as total_gastado
FROM Categoria c
INNER JOIN Movimiento m ON c.idCategoria = m.idCategoria
WHERE m.tipo = 'EGRESO'
AND EXTRACT(MONTH FROM m.fecha) = EXTRACT(MONTH FROM SYSDATE)
AND EXTRACT(YEAR FROM m.fecha) = EXTRACT(YEAR FROM SYSDATE)
GROUP BY c.nombre
ORDER BY SUM(m.monto) DESC
FETCH FIRST 3 ROWS ONLY;

PROMPT 
PROMPT ═════════════════════════════════════════════════════════
PROMPT     PRUEBAS COMPLETADAS
PROMPT ═════════════════════════════════════════════════════════

-- Mostrar estado de objetos compilados
PROMPT 
PROMPT ► Estado de objetos del sistema
PROMPT ────────────────────────────────────────

SELECT 
    object_type as tipo,
    object_name as nombre,
    status as estado
FROM user_objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'TRIGGER')
AND object_name LIKE '%FN_%' 
   OR object_name LIKE '%SP_%' 
   OR object_name LIKE '%TRG_%'
   OR object_name LIKE 'RAISE_%'
ORDER BY object_type, object_name;

PROMPT 
PROMPT ═════════════════════════════════════════════════════════
PROMPT FIN DEL SCRIPT DE PRUEBAS
PROMPT ═════════════════════════════════════════════════════════