-- Crear la base de datos
CREATE DATABASE GestorDocumentalOIJ;
GO

-- Usar la base de datos
USE GestorDocumentalOIJ;
GO

--Crear un esquema
CREATE SCHEMA GD;
GO

CREATE SCHEMA SC;
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
    TN_NormaID INT NOT NULL,
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
    TN_ClasificacionID INT NOT NULL,
    CONSTRAINT FKClasificacion_Subclasificacion FOREIGN KEY (TN_ClasificacionID) REFERENCES GD.TGESTORDOCUMENTAL_Clasificacion(TN_Id)
);

-- Tabla DocTo
CREATE TABLE GD.TGESTORDOCUMENTAL_DocTo (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_DocTo PRIMARY KEY,
    TC_Nombre NVARCHAR(255) NOT NULL,
    TC_Descripcion NVARCHAR(500),
    TB_Eliminado BIT NOT NULL CONSTRAINT CKDocToEliminado DEFAULT 0
);


---------SEGURIDAD-------------- 

-- Tabla Rol
CREATE TABLE SC.TGESTORDOCUMENTAL_Rol (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Rol PRIMARY KEY,
    TC_Nombre NVARCHAR(255) NOT NULL,
    TC_Descripcion NVARCHAR(500),
    TB_Activo BIT NOT NULL CONSTRAINT DFRolActivo DEFAULT 1
);

-- Tabla Usuario
CREATE TABLE SC.TGESTORDOCUMENTAL_Usuario (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Usuario PRIMARY KEY,
    TC_Correo NVARCHAR(255) NOT NULL,
    TC_Nombre NVARCHAR(255) NOT NULL,
    TC_Apellido NVARCHAR(255) NOT NULL,
    TN_RolID INT NOT NULL,
	TB_Activo BIT NOT NULL CONSTRAINT DFUsuarioActivo DEFAULT 1,
	TB_Eliminado BIT NOT NULL CONSTRAINT DFUsuarioEliminado DEFAULT 0,
    CONSTRAINT FKRol_Usuario FOREIGN KEY (TN_RolID) REFERENCES SC.TGESTORDOCUMENTAL_Rol(TN_Id)
);


-- Tabla Oficina
CREATE TABLE SC.TGESTORDOCUMENTAL_Oficina (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Oficina PRIMARY KEY,
    TC_Nombre NVARCHAR(255) NOT NULL,
	TC_CodigoOficina NVARCHAR(255) NOT NULL,
    TN_GestorID BIT NOT NULL CONSTRAINT DFOficinaGestor DEFAULT 0,
    TB_Eliminado BIT NOT NULL CONSTRAINT DFOficinaEliminado DEFAULT 0
);


-- Tabla Oficina_Usuario
CREATE TABLE SC.TGESTORDOCUMENTAL_Oficina_Usuario (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Oficina_Usuario PRIMARY KEY,
    TN_OficinaID INT,
    TN_UsuarioID INT,
    TB_Eliminado BIT NOT NULL CONSTRAINT DFOficinaUsuarioEliminado DEFAULT 0,
    CONSTRAINT FKOficina_OficinaUsuario FOREIGN KEY (TN_OficinaID) REFERENCES SC.TGESTORDOCUMENTAL_Oficina(TN_Id),
    CONSTRAINT FKUsuario_OficinaUsuario FOREIGN KEY (TN_UsuarioID) REFERENCES SC.TGESTORDOCUMENTAL_Usuario(TN_Id)
);

CREATE TABLE SC.TGESTORDOCUMENTAL_Oficina_Gestor (
    TN_GestorID INT,
	TN_OficinaID INT,
    CONSTRAINT FKOficina_GestorID FOREIGN KEY (TN_GestorID) REFERENCES SC.TGESTORDOCUMENTAL_Oficina(TN_Id),
	CONSTRAINT FKOficina_OficinaID FOREIGN KEY (TN_OficinaID) REFERENCES SC.TGESTORDOCUMENTAL_Oficina(TN_Id)
);

----------SEGURIDAD------------

-- Tabla Bitacora
CREATE TABLE GD.TGESTORDOCUMENTAL_Bitacora (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Bitacora PRIMARY KEY,
    TC_Operacion NVARCHAR(255),
    TN_UsuarioID INT,
    TC_Comando NVARCHAR(MAX),
    TF_FechaHora DATETIME NOT NULL CONSTRAINT DFBitacoraFechaHora DEFAULT GETDATE(),
    TN_OficinaID INT,
    CONSTRAINT FKUsuario_Bitacora FOREIGN KEY (TN_UsuarioID) REFERENCES SC.TGESTORDOCUMENTAL_Usuario(TN_Id),
    CONSTRAINT FKOficina_Bitacora FOREIGN KEY (TN_OficinaID) REFERENCES SC.TGESTORDOCUMENTAL_Oficina(TN_Id)
);

-- Tabla Norma_Usuario
CREATE TABLE GD.TGESTORDOCUMENTAL_Norma_Usuario (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Norma_Usuario PRIMARY KEY,
    TN_NormaID INT,
    TN_UsuarioID INT,
    TB_Eliminado BIT NOT NULL CONSTRAINT DFNormaUsuarioEliminado DEFAULT 0,
    CONSTRAINT FKNorma_NormaUsuario FOREIGN KEY (TN_NormaID) REFERENCES GD.TGESTORDOCUMENTAL_Norma(TN_Id),
    CONSTRAINT FKUsuario_NormaUsuario FOREIGN KEY (TN_UsuarioID) REFERENCES SC.TGESTORDOCUMENTAL_Usuario(TN_Id)
);

-- Tabla Documento
CREATE TABLE GD.TGESTORDOCUMENTAL_Documento (
    TN_Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PKGESTORDOCUMENTAL_Documento PRIMARY KEY,
    TC_Codigo NVARCHAR(255),
    TC_Asunto NVARCHAR(255),
    TC_Descripcion NVARCHAR(1000),
    TC_PalabraClave NVARCHAR(255),
    TN_CategoriaID INT,
    TN_TipoDocumento INT,
    TN_OficinaID INT, 
    TC_Vigencia NVARCHAR(255),
    TN_EtapaID INT,
    TN_DocTo INT,
    TB_Activo BIT,
    TB_Descargable BIT,
    TB_Eliminado BIT NOT NULL CONSTRAINT DFDocumentoEliminado DEFAULT 0,
    TN_SubClasificacionID INT,
    CONSTRAINT FKTipoDocumento_Documento FOREIGN KEY (TN_TipoDocumento) REFERENCES GD.TGESTORDOCUMENTAL_TipoDocumento(TN_Id),
	CONSTRAINT FKTOficinaID_Documento FOREIGN KEY (TN_OficinaID) REFERENCES SC.TGESTORDOCUMENTAL_Oficina(TN_Id),
    CONSTRAINT FKDocTo_Documento FOREIGN KEY (TN_DocTo) REFERENCES GD.TGESTORDOCUMENTAL_DocTo(TN_Id),
    CONSTRAINT FKCategoria_Documento FOREIGN KEY (TN_CategoriaID) REFERENCES GD.TGESTORDOCUMENTAL_Categoria(TN_Id),
    CONSTRAINT FKEtapa_Documento FOREIGN KEY (TN_EtapaID) REFERENCES GD.TGESTORDOCUMENTAL_Etapa(TN_Id),
    CONSTRAINT FKSubClasificacion_Documento FOREIGN KEY (TN_SubClasificacionID) REFERENCES GD.TGESTORDOCUMENTAL_Subclasificacion(TN_Id)
);

CREATE TABLE GD.TGESTORDOCUMENTAL_Documento_Documento(
    TN_DocumentoID INT,
    TN_DocTo INT,
    TC_DocRelaciona NVARCHAR(255),
    CONSTRAINT FKDocTo_Documento_Documento FOREIGN KEY (TN_DocTo) REFERENCES GD.TGESTORDOCUMENTAL_DocTo(TN_Id),
    CONSTRAINT FKDocumento_Documento FOREIGN KEY (TN_DocumentoID) REFERENCES GD.TGESTORDOCUMENTAL_Documento(TN_Id)
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
    TB_DocDinamico BIT NOT NULL CONSTRAINT DFVersionDocDinamico DEFAULT 0,
    TB_Obsoleto BIT NOT NULL CONSTRAINT DFVersionObsoleto DEFAULT 0,
    TC_NumeroSCD NVARCHAR(200),
    TC_Justificacion NVARCHAR(500) NOT NULL,
    CONSTRAINT FKDocumento_Version FOREIGN KEY (TN_DocumentoID) REFERENCES GD.TGESTORDOCUMENTAL_Documento(TN_Id),
    CONSTRAINT FKUsuario_Version FOREIGN KEY (TN_UsuarioID) REFERENCES SC.TGESTORDOCUMENTAL_Usuario(TN_Id)
);