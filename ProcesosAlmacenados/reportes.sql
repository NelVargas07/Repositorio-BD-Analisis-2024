--USE GestorDocumentalOIJ

--1 LISTO --
CREATE OR ALTER PROCEDURE GD.PA_ReporteBitacoraDeMovimiento
    @pC_CodigoDocumento NVARCHAR(255) = NULL,
    @pC_NombreDocumento NVARCHAR(255) = NULL,
	@pN_UsuarioID INT = NULL,
	@pN_OficinaID INT = NULL,
    @pF_FechaInicio DATE = NULL,
    @pF_FechaFinal DATE = NULL
AS
BEGIN

    BEGIN
        IF @pN_OficinaID = 0 SET @pN_OficinaID = NULL
        IF @pC_NombreDocumento = '' SET @pC_NombreDocumento = NULL
        IF @pN_UsuarioID = 0 SET @pN_UsuarioID = NULL
        IF @pC_CodigoDocumento = '' SET @pC_CodigoDocumento = NULL
        IF @pF_FechaInicio = '' SET @pF_FechaInicio = NULL
        IF @pF_FechaFinal = '' SET @pF_FechaFinal = NULL
    END;

    WITH Versiones AS (
        SELECT 
            V.TN_Id AS VersionID,
            V.TN_DocumentoID,
            V.TC_UrlVersion,
            V.TN_NumeroVersion,
            V.TF_FechaCreacion,
            ROW_NUMBER() OVER (PARTITION BY V.TN_DocumentoID ORDER BY V.TN_NumeroVersion DESC, V.TF_FechaCreacion DESC) AS rn
        FROM GD.TGESTORDOCUMENTAL_Version V
    )

    SELECT 
        D.TC_Codigo AS CodigoDocumento,
        D.TC_Asunto AS NombreDocumento,
        C.TC_Nombre AS Acceso,
        V.TN_NumeroVersion AS Version,
        V.TF_FechaCreacion AS FechaIngreso,
        U.TC_Nombre AS Usuario,
        CASE 
        WHEN BM.TB_Movimiento = 0 
        THEN 'Visualizado' ELSE 'Descargado' END AS Movimiento,
        O.TC_Nombre AS OficinaResponsable
    FROM 
        GD.TGESTORDOCUMENTAL_BitacoraMovimientos BM
    JOIN 
        Versiones V ON V.VersionID = BM.TN_VersionID 
    JOIN 
        GD.TGESTORDOCUMENTAL_Documento D ON D.TN_Id = V.TN_DocumentoID 
    JOIN 
        GD.TGESTORDOCUMENTAL_Categoria C ON C.TN_Id = D.TN_CategoriaID
    JOIN 
        SC.TGESTORDOCUMENTAL_Usuario U ON U.TN_Id = @pN_UsuarioID AND @pN_UsuarioID IS NOT NULL
    JOIN 
        SC.TGESTORDOCUMENTAL_Oficina O ON O.TN_Id = @pN_OficinaID AND @pN_OficinaID IS NOT NULL
    WHERE 
        (@pC_CodigoDocumento IS NULL OR D.TC_Codigo = @pC_CodigoDocumento)
        AND (@pC_NombreDocumento IS NULL OR D.TC_Asunto LIKE '%' + @pC_NombreDocumento + '%')
        AND (@pF_FechaInicio IS NULL OR CONVERT(DATE, V.TF_FechaCreacion) >= @pF_FechaInicio)
        AND (@pF_FechaFinal IS NULL OR CONVERT(DATE, V.TF_FechaCreacion) <= @pF_FechaFinal)
END

--2 LISTO --
CREATE OR ALTER PROCEDURE GD.PA_ReporteControlDeVersiones
    @pN_OficinaID INT = NULL,
    @pC_CodigoDocumento NVARCHAR(255) = NULL,
    @pC_NombreDocumento NVARCHAR(255) = NULL,
    @pN_TipoDocumento INT = NULL
AS
BEGIN
    BEGIN
        IF @pN_OficinaID = 0 SET @pN_OficinaID = NULL
        IF @pC_NombreDocumento = '' SET @pC_NombreDocumento = NULL
        IF @pN_TipoDocumento = 0 SET @pN_TipoDocumento = NULL
        IF @pC_CodigoDocumento = '' SET @pC_CodigoDocumento = NULL
    END;

    SELECT 
        D.TC_Codigo AS CodigoDocumento,
        D.TC_Asunto AS NombreDocumento,
        TD.TC_Nombre AS TipoDocumento,
        V.TC_NumeroSCD AS SCD,
        V.TN_NumeroVersion AS Version,
        V.TF_FechaCreacion AS Fecha,
        V.TC_Justificacion AS ResumenDelCambio
    FROM GD.TGESTORDOCUMENTAL_Version V
    JOIN GD.TGESTORDOCUMENTAL_Documento D ON D.TN_Id = V.TN_DocumentoID
    JOIN GD.TGESTORDOCUMENTAL_TipoDocumento TD ON TD.TN_Id = D.TN_TipoDocumento
    WHERE 
        (@pC_CodigoDocumento IS NULL OR D.TC_Codigo = @pC_CodigoDocumento) AND
        (@pC_NombreDocumento IS NULL OR D.TC_Asunto LIKE '%' + @pC_NombreDocumento + '%') AND
        (@pN_TipoDocumento IS NULL OR TD.TN_Id = @pN_TipoDocumento) AND
        (@pN_OficinaID IS NULL OR D.TN_OficinaID = @pN_OficinaID)
END
GO

--3 LISTO --
CREATE OR ALTER PROCEDURE GD.PA_ReporteDocumentosAntiguos
    @pN_OficinaID INT = NULL,
    @pN_TipoDocumento INT = NULL,
    @pF_Fecha DATE = NULL
AS
BEGIN

    BEGIN
        IF @pN_OficinaID = 0 SET @pN_OficinaID = NULL
        IF @pN_TipoDocumento = 0 SET @pN_TipoDocumento = NULL
        IF @pF_Fecha = '' SET @pF_Fecha = NULL
    END;

    WITH Versiones AS (
        SELECT 
            V.TN_Id AS VersionID,
            V.TN_DocumentoID,
            V.TC_UrlVersion,
            V.TN_NumeroVersion,
            V.TF_FechaCreacion,
            ROW_NUMBER() OVER (PARTITION BY V.TN_DocumentoID ORDER BY V.TN_NumeroVersion DESC, V.TF_FechaCreacion DESC) AS rn
        FROM GD.TGESTORDOCUMENTAL_Version V
    )

    SELECT 
        D.TC_Codigo AS CodigoDocumento,
        D.TC_Asunto AS NombreDocumento,
        C.TC_Nombre AS Acceso,  -- Interpretando acceso como categoría
        V.TN_NumeroVersion AS Version,
        V.TF_FechaCreacion AS Fecha,
        O.TC_Nombre AS OficinaResponsable
    FROM GD.TGESTORDOCUMENTAL_Documento D
    JOIN Versiones V ON D.TN_Id = V.TN_DocumentoID AND V.rn = 1
    JOIN GD.TGESTORDOCUMENTAL_Categoria C ON C.TN_Id = D.TN_CategoriaID
    JOIN SC.TGESTORDOCUMENTAL_Oficina O ON O.TN_Id = D.TN_OficinaID
    WHERE 
        (@pN_OficinaID IS NULL OR D.TN_OficinaID = @pN_OficinaID )AND
        (@pN_TipoDocumento IS NULL OR D.TN_TipoDocumento = @pN_TipoDocumento) AND
        (@pF_Fecha IS NULL OR CONVERT(DATE, V.TF_FechaCreacion) = @pF_Fecha)
END
GO

--4 LISTO --
CREATE OR ALTER PROCEDURE GD.PA_ReporteMaestroDocumentos
    @pN_OficinaID INT = NULL,
    @pN_TipoDocumento INT = NULL
AS
BEGIN

    

    WITH Versiones AS (
        SELECT 
            V.TN_Id AS VersionID,
            V.TN_DocumentoID,
            V.TN_NumeroVersion,
            V.TF_FechaCreacion,
            V.TC_NumeroSCD,
			V.TC_Justificacion,
            ROW_NUMBER() OVER (PARTITION BY V.TN_DocumentoID ORDER BY V.TN_NumeroVersion DESC, V.TF_FechaCreacion DESC) AS rn
        FROM GD.TGESTORDOCUMENTAL_Version V
    )

    SELECT 
        D.TC_Codigo AS CodigoDocumento,
        D.TC_Asunto AS NombreDocumento,
        C.TC_Nombre AS Estado,  -- Interpretando acceso como estado
        TD.TC_Nombre AS TipoDocumento,
        V.TN_NumeroVersion AS Version,
        V.TF_FechaCreacion AS Fecha,
        V.TC_Justificacion AS ResumenDelCambio,
        V.TC_NumeroSCD AS SCD
    FROM GD.TGESTORDOCUMENTAL_Documento D
    JOIN Versiones V ON D.TN_Id = V.TN_DocumentoID AND V.rn = 1
    JOIN GD.TGESTORDOCUMENTAL_TipoDocumento TD ON TD.TN_Id = D.TN_TipoDocumento 
    JOIN GD.TGESTORDOCUMENTAL_Categoria C ON C.TN_Id = D.TN_CategoriaID
    JOIN SC.TGESTORDOCUMENTAL_Oficina O ON O.TN_Id = D.TN_OficinaID
    WHERE 
        (@pN_OficinaID IS NULL OR D.TN_OficinaID = @pN_OficinaID ) AND
        (@pN_TipoDocumento IS NULL OR D.TN_TipoDocumento = @pN_TipoDocumento) 
END
GO

--5 LISTO --
CREATE OR ALTER PROCEDURE GD.PA_ReporteMaestroDocumentoPorNorma
    @pN_OficinaID INT = NULL,
    @pN_TipoDocumento INT = NULL,
    @pN_Categoria INT = NULL,
    @pN_Norma INT = NULL
AS
BEGIN

    BEGIN
        IF @pN_OficinaID = 0 SET @pN_OficinaID = NULL
        IF @pN_TipoDocumento = 0 SET @pN_TipoDocumento = NULL
        IF @pN_Categoria = 0 SET @pN_Categoria = NULL
        IF @pN_Norma = 0 SET @pN_Norma = NULL
    END;

    WITH Versiones AS (
        SELECT 
            V.TN_Id AS VersionID,
            V.TN_DocumentoID,
            V.TN_NumeroVersion,
            V.TF_FechaCreacion,
            V.TC_NumeroSCD,
            V.TC_Justificacion,
            ROW_NUMBER() OVER (PARTITION BY V.TN_DocumentoID ORDER BY V.TN_NumeroVersion DESC, V.TF_FechaCreacion DESC) AS rn
        FROM GD.TGESTORDOCUMENTAL_Version V
    )

    SELECT 
        N.TC_Nombre AS NombreNorma,
        TD.TC_Nombre AS TipoDocumento,
        D.TC_Codigo AS CodigoDocumento,
        D.TC_Asunto AS NombreDocumento,
        C.TC_Nombre AS Acceso,  -- Acceso interpretado como acceso/categoría
        V.TC_NumeroSCD AS SCD,
        V.TN_NumeroVersion AS Version,
        V.TF_FechaCreacion AS Fecha,
        V.TC_Justificacion AS ResumenDelCambio
    FROM GD.TGESTORDOCUMENTAL_Documento D
    JOIN Versiones V ON D.TN_Id = V.TN_DocumentoID AND V.rn = 1
    JOIN GD.TGESTORDOCUMENTAL_TipoDocumento TD ON TD.TN_Id = D.TN_TipoDocumento 
    JOIN GD.TGESTORDOCUMENTAL_Categoria C ON C.TN_Id = D.TN_CategoriaID
    JOIN SC.TGESTORDOCUMENTAL_Oficina O ON O.TN_Id = D.TN_OficinaID
	JOIN GD.TGESTORDOCUMENTAL_Etapa E ON E.TN_Id = D.TN_EtapaID
    JOIN GD.TGESTORDOCUMENTAL_Norma N ON N.TN_Id = E.TN_NormaID
    WHERE 
        (@pN_OficinaID IS NULL OR D.TN_OficinaID = @pN_OficinaID )AND
        (@pN_TipoDocumento IS NULL OR TD.TN_Id = @pN_TipoDocumento) AND
        (@pN_Categoria IS NULL OR C.TN_Id = @pN_Categoria) AND
        (@pN_Norma IS NULL OR N.TN_Id = @pN_Norma) 
END
GO

--6 LISTO --
CREATE OR ALTER PROCEDURE GD.PA_ReporteDescargaDeDocumentos
    @pN_Oficina INT = NULL,
    @pN_Usuario INT = NULL,
    @pC_CodigoDocumento NVARCHAR(255) = NULL,
    @pC_NombreDocumento NVARCHAR(255) = NULL,
    @pF_FechaInicio DATE = NULL,
    @pF_FechaFinal DATE = NULL
AS
BEGIN

    BEGIN
        IF @pN_Oficina = 0 SET @pN_Oficina = NULL
        IF @pC_NombreDocumento = '' SET @pC_NombreDocumento = NULL
        IF @pN_Usuario = 0 SET @pN_Usuario = NULL
        IF @pC_CodigoDocumento = '' SET @pC_CodigoDocumento = NULL
        IF @pF_FechaInicio = '' SET @pF_FechaInicio = NULL
        IF @pF_FechaFinal = '' SET @pF_FechaFinal = NULL
    END;

    SELECT 
        D.TC_Codigo AS CodigoDocumento,
        D.TC_Asunto AS NombreDocumento,
        C.TC_Nombre AS Acceso,
        V.TN_NumeroVersion AS Version,
        V.TF_FechaCreacion AS FechaIngreso,
        O.TC_Nombre AS OficinaResponsable,
        -- Contamos las visualizaciones (cuando TB_Movimiento es 0)
        COUNT(CASE WHEN BM.TB_Movimiento = 0 THEN 1 END) AS Visualizaciones,
        -- Contamos las descargas (cuando TB_Movimiento es 1)
        COUNT(CASE WHEN BM.TB_Movimiento = 1 THEN 1 END) AS Descargas
    FROM 
        GD.TGESTORDOCUMENTAL_BitacoraMovimientos BM
    JOIN 
        GD.TGESTORDOCUMENTAL_Version V ON V.TN_Id = BM.TN_VersionID
    JOIN 
        GD.TGESTORDOCUMENTAL_Documento D ON D.TN_Id = V.TN_DocumentoID 
    JOIN 
        GD.TGESTORDOCUMENTAL_Categoria C ON C.TN_Id = D.TN_CategoriaID
    JOIN 
        SC.TGESTORDOCUMENTAL_Usuario U ON U.TN_Id = BM.TN_UsuarioID
    JOIN 
        SC.TGESTORDOCUMENTAL_Oficina O ON O.TN_Id = D.TN_OficinaID
    WHERE 
        (@pN_Oficina IS NULL OR O.TN_Id = @pN_Oficina)
        AND (@pN_Usuario IS NULL OR U.TN_Id = @pN_Usuario)
        AND (@pC_CodigoDocumento IS NULL OR D.TC_Codigo = @pC_CodigoDocumento)
        AND (@pC_NombreDocumento IS NULL OR D.TC_Asunto LIKE '%' + @pC_NombreDocumento + '%')
        AND (@pF_FechaInicio IS NULL OR CONVERT(DATE, V.TF_FechaCreacion) >= @pF_FechaInicio)
        AND (@pF_FechaFinal IS NULL OR CONVERT(DATE, V.TF_FechaCreacion) <= @pF_FechaFinal)
    GROUP BY
        D.TC_Codigo,
        D.TC_Asunto,
        C.TC_Nombre,
        V.TN_NumeroVersion,
        V.TF_FechaCreacion,
        O.TC_Nombre
END
GO

--7 LISTO --
CREATE OR ALTER PROCEDURE GD.PA_ReportesDocSinMovimiento
    @pN_OficinaID INT = NULL,
    @pN_TipoDocumento INT = NULL,
    @pF_FechaFin DATE = NULL,
    @pF_FechaInicio DATE = NULL
AS
BEGIN

    -- Ajuste de parámetros a NULL si son valores por defecto
    IF @pN_OficinaID = 0 SET @pN_OficinaID = NULL;
    IF @pN_TipoDocumento = 0 SET @pN_TipoDocumento = NULL;
    IF @pF_FechaFin = '' SET @pF_FechaFin = NULL;
    IF @pF_FechaInicio = '' SET @pF_FechaInicio = NULL;

    WITH Versiones AS (
        SELECT 
            V.TN_Id AS VersionID,
            V.TN_DocumentoID,
            V.TC_UrlVersion,
            V.TN_NumeroVersion,
            V.TF_FechaCreacion,
            V.TC_NumeroSCD,
            V.TC_Justificacion,
            ROW_NUMBER() OVER (PARTITION BY V.TN_DocumentoID ORDER BY V.TN_NumeroVersion DESC, V.TF_FechaCreacion DESC) AS rn
        FROM GD.TGESTORDOCUMENTAL_Version V
    )

    SELECT 
        D.TC_Codigo AS CodigoDocumento,
        D.TC_Asunto AS NombreDocumento,
        C.TC_Nombre AS Acceso,
        V.TN_NumeroVersion AS Version,
        V.TF_FechaCreacion AS Fecha,
        O.TC_Nombre AS OficinaResponsable
    FROM 
        GD.TGESTORDOCUMENTAL_Documento D
    JOIN 
        GD.TGESTORDOCUMENTAL_Categoria C ON C.TN_Id = D.TN_CategoriaID
    JOIN 
        Versiones V ON V.TN_DocumentoID = D.TN_Id AND V.rn = 1
    JOIN 
        SC.TGESTORDOCUMENTAL_Oficina O ON O.TN_Id = D.TN_OficinaID
    WHERE 
        (@pN_OficinaID IS NULL OR D.TN_OficinaID = @pN_OficinaID)
        AND (@pN_TipoDocumento IS NULL OR D.TN_TipoDocumento = @pN_TipoDocumento)
        AND (
            @pF_FechaInicio IS NULL OR @pF_FechaFin IS NULL 
            OR (CONVERT(DATE, V.TF_FechaCreacion) BETWEEN @pF_FechaInicio AND @pF_FechaFin)
        )
        -- Filtrar documentos sin movimientos en la bitácora
        AND NOT EXISTS (
            SELECT 1
            FROM GD.TGESTORDOCUMENTAL_BitacoraMovimientos BM
            WHERE BM.TN_VersionID = V.VersionID
        );

END;
GO




---FALTA VER QUE DEBE LISTAR

