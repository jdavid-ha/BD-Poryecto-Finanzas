-- Índices para mejorar el rendimiento
CREATE INDEX idx_movimiento_fecha ON Movimiento(fecha);
CREATE INDEX idx_movimiento_tipo ON Movimiento(tipo);
CREATE INDEX idx_movimiento_usuario ON Movimiento(idUsuario);

CREATE INDEX idx_presupuesto_periodo ON Presupuesto(periodo);
CREATE INDEX idx_presupuesto_fechas ON Presupuesto(fechaInicio, fechaFin);
