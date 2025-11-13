
-- ==================== FUNCIONES ====================

-- 1. FUNCIÓN: Obtener saldo actual de una cuenta
CREATE OR REPLACE FUNCTION FN_OBTENER_SALDO_CUENTA(
    p_id_cuenta NUMBER
) RETURN NUMBER IS
    v_saldo NUMBER;
BEGIN
    SELECT saldoActual INTO v_saldo
    FROM Cuenta
    WHERE idCuenta = p_id_cuenta;
    
    RETURN v_saldo;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_CUENTA_NO_EXISTE(p_id_cuenta);
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE;
END FN_OBTENER_SALDO_CUENTA;
/

-- 2. FUNCIÓN: Calcular total gastado en una categoría durante un período
CREATE OR REPLACE FUNCTION FN_TOTAL_GASTADO_CATEGORIA(
    p_id_categoria NUMBER,
    p_fecha_inicio DATE,
    p_fecha_fin DATE
) RETURN NUMBER IS
    v_total NUMBER := 0;
BEGIN
    SELECT NVL(SUM(monto), 0) INTO v_total
    FROM Movimiento
    WHERE idCategoria = p_id_categoria
    AND tipo = 'EGRESO'
    AND fecha BETWEEN p_fecha_inicio AND p_fecha_fin;
    
    RETURN v_total;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END FN_TOTAL_GASTADO_CATEGORIA;
/

-- 3. FUNCIÓN: Verificar estado de presupuesto (OK, ALERTA, EXCEDIDO)
CREATE OR REPLACE FUNCTION FN_VERIFICAR_PRESUPUESTO(
    p_id_presupuesto NUMBER
) RETURN VARCHAR2 IS
    v_monto_maximo NUMBER;
    v_gastado NUMBER;
    v_id_categoria NUMBER;
    v_fecha_inicio DATE;
    v_fecha_fin DATE;
    v_porcentaje NUMBER;
BEGIN
    -- Obtener datos del presupuesto
    SELECT montoMaximo, idCategoria, fechaInicio, fechaFin
    INTO v_monto_maximo, v_id_categoria, v_fecha_inicio, v_fecha_fin
    FROM Presupuesto
    WHERE idPresupuesto = p_id_presupuesto;
    
    -- Calcular total gastado en el período
    v_gastado := FN_TOTAL_GASTADO_CATEGORIA(v_id_categoria, v_fecha_inicio, v_fecha_fin);
    
    -- Calcular porcentaje
    v_porcentaje := (v_gastado / v_monto_maximo) * 100;
    
    IF v_gastado > v_monto_maximo THEN
        RETURN 'EXCEDIDO (' || ROUND(v_porcentaje, 2) || '%)';
    ELSIF v_gastado >= v_monto_maximo * 0.8 THEN
        RETURN 'ALERTA (' || ROUND(v_porcentaje, 2) || '%)';
    ELSE
        RETURN 'OK (' || ROUND(v_porcentaje, 2) || '%)';
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'PRESUPUESTO NO ENCONTRADO';
    WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
END FN_VERIFICAR_PRESUPUESTO;
/

-- 4. FUNCIÓN: Calcular balance mensual de una cuenta
CREATE OR REPLACE FUNCTION FN_BALANCE_MENSUAL(
    p_id_cuenta NUMBER,
    p_mes NUMBER,
    p_anio NUMBER
) RETURN NUMBER IS
    v_ingresos NUMBER := 0;
    v_egresos NUMBER := 0;
BEGIN
    -- Calcular ingresos del mes
    SELECT NVL(SUM(monto), 0) INTO v_ingresos
    FROM Movimiento
    WHERE idCuenta = p_id_cuenta
    AND tipo = 'INGRESO'
    AND EXTRACT(MONTH FROM fecha) = p_mes
    AND EXTRACT(YEAR FROM fecha) = p_anio;
    
    -- Calcular egresos del mes
    SELECT NVL(SUM(monto), 0) INTO v_egresos
    FROM Movimiento
    WHERE idCuenta = p_id_cuenta
    AND tipo = 'EGRESO'
    AND EXTRACT(MONTH FROM fecha) = p_mes
    AND EXTRACT(YEAR FROM fecha) = p_anio;
    
    RETURN v_ingresos - v_egresos;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END FN_BALANCE_MENSUAL;
/

-- 5. FUNCIÓN: Calcular ahorro en un período
CREATE OR REPLACE FUNCTION FN_CALCULAR_AHORRO(
    p_id_cuenta NUMBER,
    p_fecha_inicio DATE,
    p_fecha_fin DATE
) RETURN NUMBER IS
    v_ingresos NUMBER := 0;
    v_egresos NUMBER := 0;
BEGIN
    -- Calcular ingresos
    SELECT NVL(SUM(monto), 0) INTO v_ingresos
    FROM Movimiento
    WHERE idCuenta = p_id_cuenta
    AND tipo = 'INGRESO'
    AND fecha BETWEEN p_fecha_inicio AND p_fecha_fin;
    
    -- Calcular egresos
    SELECT NVL(SUM(monto), 0) INTO v_egresos
    FROM Movimiento
    WHERE idCuenta = p_id_cuenta
    AND tipo = 'EGRESO'
    AND fecha BETWEEN p_fecha_inicio AND p_fecha_fin;
    
    RETURN v_ingresos - v_egresos;
END FN_CALCULAR_AHORRO;
/

-- ==================== PROCEDIMIENTOS ====================

-- 6. PROCEDIMIENTO: Registrar movimiento con validaciones
CREATE OR REPLACE PROCEDURE SP_REGISTRAR_MOVIMIENTO(
    p_id_usuario NUMBER,
    p_id_categoria NUMBER,
    p_id_cuenta NUMBER,
    p_id_metodo_pago NUMBER,
    p_monto NUMBER,
    p_tipo VARCHAR2,
    p_descripcion CLOB DEFAULT NULL
) IS
    v_saldo_actual NUMBER;
    v_existe_usuario NUMBER;
    v_existe_categoria NUMBER;
    v_existe_metodo NUMBER;
    v_id_movimiento NUMBER;
BEGIN
    -- Validar que el monto sea positivo
    IF p_monto <= 0 THEN
        RAISE_MONTO_INVALIDO(p_monto);
    END IF;
    
    -- Validar tipo de movimiento
    IF p_tipo NOT IN ('INGRESO', 'EGRESO') THEN
        RAISE_TIPO_MOVIMIENTO_INVALIDO(p_tipo);
    END IF;
    
    -- Validar que el usuario existe
    SELECT COUNT(*) INTO v_existe_usuario FROM Usuario WHERE idUsuario = p_id_usuario;
    IF v_existe_usuario = 0 THEN
        RAISE_USUARIO_NO_EXISTE(p_id_usuario);
    END IF;
    
    -- Validar que la categoría existe
    SELECT COUNT(*) INTO v_existe_categoria FROM Categoria WHERE idCategoria = p_id_categoria;
    IF v_existe_categoria = 0 THEN
        RAISE_CATEGORIA_NO_EXISTE(p_id_categoria);
    END IF;
    
    -- Validar que el método de pago existe
    SELECT COUNT(*) INTO v_existe_metodo FROM MetodoPago WHERE idMetodoPago = p_id_metodo_pago;
    IF v_existe_metodo = 0 THEN
        RAISE_METODO_PAGO_INVALIDO(p_id_metodo_pago);
    END IF;
    
    -- Obtener saldo actual
    v_saldo_actual := FN_OBTENER_SALDO_CUENTA(p_id_cuenta);
    
    -- Si es egreso, verificar saldo suficiente
    IF p_tipo = 'EGRESO' AND v_saldo_actual < p_monto THEN
        RAISE_SALDO_INSUFICIENTE(TO_CHAR(p_id_cuenta), v_saldo_actual, p_monto);
    END IF;
    
    -- Obtener siguiente ID de la secuencia
    SELECT seq_movimiento.NEXTVAL INTO v_id_movimiento FROM DUAL;
    
    -- Insertar movimiento
    INSERT INTO Movimiento (idMovimiento, idUsuario, idCategoria, idCuenta, idMetodoPago, monto, tipo, descripcion)
    VALUES (v_id_movimiento, p_id_usuario, p_id_categoria, p_id_cuenta, p_id_metodo_pago, p_monto, p_tipo, p_descripcion);
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('✓ Movimiento registrado exitosamente. ID: ' || v_id_movimiento);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_REGISTRAR_MOVIMIENTO;
/

-- 7. PROCEDIMIENTO: Transferir entre cuentas
CREATE OR REPLACE PROCEDURE SP_TRANSFERIR_ENTRE_CUENTAS(
    p_id_usuario NUMBER,
    p_cuenta_origen NUMBER,
    p_cuenta_destino NUMBER,
    p_monto NUMBER,
    p_id_categoria NUMBER,
    p_id_metodo_pago NUMBER,
    p_descripcion CLOB DEFAULT 'Transferencia entre cuentas'
) IS
    v_saldo_origen NUMBER;
    v_nombre_origen VARCHAR2(150);
    v_nombre_destino VARCHAR2(150);
BEGIN
    -- Validar monto
    IF p_monto <= 0 THEN
        RAISE_MONTO_INVALIDO(p_monto);
    END IF;
    
    -- Validar que las cuentas sean diferentes
    IF p_cuenta_origen = p_cuenta_destino THEN
        RAISE_APPLICATION_ERROR(-20013, 'Las cuentas de origen y destino deben ser diferentes');
    END IF;
    
    -- Obtener nombres de cuentas
    SELECT nombre INTO v_nombre_origen FROM Cuenta WHERE idCuenta = p_cuenta_origen;
    SELECT nombre INTO v_nombre_destino FROM Cuenta WHERE idCuenta = p_cuenta_destino;
    
    -- Verificar saldo suficiente
    v_saldo_origen := FN_OBTENER_SALDO_CUENTA(p_cuenta_origen);
    IF v_saldo_origen < p_monto THEN
        RAISE_SALDO_INSUFICIENTE(v_nombre_origen, v_saldo_origen, p_monto);
    END IF;
    
    -- Registrar egreso en cuenta origen
    SP_REGISTRAR_MOVIMIENTO(
        p_id_usuario, p_id_categoria, p_cuenta_origen, p_id_metodo_pago, 
        p_monto, 'EGRESO', 
        'Transferencia a ' || v_nombre_destino || ': ' || p_descripcion
    );
    
    -- Registrar ingreso en cuenta destino
    SP_REGISTRAR_MOVIMIENTO(
        p_id_usuario, p_id_categoria, p_cuenta_destino, p_id_metodo_pago, 
        p_monto, 'INGRESO', 
        'Transferencia desde ' || v_nombre_origen || ': ' || p_descripcion
    );
    
    DBMS_OUTPUT.PUT_LINE('✓ Transferencia completada: $' || TO_CHAR(p_monto, '999,999,999.99'));
    DBMS_OUTPUT.PUT_LINE('  Desde: ' || v_nombre_origen);
    DBMS_OUTPUT.PUT_LINE('  Hacia: ' || v_nombre_destino);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_TRANSFERIR_ENTRE_CUENTAS;
/

-- 8. PROCEDIMIENTO: Crear presupuesto
CREATE OR REPLACE PROCEDURE SP_CREAR_PRESUPUESTO(
    p_id_categoria NUMBER,
    p_nombre VARCHAR2,
    p_monto_maximo NUMBER,
    p_periodo VARCHAR2,
    p_fecha_inicio DATE,
    p_fecha_fin DATE
) IS
    v_existe_categoria NUMBER;
    v_id_presupuesto NUMBER;
BEGIN
    -- Validar monto máximo
    IF p_monto_maximo <= 0 THEN
        RAISE_MONTO_INVALIDO(p_monto_maximo);
    END IF;
    
    -- Validar fechas
    IF p_fecha_fin <= p_fecha_inicio THEN
        RAISE_PERIODO_INVALIDO(p_fecha_inicio, p_fecha_fin);
    END IF;
    
    -- Verificar que la categoría exista
    SELECT COUNT(*) INTO v_existe_categoria FROM Categoria WHERE idCategoria = p_id_categoria;
    IF v_existe_categoria = 0 THEN
        RAISE_CATEGORIA_NO_EXISTE(p_id_categoria);
    END IF;
    
    -- Obtener siguiente ID
    SELECT seq_presupuesto.NEXTVAL INTO v_id_presupuesto FROM DUAL;
    
    -- Insertar presupuesto
    INSERT INTO Presupuesto (idPresupuesto, idCategoria, nombre, montoMaximo, periodo, fechaInicio, fechaFin)
    VALUES (v_id_presupuesto, p_id_categoria, p_nombre, p_monto_maximo, p_periodo, p_fecha_inicio, p_fecha_fin);
    
    -- Insertar relación en tabla intermedia
    INSERT INTO Categoria_Presupuesto (idCategoria, idPresupuesto)
    VALUES (p_id_categoria, v_id_presupuesto);
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('✓ Presupuesto creado exitosamente');
    DBMS_OUTPUT.PUT_LINE('  ID: ' || v_id_presupuesto);
    DBMS_OUTPUT.PUT_LINE('  Nombre: ' || p_nombre);
    DBMS_OUTPUT.PUT_LINE('  Monto Máximo: $' || TO_CHAR(p_monto_maximo, '999,999,999.99'));
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_CREAR_PRESUPUESTO;
/

-- 9. PROCEDIMIENTO: Reporte por categoría
CREATE OR REPLACE PROCEDURE SP_REPORTE_POR_CATEGORIA(
    p_fecha_inicio DATE,
    p_fecha_fin DATE
) IS
    CURSOR c_categorias IS
        SELECT c.idCategoria, c.nombre, c.tipo,
               NVL(SUM(CASE WHEN m.tipo = 'INGRESO' THEN m.monto ELSE 0 END), 0) as ingresos,
               NVL(SUM(CASE WHEN m.tipo = 'EGRESO' THEN m.monto ELSE 0 END), 0) as egresos,
               COUNT(m.idMovimiento) as num_movimientos
        FROM Categoria c
        LEFT JOIN Movimiento m ON c.idCategoria = m.idCategoria
            AND m.fecha BETWEEN p_fecha_inicio AND p_fecha_fin
        GROUP BY c.idCategoria, c.nombre, c.tipo
        ORDER BY c.tipo, egresos DESC;
    
    v_total_ingresos NUMBER := 0;
    v_total_egresos NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=======================================================');
    DBMS_OUTPUT.PUT_LINE('        REPORTE DE MOVIMIENTOS POR CATEGORÍA');
    DBMS_OUTPUT.PUT_LINE('=======================================================');
    DBMS_OUTPUT.PUT_LINE('Período: ' || TO_CHAR(p_fecha_inicio, 'DD/MM/YYYY') || 
                        ' al ' || TO_CHAR(p_fecha_fin, 'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('=======================================================');
    DBMS_OUTPUT.PUT_LINE('');
    
    FOR rec IN c_categorias LOOP
        IF rec.num_movimientos > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Categoría: ' || rec.nombre || ' [' || rec.tipo || ']');
            DBMS_OUTPUT.PUT_LINE('  Ingresos:     $' || TO_CHAR(rec.ingresos, '999,999,999.99'));
            DBMS_OUTPUT.PUT_LINE('  Egresos:      $' || TO_CHAR(rec.egresos, '999,999,999.99'));
            DBMS_OUTPUT.PUT_LINE('  Balance:      $' || TO_CHAR(rec.ingresos - rec.egresos, '999,999,999.99'));
            DBMS_OUTPUT.PUT_LINE('  Movimientos:  ' || rec.num_movimientos);
            DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
            
            v_total_ingresos := v_total_ingresos + rec.ingresos;
            v_total_egresos := v_total_egresos + rec.egresos;
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=======================================================');
    DBMS_OUTPUT.PUT_LINE('RESUMEN TOTAL:');
    DBMS_OUTPUT.PUT_LINE('  Total Ingresos: $' || TO_CHAR(v_total_ingresos, '999,999,999.99'));
    DBMS_OUTPUT.PUT_LINE('  Total Egresos:  $' || TO_CHAR(v_total_egresos, '999,999,999.99'));
    DBMS_OUTPUT.PUT_LINE('  Balance Neto:   $' || TO_CHAR(v_total_ingresos - v_total_egresos, '999,999,999.99'));
    DBMS_OUTPUT.PUT_LINE('=======================================================');
END SP_REPORTE_POR_CATEGORIA;
/

-- 10. PROCEDIMIENTO: Crear usuario
CREATE OR REPLACE PROCEDURE SP_CREAR_USUARIO(
    p_nombre VARCHAR2,
    p_email VARCHAR2,
    p_password VARCHAR2
) IS
    v_existe_email NUMBER;
    v_id_usuario NUMBER;
BEGIN
    -- Verificar si el email ya existe
    SELECT COUNT(*) INTO v_existe_email FROM Usuario WHERE email = p_email;
    IF v_existe_email > 0 THEN
        RAISE_EMAIL_DUPLICADO(p_email);
    END IF;
    
    -- Obtener siguiente ID
    SELECT seq_usuario.NEXTVAL INTO v_id_usuario FROM DUAL;
    
    -- Insertar usuario
    INSERT INTO Usuario (idUsuario, nombre, email, password)
    VALUES (v_id_usuario, p_nombre, p_email, p_password);
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('✓ Usuario creado exitosamente');
    DBMS_OUTPUT.PUT_LINE('  ID: ' || v_id_usuario);
    DBMS_OUTPUT.PUT_LINE('  Nombre: ' || p_nombre);
    DBMS_OUTPUT.PUT_LINE('  Email: ' || p_email);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_CREAR_USUARIO;
/