-- Crear la base de datos
CREATE DATABASE GestorDocumentalOIJ;
GO

-- Usar la base de datos
USE GestorDocumentalOIJ;
GO

--Crear un esquema
CREATE SCHEMA GD;
GO

-- Tabla TipoDocumento
CREATE TABLE GD.TGESTORDOCUMENTAL_TipoDocumento (
    TN_ID INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_TipoDocumento PRIMARY KEY,
    TC_Nombre NVARCHAR(255) NOT NULL,
    TC_Descripcion NVARCHAR(500),
    TB_Eliminado BIT NOT NULL CONSTRAINT CKTipoDocumentoEliminado DEFAULT 0
);

-- Tabla Norma
CREATE TABLE GD.TGESTORDOCUMENTAL_Norma (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Norma PRIMARY KEY,
    TC_Nombre NVARCHAR(255) NOT NULL,
    TC_Descripcion NVARCHAR(500),
    TB_Eliminado BIT NOT NULL CONSTRAINT CKNormaEliminado DEFAULT 0
);

-- Tabla Etapa
CREATE TABLE GD.TGESTORDOCUMENTAL_Etapa (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Etapa PRIMARY KEY,
    TC_Nombre NVARCHAR(255) NOT NULL,
    TC_Descripcion NVARCHAR(500),
	TC_Color VARCHAR(500),
    TB_Eliminado BIT NOT NULL CONSTRAINT CKEtapaEliminado DEFAULT 0,
    TN_NormaID INT,
    CONSTRAINT FKNorma_Etapa FOREIGN KEY (TN_NormaID) REFERENCES GD.TGESTORDOCUMENTAL_Norma(TN_Id)
);

CREATE TABLE GD.TGESTORDOCUMENTAL_Etapa_Etapa (
    TN_EtapaPadreID INT,
	TN_EtapaID INT,
    CONSTRAINT FKEtapa_EtapaPadre FOREIGN KEY (TN_EtapaPadreID) REFERENCES GD.TGESTORDOCUMENTAL_Etapa(TN_Id),
	CONSTRAINT FKEtapa_Etapa FOREIGN KEY (TN_EtapaID) REFERENCES GD.TGESTORDOCUMENTAL_Etapa(TN_Id)
);

-- Tabla Categoria
CREATE TABLE GD.TGESTORDOCUMENTAL_Categoria (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Categoria PRIMARY KEY,
    TC_Nombre NVARCHAR(255) NOT NULL,
    TC_Descripcion NVARCHAR(500),
    TB_Eliminado BIT NOT NULL CONSTRAINT CKCategoriaEliminado DEFAULT 0
);


-- Tabla Clasificacion
CREATE TABLE GD.TGESTORDOCUMENTAL_Clasificacion (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Clasificacion PRIMARY KEY,
    TC_Nombre NVARCHAR(255) NOT NULL,
    TC_Descripcion NVARCHAR(500),
    TB_Eliminado BIT NOT NULL CONSTRAINT CKClasificacionEliminado DEFAULT 0
);

-- Tabla Subclasificacion
CREATE TABLE GD.TGESTORDOCUMENTAL_Subclasificacion (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Subclasificacion PRIMARY KEY,
    TC_Nombre NVARCHAR(255) NOT NULL,
    TC_Descripcion NVARCHAR(500),
    TB_Eliminado BIT NOT NULL CONSTRAINT CKSubclasificacionEliminado DEFAULT 0,
    TN_ClasificacionID INT,
    CONSTRAINT FKClasificacion_Subclasificacion FOREIGN KEY (TN_ClasificacionID) REFERENCES GD.TGESTORDOCUMENTAL_Clasificacion(TN_Id)
);

-- Tabla DocTo
CREATE TABLE GD.TGESTORDOCUMENTAL_DocTo (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_DocTo PRIMARY KEY,
    TC_Nombre NVARCHAR(255) NOT NULL,
    TC_Descripcion NVARCHAR(500),
    TB_Eliminado BIT NOT NULL CONSTRAINT CKDocToEliminado DEFAULT 0
);

-- Tabla Usuario
CREATE TABLE GD.TGESTORDOCUMENTAL_Usuario (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Usuario PRIMARY KEY,
    TC_Correo NVARCHAR(255) NOT NULL,
    TC_Nombre NVARCHAR(255) NOT NULL,
    TC_Apellido NVARCHAR(255) NOT NULL,
    TN_RolID INT,
    CONSTRAINT FKRol_Usuario FOREIGN KEY (TN_RolID) REFERENCES GD.TGESTORDOCUMENTAL_Rol(TN_Id)
);

-- Tabla Rol
CREATE TABLE GD.TGESTORDOCUMENTAL_Rol (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Rol PRIMARY KEY,
    TC_Nombre NVARCHAR(255) NOT NULL,
    TC_Descripcion NVARCHAR(500),
    TB_Activo BIT NOT NULL CONSTRAINT DFRolActivo DEFAULT 1
);

-- Tabla Oficina
CREATE TABLE GD.TGESTORDOCUMENTAL_Oficina (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Oficina PRIMARY KEY,
    TC_Nombre NVARCHAR(255) NOT NULL,
    TN_GestorID INT,
    TB_Eliminado BIT NOT NULL CONSTRAINT DFOficinaEliminado DEFAULT 0
);

-- Tabla Oficina_Usuario
CREATE TABLE GD.TGESTORDOCUMENTAL_Oficina_Usuario (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Oficina_Usuario PRIMARY KEY,
    TN_OficinaID INT,
    TN_UsuarioID INT,
    TB_Eliminado BIT NOT NULL CONSTRAINT DFOficinaUsuarioEliminado DEFAULT 0,
    CONSTRAINT FKOficina_OficinaUsuario FOREIGN KEY (TN_OficinaID) REFERENCES GD.TGESTORDOCUMENTAL_Oficina(TN_Id),
    CONSTRAINT FKUsuario_OficinaUsuario FOREIGN KEY (TN_UsuarioID) REFERENCES GD.TGESTORDOCUMENTAL_Usuario(TN_Id)
);

-- Tabla Bitacora
CREATE TABLE GD.TGESTORDOCUMENTAL_Bitacora (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Bitacora PRIMARY KEY,
    TC_Operacion NVARCHAR(255),
    TN_UsuarioID INT,
    TC_Comando NVARCHAR(255),
    TF_FechaHora DATETIME NOT NULL CONSTRAINT DFBitacoraFechaHora DEFAULT GETDATE(),
    TN_OficinaID INT,
    CONSTRAINT FKUsuario_Bitacora FOREIGN KEY (TN_UsuarioID) REFERENCES GD.TGESTORDOCUMENTAL_Usuario(TN_Id),
    CONSTRAINT FKOficina_Bitacora FOREIGN KEY (TN_OficinaID) REFERENCES GD.TGESTORDOCUMENTAL_Oficina(TN_Id)
);

-- Tabla Norma_Usuario
CREATE TABLE GD.TGESTORDOCUMENTAL_Norma_Usuario (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Norma_Usuario PRIMARY KEY,
    TN_NormaID INT,
    TN_UsuarioID INT,
    TB_Eliminado BIT NOT NULL CONSTRAINT DFNormaUsuarioEliminado DEFAULT 0,
    CONSTRAINT FKNorma_NormaUsuario FOREIGN KEY (TN_NormaID) REFERENCES GD.TGESTORDOCUMENTAL_Norma(TN_Id),
    CONSTRAINT FKUsuario_NormaUsuario FOREIGN KEY (TN_UsuarioID) REFERENCES GD.TGESTORDOCUMENTAL_Usuario(TN_Id)
);

-- Tabla Documento
CREATE TABLE GD.TGESTORDOCUMENTAL_Documento (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Documento PRIMARY KEY,
    TC_Codigo NVARCHAR(255),
    TC_Asunto NVARCHAR(255),
    TC_Descripcion NVARCHAR(1000),
    TC_PalabraClave NVARCHAR(255),
    TN_CategoriaID INT,
    TN_EtapaID INT,
    TN_DocTo INT,
    TB_Activo BIT,
    TB_Descargable BIT,
    TB_Eliminado BIT NOT NULL CONSTRAINT DFDocumentoEliminado DEFAULT 0,
    TN_SubClasificacionID INT,
    TN_RelacionesDoc INT,
    TN_ClasificacionID INT,
    CONSTRAINT FKCategoria_Documento FOREIGN KEY (TN_CategoriaID) REFERENCES GD.TGESTORDOCUMENTAL_Categoria(TN_Id),
    CONSTRAINT FKEtapa_Documento FOREIGN KEY (TN_EtapaID) REFERENCES GD.TGESTORDOCUMENTAL_Etapa(TN_Id),
    CONSTRAINT FKSubClasificacion_Documento FOREIGN KEY (TN_SubClasificacionID) REFERENCES GD.TGESTORDOCUMENTAL_Subclasificacion(TN_Id),
    CONSTRAINT FKClasificacion_Documento FOREIGN KEY (TN_ClasificacionID) REFERENCES GD.TGESTORDOCUMENTAL_Clasificacion(TN_Id)
);

-- Tabla Version
CREATE TABLE GD.TGESTORDOCUMENTAL_Version (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Version PRIMARY KEY,
    TN_DocumentoID INT,
    TN_NumeroVersion INT NOT NULL,
    TF_FechaCreacion DATETIME NOT NULL CONSTRAINT DFVersionFechaCreacion DEFAULT GETDATE(),
    TC_UrlVersion NVARCHAR(500),
    TB_Eliminado BIT NOT NULL CONSTRAINT DFVersionEliminado DEFAULT 0,
    TN_UsuarioID INT,
    CONSTRAINT FKDocumento_Version FOREIGN KEY (TN_DocumentoID) REFERENCES GD.TGESTORDOCUMENTAL_Documento(TN_Id),
    CONSTRAINT FKUsuario_Version FOREIGN KEY (TN_UsuarioID) REFERENCES GD.TGESTORDOCUMENTAL_Usuario(TN_Id)
);