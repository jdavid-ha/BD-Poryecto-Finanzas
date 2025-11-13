-- =====================================================
-- EXCEPCIONES (12)
-- =====================================================

-- 1. Excepción para saldo insuficiente
CREATE OR REPLACE PROCEDURE RAISE_SALDO_INSUFICIENTE(
    p_cuenta VARCHAR2,
    p_saldo_actual NUMBER,
    p_monto_requerido NUMBER
) IS
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 
        'SALDO INSUFICIENTE en cuenta ' || p_cuenta || 
        '. Saldo disponible: $' || TO_CHAR(p_saldo_actual, '999,999,999.99') || 
        ', Monto requerido: $' || TO_CHAR(p_monto_requerido, '999,999,999.99'));
END RAISE_SALDO_INSUFICIENTE;
/

-- 2. Excepción para presupuesto excedido
CREATE OR REPLACE PROCEDURE RAISE_PRESUPUESTO_EXCEDIDO(
    p_nombre_presupuesto VARCHAR2,
    p_categoria VARCHAR2,
    p_monto_gastado NUMBER,
    p_monto_maximo NUMBER
) IS
BEGIN
    RAISE_APPLICATION_ERROR(-20002, 
        'PRESUPUESTO EXCEDIDO: "' || p_nombre_presupuesto || '" en categoría "' || p_categoria || '". ' ||
        'Gastado: $' || TO_CHAR(p_monto_gastado, '999,999,999.99') || 
        ', Límite: $' || TO_CHAR(p_monto_maximo, '999,999,999.99'));
END RAISE_PRESUPUESTO_EXCEDIDO;
/

-- 3. Excepción para fecha inválida
CREATE OR REPLACE PROCEDURE RAISE_FECHA_INVALIDA(
    p_mensaje VARCHAR2
) IS
BEGIN
    RAISE_APPLICATION_ERROR(-20003, 
        'FECHA INVÁLIDA: ' || p_mensaje);
END RAISE_FECHA_INVALIDA;
/

-- 4. Excepción para monto negativo o cero
CREATE OR REPLACE PROCEDURE RAISE_MONTO_INVALIDO(
    p_monto NUMBER
) IS
BEGIN
    RAISE_APPLICATION_ERROR(-20004, 
        'MONTO INVÁLIDO: El monto debe ser mayor a cero. Valor recibido: $' || 
        TO_CHAR(p_monto, '999,999,999.99'));
END RAISE_MONTO_INVALIDO;
/

-- 5. Excepción para cuenta inexistente
CREATE OR REPLACE PROCEDURE RAISE_CUENTA_NO_EXISTE(
    p_id_cuenta NUMBER
) IS
BEGIN
    RAISE_APPLICATION_ERROR(-20005, 
        'CUENTA NO EXISTE: La cuenta con ID ' || p_id_cuenta || ' no fue encontrada en el sistema');
END RAISE_CUENTA_NO_EXISTE;
/

-- 6. Excepción para categoría inexistente
CREATE OR REPLACE PROCEDURE RAISE_CATEGORIA_NO_EXISTE(
    p_id_categoria NUMBER
) IS
BEGIN
    RAISE_APPLICATION_ERROR(-20006, 
        'CATEGORÍA NO EXISTE: La categoría con ID ' || p_id_categoria || ' no fue encontrada');
END RAISE_CATEGORIA_NO_EXISTE;
/

-- 7. Excepción para presupuesto vencido
CREATE OR REPLACE PROCEDURE RAISE_PRESUPUESTO_VENCIDO(
    p_nombre_presupuesto VARCHAR2,
    p_fecha_fin DATE
) IS
BEGIN
    RAISE_APPLICATION_ERROR(-20007, 
        'PRESUPUESTO VENCIDO: "' || p_nombre_presupuesto || '" finalizó el ' || 
        TO_CHAR(p_fecha_fin, 'DD/MM/YYYY'));
END RAISE_PRESUPUESTO_VENCIDO;
/

-- 8. Excepción para usuario inexistente
CREATE OR REPLACE PROCEDURE RAISE_USUARIO_NO_EXISTE(
    p_id_usuario NUMBER
) IS
BEGIN
    RAISE_APPLICATION_ERROR(-20008, 
        'USUARIO NO EXISTE: El usuario con ID ' || p_id_usuario || ' no fue encontrado');
END RAISE_USUARIO_NO_EXISTE;
/

-- 9. Excepción para tipo de movimiento inválido
CREATE OR REPLACE PROCEDURE RAISE_TIPO_MOVIMIENTO_INVALIDO(
    p_tipo VARCHAR2
) IS
BEGIN
    RAISE_APPLICATION_ERROR(-20009, 
        'TIPO DE MOVIMIENTO INVÁLIDO: "' || p_tipo || '". Debe ser INGRESO o EGRESO');
END RAISE_TIPO_MOVIMIENTO_INVALIDO;
/

-- 10. Excepción para método de pago inválido
CREATE OR REPLACE PROCEDURE RAISE_METODO_PAGO_INVALIDO(
    p_id_metodo NUMBER
) IS
BEGIN
    RAISE_APPLICATION_ERROR(-20010, 
        'MÉTODO DE PAGO INVÁLIDO: El método de pago con ID ' || p_id_metodo || 
        ' no existe o no está disponible');
END RAISE_METODO_PAGO_INVALIDO;
/

-- 11. Excepción para período inválido
CREATE OR REPLACE PROCEDURE RAISE_PERIODO_INVALIDO(
    p_fecha_inicio DATE,
    p_fecha_fin DATE
) IS
BEGIN
    RAISE_APPLICATION_ERROR(-20011, 
        'PERÍODO INVÁLIDO: La fecha de inicio (' || TO_CHAR(p_fecha_inicio, 'DD/MM/YYYY') || 
        ') debe ser anterior a la fecha de fin (' || TO_CHAR(p_fecha_fin, 'DD/MM/YYYY') || ')');
END RAISE_PERIODO_INVALIDO;
/

-- 12. Excepción para email duplicado
CREATE OR REPLACE PROCEDURE RAISE_EMAIL_DUPLICADO(
    p_email VARCHAR2
) IS
BEGIN
    RAISE_APPLICATION_ERROR(-20012, 
        'EMAIL DUPLICADO: El correo electrónico "' || p_email || '" ya está registrado en el sistema');
END RAISE_EMAIL_DUPLICADO;
/

-- Procedimiento para mostrar todas las excepciones disponibles
CREATE OR REPLACE PROCEDURE MOSTRAR_EXCEPCIONES IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('====== EXCEPCIONES DEL SISTEMA ======');
    DBMS_OUTPUT.PUT_LINE('-20001: Saldo insuficiente');
    DBMS_OUTPUT.PUT_LINE('-20002: Presupuesto excedido');
    DBMS_OUTPUT.PUT_LINE('-20003: Fecha inválida');
    DBMS_OUTPUT.PUT_LINE('-20004: Monto inválido');
    DBMS_OUTPUT.PUT_LINE('-20005: Cuenta no existe');
    DBMS_OUTPUT.PUT_LINE('-20006: Categoría no existe');
    DBMS_OUTPUT.PUT_LINE('-20007: Presupuesto vencido');
    DBMS_OUTPUT.PUT_LINE('-20008: Usuario no existe');
    DBMS_OUTPUT.PUT_LINE('-20009: Tipo de movimiento inválido');
    DBMS_OUTPUT.PUT_LINE('-20010: Método de pago inválido');
    DBMS_OUTPUT.PUT_LINE('-20011: Período inválido');
    DBMS_OUTPUT.PUT_LINE('-20012: Email duplicado');
    DBMS_OUTPUT.PUT_LINE('=====================================');
END MOSTRAR_EXCEPCIONES;
/


COMMIT;