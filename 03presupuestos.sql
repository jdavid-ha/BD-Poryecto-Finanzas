-- Tabla Presupuesto
CREATE TABLE Presupuesto (
    idPresupuesto NUMBER(10) PRIMARY KEY,
    idCategoria NUMBER(10) NOT NULL,
    nombre VARCHAR2(150) NOT NULL,
    montoMaximo NUMBER(15,2) NOT NULL,
    periodo VARCHAR2(50) NOT NULL,
    fechaInicio DATE NOT NULL,
    fechaFin DATE NOT NULL,
    CONSTRAINT fk_presupuesto_categoria FOREIGN KEY (idCategoria) 
        REFERENCES Categoria(idCategoria) ON DELETE CASCADE
);

-- Tabla de relación Categoria_Presupuesto
CREATE TABLE Categoria_Presupuesto (
    idCategoria NUMBER(10) NOT NULL,
    idPresupuesto NUMBER(10) NOT NULL,
    PRIMARY KEY (idCategoria, idPresupuesto),
    CONSTRAINT fk_catpre_categoria FOREIGN KEY (idCategoria) 
        REFERENCES Categoria(idCategoria) ON DELETE CASCADE,
    CONSTRAINT fk_catpre_presupuesto FOREIGN KEY (idPresupuesto) 
        REFERENCES Presupuesto(idPresupuesto) ON DELETE CASCADE
);
