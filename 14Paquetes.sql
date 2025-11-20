-- ============================================================================
-- PAQUETE: PKG_USUARIO
-- ============================================================================

CREATE OR REPLACE PACKAGE pkg_usuario AS
    -- Crear usuario (retorna ID generado)
    FUNCTION crear_usuario(
        p_nombre IN VARCHAR2,
        p_email IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN t_respuesta;
    
    -- Actualizar usuario
    FUNCTION actualizar_usuario(
        p_idUsuario IN NUMBER,
        p_nombre IN VARCHAR2,
        p_email IN VARCHAR2
    ) RETURN t_respuesta;
    
    -- Eliminar usuario
    FUNCTION eliminar_usuario(
        p_idUsuario IN NUMBER
    ) RETURN t_respuesta;
    
    -- Obtener usuario por ID
    FUNCTION obtener_usuario(
        p_idUsuario IN NUMBER
    ) RETURN t_usuario;
    
    -- Listar todos los usuarios
    FUNCTION listar_usuarios RETURN t_usuarios_tabla PIPELINED;
    
    -- Insertar usuario usando %ROWTYPE
    FUNCTION insertar_usuario_rowtype(
    p_usuario IN Usuario%ROWTYPE
) RETURN t_respuesta;
END pkg_usuario;
/

CREATE OR REPLACE PACKAGE BODY pkg_usuario AS

    FUNCTION crear_usuario(
        p_nombre IN VARCHAR2,
        p_email IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN t_respuesta IS
        v_id NUMBER;
        v_respuesta t_respuesta;
    BEGIN
        v_id := seq_usuario.NEXTVAL;
        
        INSERT INTO Usuario (idUsuario, nombre, email, password, fechaRegistro)
        VALUES (v_id, p_nombre, p_email, p_password, CURRENT_TIMESTAMP);
        
        COMMIT;
        
        v_respuesta := t_respuesta(1, 'Usuario creado exitosamente', v_id);
        RETURN v_respuesta;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'El email ya existe', NULL);
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END crear_usuario;

    FUNCTION actualizar_usuario(
        p_idUsuario IN NUMBER,
        p_nombre IN VARCHAR2,
        p_email IN VARCHAR2
    ) RETURN t_respuesta IS
        v_count NUMBER;
    BEGIN
        UPDATE Usuario 
        SET nombre = p_nombre, 
            email = p_email
        WHERE idUsuario = p_idUsuario;
        
        v_count := SQL%ROWCOUNT;
        
        IF v_count > 0 THEN
            COMMIT;
            RETURN t_respuesta(1, 'Usuario actualizado exitosamente', p_idUsuario);
        ELSE
            RETURN t_respuesta(0, 'Usuario no encontrado', NULL);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END actualizar_usuario;

    FUNCTION eliminar_usuario(
        p_idUsuario IN NUMBER
    ) RETURN t_respuesta IS
        v_count NUMBER;
    BEGIN
        DELETE FROM Usuario WHERE idUsuario = p_idUsuario;
        v_count := SQL%ROWCOUNT;
        
        IF v_count > 0 THEN
            COMMIT;
            RETURN t_respuesta(1, 'Usuario eliminado exitosamente', p_idUsuario);
        ELSE
            RETURN t_respuesta(0, 'Usuario no encontrado', NULL);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END eliminar_usuario;

    FUNCTION obtener_usuario(
        p_idUsuario IN NUMBER
    ) RETURN t_usuario IS
        v_usuario t_usuario;
    BEGIN
        SELECT t_usuario(idUsuario, nombre, email, password, fechaRegistro)
        INTO v_usuario
        FROM Usuario
        WHERE idUsuario = p_idUsuario;
        
        RETURN v_usuario;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END obtener_usuario;

    FUNCTION listar_usuarios RETURN t_usuarios_tabla PIPELINED IS
    BEGIN
        FOR rec IN (SELECT * FROM Usuario ORDER BY fechaRegistro DESC) LOOP
            PIPE ROW(t_usuario(
                rec.idUsuario,
                rec.nombre,
                rec.email,
                rec.password,
                rec.fechaRegistro
            ));
        END LOOP;
        RETURN;
    END listar_usuarios;

    FUNCTION insertar_usuario_rowtype(
        p_usuario IN Usuario%ROWTYPE
    ) RETURN t_respuesta IS
        v_id NUMBER;
    BEGIN
        v_id := seq_usuario.NEXTVAL;
        
        INSERT INTO Usuario VALUES (
            v_id,
            p_usuario.nombre,
            p_usuario.email,
            p_usuario.password,
            CURRENT_TIMESTAMP
        );
        
        COMMIT;
        RETURN t_respuesta(1, 'Usuario creado desde ROWTYPE', v_id);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END insertar_usuario_rowtype;

END pkg_usuario;
/

-- ============================================================================
-- PAQUETE: PKG_CATEGORIA
-- ============================================================================

CREATE OR REPLACE PACKAGE pkg_categoria AS
    FUNCTION crear_categoria(
        p_nombre IN VARCHAR2,
        p_tipo IN VARCHAR2
    ) RETURN t_respuesta;
    
    FUNCTION actualizar_categoria(
        p_idCategoria IN NUMBER,
        p_nombre IN VARCHAR2,
        p_tipo IN VARCHAR2
    ) RETURN t_respuesta;
    
    FUNCTION eliminar_categoria(
        p_idCategoria IN NUMBER
    ) RETURN t_respuesta;
    
    FUNCTION obtener_categoria(
        p_idCategoria IN NUMBER
    ) RETURN t_categoria;
    
    FUNCTION listar_categorias RETURN t_categorias_tabla PIPELINED;
    
    FUNCTION insertar_categoria_rowtype(
        p_categoria IN Categoria%ROWTYPE
    ) RETURN t_respuesta;
END pkg_categoria;
/

CREATE OR REPLACE PACKAGE BODY pkg_categoria AS

    FUNCTION crear_categoria(
        p_nombre IN VARCHAR2,
        p_tipo IN VARCHAR2
    ) RETURN t_respuesta IS
        v_id NUMBER;
    BEGIN
        v_id := seq_categoria.NEXTVAL;
        
        INSERT INTO Categoria (idCategoria, nombre, tipo)
        VALUES (v_id, p_nombre, p_tipo);
        
        COMMIT;
        RETURN t_respuesta(1, 'Categoría creada exitosamente', v_id);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END crear_categoria;

    FUNCTION actualizar_categoria(
        p_idCategoria IN NUMBER,
        p_nombre IN VARCHAR2,
        p_tipo IN VARCHAR2
    ) RETURN t_respuesta IS
        v_count NUMBER;
    BEGIN
        UPDATE Categoria 
        SET nombre = p_nombre, tipo = p_tipo
        WHERE idCategoria = p_idCategoria;
        
        v_count := SQL%ROWCOUNT;
        
        IF v_count > 0 THEN
            COMMIT;
            RETURN t_respuesta(1, 'Categoría actualizada exitosamente', p_idCategoria);
        ELSE
            RETURN t_respuesta(0, 'Categoría no encontrada', NULL);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END actualizar_categoria;

    FUNCTION eliminar_categoria(
        p_idCategoria IN NUMBER
    ) RETURN t_respuesta IS
        v_count NUMBER;
    BEGIN
        DELETE FROM Categoria WHERE idCategoria = p_idCategoria;
        v_count := SQL%ROWCOUNT;
        
        IF v_count > 0 THEN
            COMMIT;
            RETURN t_respuesta(1, 'Categoría eliminada exitosamente', p_idCategoria);
        ELSE
            RETURN t_respuesta(0, 'Categoría no encontrada', NULL);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END eliminar_categoria;

    FUNCTION obtener_categoria(
        p_idCategoria IN NUMBER
    ) RETURN t_categoria IS
        v_categoria t_categoria;
    BEGIN
        SELECT t_categoria(idCategoria, nombre, tipo)
        INTO v_categoria
        FROM Categoria
        WHERE idCategoria = p_idCategoria;
        
        RETURN v_categoria;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END obtener_categoria;

    FUNCTION listar_categorias RETURN t_categorias_tabla PIPELINED IS
    BEGIN
        FOR rec IN (SELECT * FROM Categoria ORDER BY nombre) LOOP
            PIPE ROW(t_categoria(rec.idCategoria, rec.nombre, rec.tipo));
        END LOOP;
        RETURN;
    END listar_categorias;

    FUNCTION insertar_categoria_rowtype(
        p_categoria IN Categoria%ROWTYPE
    ) RETURN t_respuesta IS
        v_id NUMBER;
    BEGIN
        v_id := seq_categoria.NEXTVAL;
        
        INSERT INTO Categoria VALUES (
            v_id,
            p_categoria.nombre,
            p_categoria.tipo
        );
        
        COMMIT;
        RETURN t_respuesta(1, 'Categoría creada desde ROWTYPE', v_id);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END insertar_categoria_rowtype;

END pkg_categoria;
/


-- ============================================================================
-- PAQUETE: PKG_CUENTA
-- ============================================================================

CREATE OR REPLACE PACKAGE pkg_cuenta AS
    FUNCTION crear_cuenta(
        p_nombre IN VARCHAR2,
        p_tipoCuenta IN VARCHAR2,
        p_saldoInicial IN NUMBER,
        p_descripcion IN CLOB DEFAULT NULL,
        p_moneda IN VARCHAR2 DEFAULT 'COP'
    ) RETURN t_respuesta;
    
    FUNCTION actualizar_cuenta(
        p_idCuenta IN NUMBER,
        p_nombre IN VARCHAR2,
        p_tipoCuenta IN VARCHAR2,
        p_descripcion IN CLOB
    ) RETURN t_respuesta;
    
    FUNCTION eliminar_cuenta(
        p_idCuenta IN NUMBER
    ) RETURN t_respuesta;
    
    FUNCTION obtener_cuenta(
        p_idCuenta IN NUMBER
    ) RETURN t_cuenta;
    
    FUNCTION listar_cuentas RETURN t_cuentas_tabla PIPELINED;
    
    FUNCTION insertar_cuenta_rowtype(
        p_cuenta IN Cuenta%ROWTYPE
    ) RETURN t_respuesta;
    
    -- Función para actualizar saldo
    FUNCTION actualizar_saldo(
        p_idCuenta IN NUMBER,
        p_monto IN NUMBER,
        p_operacion IN VARCHAR2 -- 'SUMAR' o 'RESTAR'
    ) RETURN t_respuesta;
END pkg_cuenta;
/

CREATE OR REPLACE PACKAGE BODY pkg_cuenta AS

    FUNCTION crear_cuenta(
        p_nombre IN VARCHAR2,
        p_tipoCuenta IN VARCHAR2,
        p_saldoInicial IN NUMBER,
        p_descripcion IN CLOB DEFAULT NULL,
        p_moneda IN VARCHAR2 DEFAULT 'COP'
    ) RETURN t_respuesta IS
        v_id NUMBER;
    BEGIN
        v_id := seq_cuenta.NEXTVAL;
        
        INSERT INTO Cuenta (
            idCuenta, nombre, tipoCuenta, saldoInicial, 
            saldoActual, descripcion, moneda
        ) VALUES (
            v_id, p_nombre, p_tipoCuenta, p_saldoInicial,
            p_saldoInicial, p_descripcion, p_moneda
        );
        
        COMMIT;
        RETURN t_respuesta(1, 'Cuenta creada exitosamente', v_id);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END crear_cuenta;

    FUNCTION actualizar_cuenta(
        p_idCuenta IN NUMBER,
        p_nombre IN VARCHAR2,
        p_tipoCuenta IN VARCHAR2,
        p_descripcion IN CLOB
    ) RETURN t_respuesta IS
        v_count NUMBER;
    BEGIN
        UPDATE Cuenta 
        SET nombre = p_nombre,
            tipoCuenta = p_tipoCuenta,
            descripcion = p_descripcion
        WHERE idCuenta = p_idCuenta;
        
        v_count := SQL%ROWCOUNT;
        
        IF v_count > 0 THEN
            COMMIT;
            RETURN t_respuesta(1, 'Cuenta actualizada exitosamente', p_idCuenta);
        ELSE
            RETURN t_respuesta(0, 'Cuenta no encontrada', NULL);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END actualizar_cuenta;

    FUNCTION eliminar_cuenta(
        p_idCuenta IN NUMBER
    ) RETURN t_respuesta IS
        v_count NUMBER;
    BEGIN
        DELETE FROM Cuenta WHERE idCuenta = p_idCuenta;
        v_count := SQL%ROWCOUNT;
        
        IF v_count > 0 THEN
            COMMIT;
            RETURN t_respuesta(1, 'Cuenta eliminada exitosamente', p_idCuenta);
        ELSE
            RETURN t_respuesta(0, 'Cuenta no encontrada', NULL);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END eliminar_cuenta;

    FUNCTION obtener_cuenta(
        p_idCuenta IN NUMBER
    ) RETURN t_cuenta IS
        v_cuenta t_cuenta;
    BEGIN
        SELECT t_cuenta(
            idCuenta, nombre, tipoCuenta, saldoInicial,
            saldoActual, descripcion, moneda
        )
        INTO v_cuenta
        FROM Cuenta
        WHERE idCuenta = p_idCuenta;
        
        RETURN v_cuenta;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END obtener_cuenta;

    FUNCTION listar_cuentas RETURN t_cuentas_tabla PIPELINED IS
    BEGIN
        FOR rec IN (SELECT * FROM Cuenta ORDER BY nombre) LOOP
            PIPE ROW(t_cuenta(
                rec.idCuenta, rec.nombre, rec.tipoCuenta,
                rec.saldoInicial, rec.saldoActual,
                rec.descripcion, rec.moneda
            ));
        END LOOP;
        RETURN;
    END listar_cuentas;

    FUNCTION insertar_cuenta_rowtype(
        p_cuenta IN Cuenta%ROWTYPE
    ) RETURN t_respuesta IS
        v_id NUMBER;
    BEGIN
        v_id := seq_cuenta.NEXTVAL;
        
        INSERT INTO Cuenta VALUES (
            v_id,
            p_cuenta.nombre,
            p_cuenta.tipoCuenta,
            p_cuenta.saldoInicial,
            p_cuenta.saldoInicial, -- saldoActual = saldoInicial
            p_cuenta.descripcion,
            p_cuenta.moneda
        );
        
        COMMIT;
        RETURN t_respuesta(1, 'Cuenta creada desde ROWTYPE', v_id);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END insertar_cuenta_rowtype;

    FUNCTION actualizar_saldo(
        p_idCuenta IN NUMBER,
        p_monto IN NUMBER,
        p_operacion IN VARCHAR2
    ) RETURN t_respuesta IS
        v_count NUMBER;
    BEGIN
        IF p_operacion = 'SUMAR' THEN
            UPDATE Cuenta 
            SET saldoActual = saldoActual + p_monto
            WHERE idCuenta = p_idCuenta;
        ELSIF p_operacion = 'RESTAR' THEN
            UPDATE Cuenta 
            SET saldoActual = saldoActual - p_monto
            WHERE idCuenta = p_idCuenta;
        ELSE
            RETURN t_respuesta(0, 'Operación inválida', NULL);
        END IF;
        
        v_count := SQL%ROWCOUNT;
        
        IF v_count > 0 THEN
            COMMIT;
            RETURN t_respuesta(1, 'Saldo actualizado exitosamente', p_idCuenta);
        ELSE
            RETURN t_respuesta(0, 'Cuenta no encontrada', NULL);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END actualizar_saldo;

END pkg_cuenta;
/


-- ============================================================================
-- PAQUETE: PKG_MOVIMIENTO
-- ============================================================================

CREATE OR REPLACE PACKAGE pkg_movimiento AS
    FUNCTION crear_movimiento(
        p_idUsuario IN NUMBER,
        p_idCategoria IN NUMBER,
        p_idCuenta IN NUMBER,
        p_idMetodoPago IN NUMBER,
        p_monto IN NUMBER,
        p_tipo IN VARCHAR2,
        p_descripcion IN CLOB DEFAULT NULL
    ) RETURN t_respuesta;
    
    FUNCTION actualizar_movimiento(
        p_idMovimiento IN NUMBER,
        p_idCategoria IN NUMBER,
        p_monto IN NUMBER,
        p_descripcion IN CLOB
    ) RETURN t_respuesta;
    
    FUNCTION eliminar_movimiento(
        p_idMovimiento IN NUMBER
    ) RETURN t_respuesta;
    
    FUNCTION obtener_movimiento(
        p_idMovimiento IN NUMBER
    ) RETURN t_movimiento;
    
    FUNCTION listar_movimientos RETURN t_movimientos_tabla PIPELINED;
    
    FUNCTION listar_movimientos_usuario(
        p_idUsuario IN NUMBER
    ) RETURN t_movimientos_tabla PIPELINED;
    
    FUNCTION insertar_movimiento_rowtype(
        p_movimiento IN Movimiento%ROWTYPE
    ) RETURN t_respuesta;
END pkg_movimiento;
/

CREATE OR REPLACE PACKAGE BODY pkg_movimiento AS

    FUNCTION crear_movimiento(
        p_idUsuario IN NUMBER,
        p_idCategoria IN NUMBER,
        p_idCuenta IN NUMBER,
        p_idMetodoPago IN NUMBER,
        p_monto IN NUMBER,
        p_tipo IN VARCHAR2,
        p_descripcion IN CLOB DEFAULT NULL
    ) RETURN t_respuesta IS
        v_id NUMBER;
        v_respuesta t_respuesta;
    BEGIN
        v_id := seq_movimiento.NEXTVAL;
        
        INSERT INTO Movimiento (
            idMovimiento, idUsuario, idCategoria, idCuenta,
            idMetodoPago, fecha, monto, tipo, descripcion
        ) VALUES (
            v_id, p_idUsuario, p_idCategoria, p_idCuenta,
            p_idMetodoPago, CURRENT_TIMESTAMP, p_monto, p_tipo, p_descripcion
        );
        
        -- Actualizar saldo de la cuenta
        IF p_tipo = 'INGRESO' THEN
            v_respuesta := pkg_cuenta.actualizar_saldo(p_idCuenta, p_monto, 'SUMAR');
        ELSIF p_tipo = 'EGRESO' THEN
            v_respuesta := pkg_cuenta.actualizar_saldo(p_idCuenta, p_monto, 'RESTAR');
        END IF;
        
        COMMIT;
        RETURN t_respuesta(1, 'Movimiento creado exitosamente', v_id);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END crear_movimiento;

    FUNCTION actualizar_movimiento(
        p_idMovimiento IN NUMBER,
        p_idCategoria IN NUMBER,
        p_monto IN NUMBER,
        p_descripcion IN CLOB
    ) RETURN t_respuesta IS
        v_count NUMBER;
    BEGIN
        UPDATE Movimiento 
        SET idCategoria = p_idCategoria,
            monto = p_monto,
            descripcion = p_descripcion
        WHERE idMovimiento = p_idMovimiento;
        
        v_count := SQL%ROWCOUNT;
        
        IF v_count > 0 THEN
            COMMIT;
            RETURN t_respuesta(1, 'Movimiento actualizado exitosamente', p_idMovimiento);
        ELSE
            RETURN t_respuesta(0, 'Movimiento no encontrado', NULL);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END actualizar_movimiento;

    FUNCTION eliminar_movimiento(
        p_idMovimiento IN NUMBER
    ) RETURN t_respuesta IS
        v_count NUMBER;
        v_monto NUMBER;
        v_tipo VARCHAR2(10);
        v_idCuenta NUMBER;
    BEGIN
        -- Obtener datos del movimiento antes de eliminarlo
        SELECT monto, tipo, idCuenta
        INTO v_monto, v_tipo, v_idCuenta
        FROM Movimiento
        WHERE idMovimiento = p_idMovimiento;
        
        -- Eliminar el movimiento
        DELETE FROM Movimiento WHERE idMovimiento = p_idMovimiento;
        v_count := SQL%ROWCOUNT;
        
        IF v_count > 0 THEN
            -- Revertir el efecto en el saldo
            IF v_tipo = 'INGRESO' THEN
                v_count := pkg_cuenta.actualizar_saldo(v_idCuenta, v_monto, 'RESTAR').codigo;
            ELSIF v_tipo = 'EGRESO' THEN
                v_count := pkg_cuenta.actualizar_saldo(v_idCuenta, v_monto, 'SUMAR').codigo;
            END IF;
            
            COMMIT;
            RETURN t_respuesta(1, 'Movimiento eliminado exitosamente', p_idMovimiento);
        ELSE
            RETURN t_respuesta(0, 'Movimiento no encontrado', NULL);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN t_respuesta(0, 'Movimiento no encontrado', NULL);
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END eliminar_movimiento;

    FUNCTION obtener_movimiento(
        p_idMovimiento IN NUMBER
    ) RETURN t_movimiento IS
        v_movimiento t_movimiento;
    BEGIN
        SELECT t_movimiento(
            idMovimiento, idUsuario, idCategoria, idCuenta,
            idMetodoPago, fecha, monto, tipo, descripcion
        )
        INTO v_movimiento
        FROM Movimiento
        WHERE idMovimiento = p_idMovimiento;
        
        RETURN v_movimiento;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END obtener_movimiento;

    FUNCTION listar_movimientos RETURN t_movimientos_tabla PIPELINED IS
    BEGIN
        FOR rec IN (SELECT * FROM Movimiento ORDER BY fecha DESC) LOOP
            PIPE ROW(t_movimiento(
                rec.idMovimiento, rec.idUsuario, rec.idCategoria,
                rec.idCuenta, rec.idMetodoPago, rec.fecha,
                rec.monto, rec.tipo, rec.descripcion
            ));
        END LOOP;
        RETURN;
    END listar_movimientos;

    FUNCTION listar_movimientos_usuario(
        p_idUsuario IN NUMBER
    ) RETURN t_movimientos_tabla PIPELINED IS
    BEGIN
        FOR rec IN (
            SELECT * FROM Movimiento 
            WHERE idUsuario = p_idUsuario 
            ORDER BY fecha DESC
        ) LOOP
            PIPE ROW(t_movimiento(
                rec.idMovimiento, rec.idUsuario, rec.idCategoria,
                rec.idCuenta, rec.idMetodoPago, rec.fecha,
                rec.monto, rec.tipo, rec.descripcion
            ));
        END LOOP;
        RETURN;
    END listar_movimientos_usuario;

    FUNCTION insertar_movimiento_rowtype(
        p_movimiento IN Movimiento%ROWTYPE
    ) RETURN t_respuesta IS
        v_id NUMBER;
    BEGIN
        v_id := seq_movimiento.NEXTVAL;
        
        INSERT INTO Movimiento VALUES (
            v_id,
            p_movimiento.idUsuario,
            p_movimiento.idCategoria,
            p_movimiento.idCuenta,
            p_movimiento.idMetodoPago,
            CURRENT_TIMESTAMP,
            p_movimiento.monto,
            p_movimiento.tipo,
            p_movimiento.descripcion
        );
        
        COMMIT;
        RETURN t_respuesta(1, 'Movimiento creado desde ROWTYPE', v_id);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END insertar_movimiento_rowtype;

END pkg_movimiento;
/


-- ============================================================================
-- PAQUETE: PKG_PRESUPUESTO
-- ============================================================================

CREATE OR REPLACE PACKAGE pkg_presupuesto AS
    FUNCTION crear_presupuesto(
        p_idCategoria IN NUMBER,
        p_nombre IN VARCHAR2,
        p_montoMaximo IN NUMBER,
        p_periodo IN VARCHAR2,
        p_fechaInicio IN DATE,
        p_fechaFin IN DATE
    ) RETURN t_respuesta;
    
    FUNCTION actualizar_presupuesto(
        p_idPresupuesto IN NUMBER,
        p_nombre IN VARCHAR2,
        p_montoMaximo IN NUMBER,
        p_periodo IN VARCHAR2
    ) RETURN t_respuesta;
    
    FUNCTION eliminar_presupuesto(
        p_idPresupuesto IN NUMBER
    ) RETURN t_respuesta;
    
    FUNCTION obtener_presupuesto(
        p_idPresupuesto IN NUMBER
    ) RETURN t_presupuesto;
    
    FUNCTION listar_presupuestos RETURN t_presupuestos_tabla PIPELINED;
    
    FUNCTION insertar_presupuesto_rowtype(
        p_presupuesto IN Presupuesto%ROWTYPE
    ) RETURN t_respuesta;
    
    -- Función para obtener el gasto actual vs presupuesto
    FUNCTION obtener_estado_presupuesto(
        p_idPresupuesto IN NUMBER
    ) RETURN VARCHAR2;
END pkg_presupuesto;
/

CREATE OR REPLACE PACKAGE BODY pkg_presupuesto AS

    FUNCTION crear_presupuesto(
        p_idCategoria IN NUMBER,
        p_nombre IN VARCHAR2,
        p_montoMaximo IN NUMBER,
        p_periodo IN VARCHAR2,
        p_fechaInicio IN DATE,
        p_fechaFin IN DATE
    ) RETURN t_respuesta IS
        v_id NUMBER;
    BEGIN
        v_id := seq_presupuesto.NEXTVAL;
        
        INSERT INTO Presupuesto (
            idPresupuesto, idCategoria, nombre, montoMaximo,
            periodo, fechaInicio, fechaFin
        ) VALUES (
            v_id, p_idCategoria, p_nombre, p_montoMaximo,
            p_periodo, p_fechaInicio, p_fechaFin
        );
        
        COMMIT;
        RETURN t_respuesta(1, 'Presupuesto creado exitosamente', v_id);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END crear_presupuesto;

    FUNCTION actualizar_presupuesto(
        p_idPresupuesto IN NUMBER,
        p_nombre IN VARCHAR2,
        p_montoMaximo IN NUMBER,
        p_periodo IN VARCHAR2
    ) RETURN t_respuesta IS
        v_count NUMBER;
    BEGIN
        UPDATE Presupuesto 
        SET nombre = p_nombre,
            montoMaximo = p_montoMaximo,
            periodo = p_periodo
        WHERE idPresupuesto = p_idPresupuesto;
        
        v_count := SQL%ROWCOUNT;
        
        IF v_count > 0 THEN
            COMMIT;
            RETURN t_respuesta(1, 'Presupuesto actualizado exitosamente', p_idPresupuesto);
        ELSE
            RETURN t_respuesta(0, 'Presupuesto no encontrado', NULL);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END actualizar_presupuesto;

    FUNCTION eliminar_presupuesto(
        p_idPresupuesto IN NUMBER
    ) RETURN t_respuesta IS
        v_count NUMBER;
    BEGIN
        DELETE FROM Presupuesto WHERE idPresupuesto = p_idPresupuesto;
        v_count := SQL%ROWCOUNT;
        
        IF v_count > 0 THEN
            COMMIT;
            RETURN t_respuesta(1, 'Presupuesto eliminado exitosamente', p_idPresupuesto);
        ELSE
            RETURN t_respuesta(0, 'Presupuesto no encontrado', NULL);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END eliminar_presupuesto;

    FUNCTION obtener_presupuesto(
        p_idPresupuesto IN NUMBER
    ) RETURN t_presupuesto IS
        v_presupuesto t_presupuesto;
    BEGIN
        SELECT t_presupuesto(
            idPresupuesto, idCategoria, nombre, montoMaximo,
            periodo, fechaInicio, fechaFin
        )
        INTO v_presupuesto
        FROM Presupuesto
        WHERE idPresupuesto = p_idPresupuesto;
        
        RETURN v_presupuesto;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END obtener_presupuesto;

    FUNCTION listar_presupuestos RETURN t_presupuestos_tabla PIPELINED IS
    BEGIN
        FOR rec IN (SELECT * FROM Presupuesto ORDER BY fechaInicio DESC) LOOP
            PIPE ROW(t_presupuesto(
                rec.idPresupuesto, rec.idCategoria, rec.nombre,
                rec.montoMaximo, rec.periodo, rec.fechaInicio, rec.fechaFin
            ));
        END LOOP;
        RETURN;
    END listar_presupuestos;

    FUNCTION insertar_presupuesto_rowtype(
        p_presupuesto IN Presupuesto%ROWTYPE
    ) RETURN t_respuesta IS
        v_id NUMBER;
    BEGIN
        v_id := seq_presupuesto.NEXTVAL;
        
        INSERT INTO Presupuesto VALUES (
            v_id,
            p_presupuesto.idCategoria,
            p_presupuesto.nombre,
            p_presupuesto.montoMaximo,
            p_presupuesto.periodo,
            p_presupuesto.fechaInicio,
            p_presupuesto.fechaFin
        );
        
        COMMIT;
        RETURN t_respuesta(1, 'Presupuesto creado desde ROWTYPE', v_id);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END insertar_presupuesto_rowtype;

    FUNCTION obtener_estado_presupuesto(
        p_idPresupuesto IN NUMBER
    ) RETURN VARCHAR2 IS
        v_gastado NUMBER;
        v_presupuesto NUMBER;
        v_porcentaje NUMBER;
        v_idCategoria NUMBER;
        v_fechaInicio DATE;
        v_fechaFin DATE;
    BEGIN
        -- Obtener datos del presupuesto
        SELECT idCategoria, montoMaximo, fechaInicio, fechaFin
        INTO v_idCategoria, v_presupuesto, v_fechaInicio, v_fechaFin
        FROM Presupuesto
        WHERE idPresupuesto = p_idPresupuesto;
        
        -- Calcular total gastado en el período
        SELECT NVL(SUM(monto), 0)
        INTO v_gastado
        FROM Movimiento
        WHERE idCategoria = v_idCategoria
          AND tipo = 'EGRESO'
          AND fecha BETWEEN v_fechaInicio AND v_fechaFin;
        
        v_porcentaje := ROUND((v_gastado / v_presupuesto) * 100, 2);
        
        RETURN 'Gastado: ' || v_gastado || ' de ' || v_presupuesto || 
               ' (' || v_porcentaje || '%)';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Presupuesto no encontrado';
        WHEN OTHERS THEN
            RETURN 'Error: ' || SQLERRM;
    END obtener_estado_presupuesto;

END pkg_presupuesto;
/


-- ============================================================================
-- PAQUETE: PKG_METODO_PAGO
-- ============================================================================

CREATE OR REPLACE PACKAGE pkg_metodo_pago AS
    FUNCTION crear_metodo_pago(
        p_nombre IN VARCHAR2,
        p_descripcion IN VARCHAR2
    ) RETURN t_respuesta;
    
    FUNCTION actualizar_metodo_pago(
        p_idMetodoPago IN NUMBER,
        p_nombre IN VARCHAR2,
        p_descripcion IN VARCHAR2
    ) RETURN t_respuesta;
    
    FUNCTION eliminar_metodo_pago(
        p_idMetodoPago IN NUMBER
    ) RETURN t_respuesta;
    
    FUNCTION insertar_metodo_rowtype(
        p_metodo IN MetodoPago%ROWTYPE
    ) RETURN t_respuesta;
END pkg_metodo_pago;
/

CREATE OR REPLACE PACKAGE BODY pkg_metodo_pago AS

    FUNCTION crear_metodo_pago(
        p_nombre IN VARCHAR2,
        p_descripcion IN VARCHAR2
    ) RETURN t_respuesta IS
        v_id NUMBER;
    BEGIN
        v_id := seq_metodopago.NEXTVAL;
        
        INSERT INTO MetodoPago (idMetodoPago, nombre, descripcion)
        VALUES (v_id, p_nombre, p_descripcion);
        
        COMMIT;
        RETURN t_respuesta(1, 'Método de pago creado exitosamente', v_id);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END crear_metodo_pago;

    FUNCTION actualizar_metodo_pago(
        p_idMetodoPago IN NUMBER,
        p_nombre IN VARCHAR2,
        p_descripcion IN VARCHAR2
    ) RETURN t_respuesta IS
        v_count NUMBER;
    BEGIN
        UPDATE MetodoPago 
        SET nombre = p_nombre,
            descripcion = p_descripcion
        WHERE idMetodoPago = p_idMetodoPago;
        
        v_count := SQL%ROWCOUNT;
        
        IF v_count > 0 THEN
            COMMIT;
            RETURN t_respuesta(1, 'Método de pago actualizado', p_idMetodoPago);
        ELSE
            RETURN t_respuesta(0, 'Método de pago no encontrado', NULL);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END actualizar_metodo_pago;

    FUNCTION eliminar_metodo_pago(
        p_idMetodoPago IN NUMBER
    ) RETURN t_respuesta IS
        v_count NUMBER;
    BEGIN
        DELETE FROM MetodoPago WHERE idMetodoPago = p_idMetodoPago;
        v_count := SQL%ROWCOUNT;
        
        IF v_count > 0 THEN
            COMMIT;
            RETURN t_respuesta(1, 'Método de pago eliminado', p_idMetodoPago);
        ELSE
            RETURN t_respuesta(0, 'Método de pago no encontrado', NULL);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END eliminar_metodo_pago;

    FUNCTION insertar_metodo_rowtype(
        p_metodo IN MetodoPago%ROWTYPE
    ) RETURN t_respuesta IS
        v_id NUMBER;
    BEGIN
        v_id := seq_metodopago.NEXTVAL;
        
        INSERT INTO MetodoPago VALUES (
            v_id,
            p_metodo.nombre,
            p_metodo.descripcion
        );
        
        COMMIT;
        RETURN t_respuesta(1, 'Método de pago creado desde ROWTYPE', v_id);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN t_respuesta(0, 'Error: ' || SQLERRM, NULL);
    END insertar_metodo_rowtype;

END pkg_metodo_pago;
/