-- ============================================================================
-- TIPOS DE DATOS Y COLECCIONES
-- ============================================================================

-- Tipos para Usuario
CREATE OR REPLACE TYPE t_usuario AS OBJECT (
    idUsuario NUMBER(10),
    nombre VARCHAR2(100),
    email VARCHAR2(150),
    password VARCHAR2(255),
    fechaRegistro TIMESTAMP
);
/

CREATE OR REPLACE TYPE t_usuarios_tabla IS TABLE OF t_usuario;
/

-- Tipos para Categoria
CREATE OR REPLACE TYPE t_categoria AS OBJECT (
    idCategoria NUMBER(10),
    nombre VARCHAR2(100),
    tipo VARCHAR2(50)
);
/

CREATE OR REPLACE TYPE t_categorias_tabla IS TABLE OF t_categoria;
/

-- Tipos para Cuenta
CREATE OR REPLACE TYPE t_cuenta AS OBJECT (
    idCuenta NUMBER(10),
    nombre VARCHAR2(150),
    tipoCuenta VARCHAR2(50),
    saldoInicial NUMBER(15,2),
    saldoActual NUMBER(15,2),
    descripcion CLOB,
    moneda VARCHAR2(10)
);
/

CREATE OR REPLACE TYPE t_cuentas_tabla IS TABLE OF t_cuenta;
/

-- Tipos para Movimiento
CREATE OR REPLACE TYPE t_movimiento AS OBJECT (
    idMovimiento NUMBER(10),
    idUsuario NUMBER(10),
    idCategoria NUMBER(10),
    idCuenta NUMBER(10),
    idMetodoPago NUMBER(10),
    fecha TIMESTAMP,
    monto NUMBER(15,2),
    tipo VARCHAR2(10),
    descripcion CLOB
);
/

CREATE OR REPLACE TYPE t_movimientos_tabla IS TABLE OF t_movimiento;
/

-- Tipos para Presupuesto
CREATE OR REPLACE TYPE t_presupuesto AS OBJECT (
    idPresupuesto NUMBER(10),
    idCategoria NUMBER(10),
    nombre VARCHAR2(150),
    montoMaximo NUMBER(15,2),
    periodo VARCHAR2(50),
    fechaInicio DATE,
    fechaFin DATE
);
/

CREATE OR REPLACE TYPE t_presupuestos_tabla IS TABLE OF t_presupuesto;
/

-- Tipo para respuestas genéricas
CREATE OR REPLACE TYPE t_respuesta AS OBJECT (
    codigo NUMBER,
    mensaje VARCHAR2(500),
    id_generado NUMBER
);
/