-- =====================================================
-- TRIGGERS DEL SISTEMA
-- =====================================================

-- ==================== TRIGGERS BÁSICOS ====================

-- 1. TRIGGER: Actualizar saldo de cuenta después de insertar movimiento
CREATE OR REPLACE TRIGGER TRG_ACTUALIZAR_SALDO_INSERTAR
AFTER INSERT ON Movimiento
FOR EACH ROW
BEGIN
    IF :NEW.tipo = 'INGRESO' THEN
        UPDATE Cuenta
        SET saldoActual = saldoActual + :NEW.monto
        WHERE idCuenta = :NEW.idCuenta;
    ELSIF :NEW.tipo = 'EGRESO' THEN
        UPDATE Cuenta
        SET saldoActual = saldoActual - :NEW.monto
        WHERE idCuenta = :NEW.idCuenta;
    END IF;
END;
/

-- 2. TRIGGER: Validar datos antes de insertar movimiento
CREATE OR REPLACE TRIGGER TRG_VALIDAR_MOVIMIENTO
BEFORE INSERT OR UPDATE ON Movimiento
FOR EACH ROW
DECLARE
    v_saldo_actual NUMBER;
BEGIN
    -- Validar que el monto sea positivo
    IF :NEW.monto <= 0 THEN
        RAISE_MONTO_INVALIDO(:NEW.monto);
    END IF;
    
    -- Validar tipo de movimiento
    IF :NEW.tipo NOT IN ('INGRESO', 'EGRESO') THEN
        RAISE_TIPO_MOVIMIENTO_INVALIDO(:NEW.tipo);
    END IF;
    
    -- Si es INSERT y no tiene fecha, asignar fecha actual
    IF INSERTING AND :NEW.fecha IS NULL THEN
        :NEW.fecha := SYSTIMESTAMP;
    END IF;
    
    -- No permitir fechas futuras
    IF :NEW.fecha > SYSTIMESTAMP THEN
        RAISE_FECHA_INVALIDA('No se permiten movimientos con fecha futura');
    END IF;
    
    -- Si es egreso, verificar saldo suficiente antes de insertar
    IF INSERTING AND :NEW.tipo = 'EGRESO' THEN
        SELECT saldoActual INTO v_saldo_actual
        FROM Cuenta
        WHERE idCuenta = :NEW.idCuenta;
        
        IF v_saldo_actual < :NEW.monto THEN
            RAISE_SALDO_INSUFICIENTE(TO_CHAR(:NEW.idCuenta), v_saldo_actual, :NEW.monto);
        END IF;
    END IF;
END;
/


ROLLBACK;

-- 3. TRIGGER: Verificar presupuesto al registrar egreso
CREATE OR REPLACE TRIGGER TRG_VERIFICAR_PRESUPUESTO
AFTER INSERT ON Movimiento
FOR EACH ROW
DECLARE
    v_total_gastado NUMBER;
    v_monto_maximo NUMBER;
    v_nombre_categoria VARCHAR2(100);
    v_nombre_presupuesto VARCHAR2(150);
    v_porcentaje NUMBER;
    
    CURSOR c_presupuestos IS
        SELECT p.idPresupuesto, p.nombre, p.montoMaximo, c.nombre as nombre_categoria
        FROM Presupuesto p
        INNER JOIN Categoria c ON p.idCategoria = c.idCategoria
        WHERE p.idCategoria = :NEW.idCategoria
        AND TRUNC(SYSDATE) BETWEEN TRUNC(p.fechaInicio) AND TRUNC(p.fechaFin);
BEGIN
    -- Solo verificar si es un egreso
    IF :NEW.tipo = 'EGRESO' THEN
        FOR rec IN c_presupuestos LOOP
            -- Calcular total gastado en el período del presupuesto
            SELECT NVL(SUM(m.monto), 0) INTO v_total_gastado
            FROM Movimiento m
            INNER JOIN Presupuesto p ON m.idCategoria = p.idCategoria
            WHERE p.idPresupuesto = rec.idPresupuesto
            AND m.tipo = 'EGRESO'
            AND TRUNC(m.fecha) BETWEEN (SELECT TRUNC(fechaInicio) FROM Presupuesto WHERE idPresupuesto = rec.idPresupuesto)
                                   AND (SELECT TRUNC(fechaFin) FROM Presupuesto WHERE idPresupuesto = rec.idPresupuesto);
            
            v_porcentaje := (v_total_gastado / rec.montoMaximo) * 100;
            
            -- Emitir alerta si supera el 80%
            IF v_total_gastado >= rec.montoMaximo * 0.8 AND v_total_gastado < rec.montoMaximo THEN
                DBMS_OUTPUT.PUT_LINE('⚠ ALERTA: Presupuesto "' || rec.nombre || '" en ' || 
                    ROUND(v_porcentaje, 2) || '% de consumo');
                DBMS_OUTPUT.PUT_LINE('  Gastado: $' || TO_CHAR(v_total_gastado, '999,999,999.99') || 
                    ' de $' || TO_CHAR(rec.montoMaximo, '999,999,999.99'));
            END IF;
            
            -- Lanzar error si excede el presupuesto
            IF v_total_gastado > rec.montoMaximo THEN
                RAISE_PRESUPUESTO_EXCEDIDO(rec.nombre, rec.nombre_categoria, v_total_gastado, rec.montoMaximo);
            END IF;
        END LOOP;
    END IF;
END;
/

-- 4. TRIGGER: Auditar cambios en saldo de cuenta
CREATE OR REPLACE TRIGGER TRG_AUDITAR_CUENTA
AFTER UPDATE OF saldoActual ON Cuenta
FOR EACH ROW
BEGIN
    -- Registrar en log (si existe tabla de auditoría)
    DBMS_OUTPUT.PUT_LINE('AUDITORÍA: Cuenta ' || :NEW.idCuenta || 
        ' | Saldo anterior: $' || TO_CHAR(:OLD.saldoActual, '999,999,999.99') ||
        ' | Saldo nuevo: $' || TO_CHAR(:NEW.saldoActual, '999,999,999.99'));
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Si falla la auditoría, no detener la operación
END;
/

-- 5. TRIGGER: Prevenir eliminación de categorías con movimientos
CREATE OR REPLACE TRIGGER TRG_PREVENIR_ELIMINAR_CATEGORIA
BEFORE DELETE ON Categoria
FOR EACH ROW
DECLARE
    v_count_movimientos NUMBER;
    v_count_presupuestos NUMBER;
BEGIN
    -- Verificar movimientos asociados
    SELECT COUNT(*) INTO v_count_movimientos
    FROM Movimiento
    WHERE idCategoria = :OLD.idCategoria;
    
    IF v_count_movimientos > 0 THEN
        RAISE_APPLICATION_ERROR(-20014, 
            'No se puede eliminar la categoría "' || :OLD.nombre || 
            '" porque tiene ' || v_count_movimientos || ' movimiento(s) asociado(s)');
    END IF;
    
    -- Verificar presupuestos asociados
    SELECT COUNT(*) INTO v_count_presupuestos
    FROM Presupuesto
    WHERE idCategoria = :OLD.idCategoria;
    
    IF v_count_presupuestos > 0 THEN
        RAISE_APPLICATION_ERROR(-20015, 
            'No se puede eliminar la categoría "' || :OLD.nombre || 
            '" porque tiene ' || v_count_presupuestos || ' presupuesto(s) asociado(s)');
    END IF;
END;
/

-- ==================== TRIGGERS INSTEAD OF ====================

-- 6. VISTA: Resumen de cuentas con información agregada
CREATE OR REPLACE VIEW VW_RESUMEN_CUENTAS AS
SELECT 
    c.idCuenta,
    c.nombre,
    c.tipoCuenta,
    c.saldoInicial,
    c.saldoActual,
    c.moneda,
    COUNT(m.idMovimiento) as total_movimientos,
    NVL(SUM(CASE WHEN m.tipo = 'INGRESO' THEN m.monto ELSE 0 END), 0) as total_ingresos,
    NVL(SUM(CASE WHEN m.tipo = 'EGRESO' THEN m.monto ELSE 0 END), 0) as total_egresos,
    c.saldoActual - c.saldoInicial as diferencia_saldo
FROM Cuenta c
LEFT JOIN Movimiento m ON c.idCuenta = m.idCuenta
GROUP BY c.idCuenta, c.nombre, c.tipoCuenta, c.saldoInicial, c.saldoActual, c.moneda;

-- TRIGGER: Actualizar cuenta a través de la vista
CREATE OR REPLACE TRIGGER TRG_IOF_ACTUALIZAR_CUENTA
INSTEAD OF UPDATE ON VW_RESUMEN_CUENTAS
FOR EACH ROW
BEGIN
    UPDATE Cuenta
    SET nombre = :NEW.nombre,
        tipoCuenta = :NEW.tipoCuenta,
        moneda = :NEW.moneda
    WHERE idCuenta = :OLD.idCuenta;
    
    DBMS_OUTPUT.PUT_LINE('✓ Cuenta actualizada: ' || :NEW.nombre);
END;
/

-- 7. VISTA: Movimientos con información detallada
CREATE OR REPLACE VIEW VW_MOVIMIENTOS_DETALLE AS
SELECT 
    m.idMovimiento,
    m.fecha,
    m.tipo,
    m.monto,
    m.descripcion,
    u.nombre as usuario,
    c.nombre as cuenta,
    cat.nombre as categoria,
    cat.tipo as tipo_categoria,
    mp.nombre as metodoPago,
    ct.moneda
FROM Movimiento m
INNER JOIN Usuario u ON m.idUsuario = u.idUsuario
INNER JOIN Cuenta ct ON m.idCuenta = ct.idCuenta
INNER JOIN Categoria cat ON m.idCategoria = cat.idCategoria
INNER JOIN MetodoPago mp ON m.idMetodoPago = mp.idMetodoPago
LEFT JOIN Cuenta c ON m.idCuenta = c.idCuenta;

-- TRIGGER: Eliminar movimiento a través de la vista
CREATE OR REPLACE TRIGGER TRG_IOF_ELIMINAR_MOVIMIENTO
INSTEAD OF DELETE ON VW_MOVIMIENTOS_DETALLE
FOR EACH ROW
DECLARE
    v_id_cuenta NUMBER;
    v_tipo VARCHAR2(10);
    v_monto NUMBER;
BEGIN
    -- Obtener información del movimiento
    SELECT idCuenta, tipo, monto INTO v_id_cuenta, v_tipo, v_monto
    FROM Movimiento
    WHERE idMovimiento = :OLD.idMovimiento;
    
    -- Revertir el cambio en el saldo
    IF v_tipo = 'INGRESO' THEN
        UPDATE Cuenta
        SET saldoActual = saldoActual - v_monto
        WHERE idCuenta = v_id_cuenta;
    ELSIF v_tipo = 'EGRESO' THEN
        UPDATE Cuenta
        SET saldoActual = saldoActual + v_monto
        WHERE idCuenta = v_id_cuenta;
    END IF;
    
    -- Eliminar el movimiento
    DELETE FROM Movimiento
    WHERE idMovimiento = :OLD.idMovimiento;
    
    DBMS_OUTPUT.PUT_LINE('✓ Movimiento eliminado y saldo revertido');
END;
/

-- ==================== TRIGGERS COMPUESTOS ====================

-- 8. TRIGGER COMPUESTO: Control integral de movimientos
CREATE OR REPLACE TRIGGER TRG_COMP_CONTROL_MOVIMIENTOS
FOR INSERT OR UPDATE OR DELETE ON Movimiento
COMPOUND TRIGGER
    
    -- Variables compartidas
    TYPE t_cuentas IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    TYPE t_categorias IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    
    v_cuentas_afectadas t_cuentas;
    v_categorias_afectadas t_categorias;
    v_contador_cuentas PLS_INTEGER := 0;
    v_contador_categorias PLS_INTEGER := 0;
    v_total_ingresos NUMBER := 0;
    v_total_egresos NUMBER := 0;
    
    -- BEFORE STATEMENT
    BEFORE STATEMENT IS
    BEGIN
        v_contador_cuentas := 0;
        v_contador_categorias := 0;
        v_total_ingresos := 0;
        v_total_egresos := 0;
        DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════');
        DBMS_OUTPUT.PUT_LINE('Iniciando operación en tabla Movimiento...');
    END BEFORE STATEMENT;
    
    -- AFTER EACH ROW
    AFTER EACH ROW IS
    BEGIN
        IF INSERTING OR UPDATING THEN
            -- Registrar cuenta afectada
            v_contador_cuentas := v_contador_cuentas + 1;
            v_cuentas_afectadas(v_contador_cuentas) := :NEW.idCuenta;
            
            -- Registrar categoría afectada
            v_contador_categorias := v_contador_categorias + 1;
            v_categorias_afectadas(v_contador_categorias) := :NEW.idCategoria;
            
            -- Acumular montos
            IF :NEW.tipo = 'INGRESO' THEN
                v_total_ingresos := v_total_ingresos + :NEW.monto;
            ELSE
                v_total_egresos := v_total_egresos + :NEW.monto;
            END IF;
            
        ELSIF DELETING THEN
            v_contador_cuentas := v_contador_cuentas + 1;
            v_cuentas_afectadas(v_contador_cuentas) := :OLD.idCuenta;
        END IF;
    END AFTER EACH ROW;
    
    -- AFTER STATEMENT
    AFTER STATEMENT IS
        v_nombre_cuenta VARCHAR2(150);
        v_nombre_categoria VARCHAR2(100);
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Operación completada');
        DBMS_OUTPUT.PUT_LINE('───────────────────────────────────────────');
        
        IF v_contador_cuentas > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Cuentas afectadas: ' || v_contador_cuentas);
            
            -- Mostrar detalles de cuentas únicas
            FOR i IN 1..v_contador_cuentas LOOP
                BEGIN
                    SELECT nombre INTO v_nombre_cuenta
                    FROM Cuenta
                    WHERE idCuenta = v_cuentas_afectadas(i)
                    AND ROWNUM = 1;
                    
                    DBMS_OUTPUT.PUT_LINE('  • ' || v_nombre_cuenta || ' (ID: ' || v_cuentas_afectadas(i) || ')');
                EXCEPTION
                    WHEN OTHERS THEN NULL;
                END;
            END LOOP;
        END IF;
        
        IF v_total_ingresos > 0 OR v_total_egresos > 0 THEN
            DBMS_OUTPUT.PUT_LINE('───────────────────────────────────────────');
            IF v_total_ingresos > 0 THEN
                DBMS_OUTPUT.PUT_LINE('Total Ingresos: $' || TO_CHAR(v_total_ingresos, '999,999,999.99'));
            END IF;
            IF v_total_egresos > 0 THEN
                DBMS_OUTPUT.PUT_LINE('Total Egresos:  $' || TO_CHAR(v_total_egresos, '999,999,999.99'));
            END IF;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════');
    END AFTER STATEMENT;
    
END TRG_COMP_CONTROL_MOVIMIENTOS;
/

-- 9. TRIGGER COMPUESTO: Gestión de presupuestos
CREATE OR REPLACE TRIGGER TRG_COMP_GESTION_PRESUPUESTOS
FOR INSERT OR UPDATE OR DELETE ON Presupuesto
COMPOUND TRIGGER
    
    TYPE t_presupuestos IS TABLE OF VARCHAR2(200) INDEX BY PLS_INTEGER;
    v_presupuestos_creados t_presupuestos;
    v_contador PLS_INTEGER := 0;
    
    BEFORE STATEMENT IS
    BEGIN
        v_contador := 0;
        DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════');
        DBMS_OUTPUT.PUT_LINE('Gestionando presupuestos...');
    END BEFORE STATEMENT;
    
    BEFORE EACH ROW IS
    BEGIN
        IF INSERTING OR UPDATING THEN
            -- Validar fechas
            IF :NEW.fechaFin <= :NEW.fechaInicio THEN
                RAISE_PERIODO_INVALIDO(:NEW.fechaInicio, :NEW.fechaFin);
            END IF;
            
            -- Validar monto máximo
            IF :NEW.montoMaximo <= 0 THEN
                RAISE_MONTO_INVALIDO(:NEW.montoMaximo);
            END IF;
        END IF;
    END BEFORE EACH ROW;
    
    AFTER EACH ROW IS
    BEGIN
        IF INSERTING THEN
            v_contador := v_contador + 1;
            v_presupuestos_creados(v_contador) := :NEW.nombre || ' ($' || 
                TO_CHAR(:NEW.montoMaximo, '999,999,999.99') || ')';
        END IF;
    END AFTER EACH ROW;
    
    AFTER STATEMENT IS
    BEGIN
        IF v_contador > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Presupuestos creados: ' || v_contador);
            FOR i IN 1..v_contador LOOP
                DBMS_OUTPUT.PUT_LINE('  ✓ ' || v_presupuestos_creados(i));
            END LOOP;
        END IF;
        DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════');
    END AFTER STATEMENT;
    
END TRG_COMP_GESTION_PRESUPUESTOS;
/

-- 10. TRIGGER: Validar email único al insertar usuario
CREATE OR REPLACE TRIGGER TRG_VALIDAR_USUARIO
BEFORE INSERT OR UPDATE ON Usuario
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    -- Convertir email a minúsculas
    :NEW.email := LOWER(:NEW.email);
    
    -- Validar formato de email
    IF NOT REGEXP_LIKE(:NEW.email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RAISE_APPLICATION_ERROR(-20016, 'Formato de email inválido: ' || :NEW.email);
    END IF;
    
    -- Si es UPDATE, verificar que no se duplique con otro usuario
    IF UPDATING THEN
        SELECT COUNT(*) INTO v_count
        FROM Usuario
        WHERE email = :NEW.email
        AND idUsuario != :OLD.idUsuario;
        
        IF v_count > 0 THEN
            RAISE_EMAIL_DUPLICADO(:NEW.email);
        END IF;
    END IF;
END;
/

COMMIT;