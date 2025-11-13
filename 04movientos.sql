-- Tabla Movimiento
CREATE TABLE Movimiento (
    idMovimiento NUMBER(10) PRIMARY KEY,
    idUsuario NUMBER(10) NOT NULL,
    idCategoria NUMBER(10) NOT NULL,
    idCuenta NUMBER(10) NOT NULL,
    idMetodoPago NUMBER(10) NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    monto NUMBER(15,2) NOT NULL,
    tipo VARCHAR2(10) CHECK (tipo IN ('INGRESO', 'EGRESO')) NOT NULL,
    descripcion CLOB,
    CONSTRAINT fk_movimiento_usuario FOREIGN KEY (idUsuario) 
        REFERENCES Usuario(idUsuario),
    CONSTRAINT fk_movimiento_categoria FOREIGN KEY (idCategoria) 
        REFERENCES Categoria(idCategoria),
    CONSTRAINT fk_movimiento_cuenta FOREIGN KEY (idCuenta) 
        REFERENCES Cuenta(idCuenta),
    CONSTRAINT fk_movimiento_metodopago FOREIGN KEY (idMetodoPago) 
        REFERENCES MetodoPago(idMetodoPago)
);
