-- Tabla Categoria
CREATE TABLE Categoria (
    idCategoria NUMBER(10) PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    tipo VARCHAR2(50) NOT NULL
);

-- Tabla Usuario
CREATE TABLE Usuario (
    idUsuario NUMBER(10) PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    email VARCHAR2(150) UNIQUE NOT NULL,
    password VARCHAR2(255) NOT NULL,
    fechaRegistro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla MetodoPago
CREATE TABLE MetodoPago (
    idMetodoPago NUMBER(10) PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    descripcion VARCHAR2(255)
);

-- Tabla Cuenta
CREATE TABLE Cuenta (
    idCuenta NUMBER(10) PRIMARY KEY,
    nombre VARCHAR2(150) NOT NULL,
    tipoCuenta VARCHAR2(50) NOT NULL,
    saldoInicial NUMBER(15,2) DEFAULT 0.00 NOT NULL,
    saldoActual NUMBER(15,2) DEFAULT 0.00 NOT NULL,
    descripcion CLOB,
    moneda VARCHAR2(10) DEFAULT 'COP'
);
