-- Insertar datos de ejemplo

-- Categorías
INSERT INTO Categoria (idCategoria, nombre, tipo) VALUES (seq_categoria.NEXTVAL, 'Alimentación', 'EGRESO');
INSERT INTO Categoria (idCategoria, nombre, tipo) VALUES (seq_categoria.NEXTVAL, 'Transporte', 'EGRESO');
INSERT INTO Categoria (idCategoria, nombre, tipo) VALUES (seq_categoria.NEXTVAL, 'Salario', 'INGRESO');
INSERT INTO Categoria (idCategoria, nombre, tipo) VALUES (seq_categoria.NEXTVAL, 'Entretenimiento', 'EGRESO');
INSERT INTO Categoria (idCategoria, nombre, tipo) VALUES (seq_categoria.NEXTVAL, 'Servicios', 'EGRESO');

-- Métodos de pago
INSERT INTO MetodoPago (idMetodoPago, nombre, descripcion) VALUES (seq_metodopago.NEXTVAL, 'Efectivo', 'Pago en efectivo');
INSERT INTO MetodoPago (idMetodoPago, nombre, descripcion) VALUES (seq_metodopago.NEXTVAL, 'Tarjeta de Débito', 'Pago con tarjeta de débito');
INSERT INTO MetodoPago (idMetodoPago, nombre, descripcion) VALUES (seq_metodopago.NEXTVAL, 'Tarjeta de Crédito', 'Pago con tarjeta de crédito');
INSERT INTO MetodoPago (idMetodoPago, nombre, descripcion) VALUES (seq_metodopago.NEXTVAL, 'Transferencia', 'Transferencia bancaria');

-- Cuentas
INSERT INTO Cuenta (idCuenta, nombre, tipoCuenta, saldoInicial, saldoActual, descripcion) 
VALUES (seq_cuenta.NEXTVAL, 'Cuenta Corriente Principal', 'Corriente', 1000000.00, 1000000.00, 'Cuenta principal de ahorros');

INSERT INTO Cuenta (idCuenta, nombre, tipoCuenta, saldoInicial, saldoActual, descripcion) 
VALUES (seq_cuenta.NEXTVAL, 'Tarjeta Crédito Visa', 'Crédito', 0.00, 0.00, 'Tarjeta de crédito Visa');

COMMIT;
