-- Crear la base de datos
CREATE DATABASE GestorDocumentalOIJ;
GO

-- Usar la base de datos
USE GestorDocumentalOIJ;
GO

-- Tabla TipoDocumento
CREATE TABLE TipoDocumento (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(255) NOT NULL,
    Descripcion NVARCHAR(500),
    Eliminado BIT DEFAULT 0
);

-- Tabla Etapa
CREATE TABLE Etapa (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(255) NOT NULL,
    Descripcion NVARCHAR(500),
    Eliminado BIT DEFAULT 0,
    NormaID INT,
    FOREIGN KEY (NormaID) REFERENCES Norma(Id)
);

-- Tabla Documento
CREATE TABLE Documento (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Codigo NVARCHAR(255),
    Asunto NVARCHAR(255),
    Descripcion NVARCHAR(1000),
    PalabraClave NVARCHAR(255),
    CategoriaID INT,
    EtapaID INT,
    DocTo INT,
    Activo BIT,
    Descargable BIT,
    Eliminado BIT DEFAULT 0,
    SubClasificacionID INT,
    RelacionesDoc INT,
    ClasificacionID INT,
    FOREIGN KEY (CategoriaID) REFERENCES Categoria(Id),
    FOREIGN KEY (EtapaID) REFERENCES Etapa(Id),
    FOREIGN KEY (SubClasificacionID) REFERENCES Subclasificacion(Id),
    FOREIGN KEY (ClasificacionID) REFERENCES Clasificacion(Id)
);

-- Tabla Version
CREATE TABLE Version (
    Id INT PRIMARY KEY IDENTITY(1,1),
    DocumentoID INT,
    NumeroVersion INT NOT NULL,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    UrlVersion NVARCHAR(500),
    Eliminado BIT DEFAULT 0,
    UsuarioID INT,
    FOREIGN KEY (DocumentoID) REFERENCES Documento(Id),
    FOREIGN KEY (UsuarioID) REFERENCES Usuario(Id)
);

-- Tabla Norma
CREATE TABLE Norma (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(255) NOT NULL,
    Descripcion NVARCHAR(500),
    Eliminado BIT DEFAULT 0
);

-- Tabla Categoria
CREATE TABLE Categoria (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(255) NOT NULL,
    Descripcion NVARCHAR(500),
    Eliminado BIT DEFAULT 0
);

-- Tabla Clasificacion
CREATE TABLE Clasificacion (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(255) NOT NULL,
    Descripcion NVARCHAR(500),
    Eliminado BIT DEFAULT 0
);

-- Tabla Subclasificacion
CREATE TABLE Subclasificacion (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(255) NOT NULL,
    Descripcion NVARCHAR(500),
    Eliminado BIT DEFAULT 0
);

-- Tabla Usuario
CREATE TABLE Usuario (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Correo NVARCHAR(255) NOT NULL,
    Nombre NVARCHAR(255) NOT NULL,
    Apellido NVARCHAR(255) NOT NULL,
    RolID INT,
    FOREIGN KEY (RolID) REFERENCES Rol(Id)
);

-- Tabla Rol
CREATE TABLE Rol (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(255) NOT NULL,
    Descripcion NVARCHAR(500),
    Activo BIT DEFAULT 1
);

-- Tabla Oficina
CREATE TABLE Oficina (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(255) NOT NULL,
    GestorID INT,
    Eliminado BIT DEFAULT 0
);

-- Tabla Oficina_Usuario
CREATE TABLE Oficina_Usuario (
    Id INT PRIMARY KEY IDENTITY(1,1),
    OficinaID INT,
    UsuarioID INT,
    Eliminado BIT DEFAULT 0,
    FOREIGN KEY (OficinaID) REFERENCES Oficina(Id),
    FOREIGN KEY (UsuarioID) REFERENCES Usuario(Id)
);

-- Tabla DocTo
CREATE TABLE DocTo (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(255) NOT NULL,
    Descripcion NVARCHAR(500),
    Eliminado BIT DEFAULT 0
);

-- Tabla Norma_Usuario
CREATE TABLE Norma_Usuario (
    Id INT PRIMARY KEY IDENTITY(1,1),
    NormaID INT,
    UsuarioID INT,
    Eliminado BIT DEFAULT 0,
    FOREIGN KEY (NormaID) REFERENCES Norma(Id),
    FOREIGN KEY (UsuarioID) REFERENCES Usuario(Id)
);

-- Tabla Bitacora
CREATE TABLE Bitacora (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Operacion NVARCHAR(255),
    Usuario NVARCHAR(255),
    FechaHora DATETIME DEFAULT GETDATE(),
    Comando NVARCHAR(255),
    OficinaID INT,
    InstitucionID INT
);
