--USE GestorDocumentalOIJ
-- Procedimiento para insertar un nuevo documento
CREATE or alter PROCEDURE GD.PA_InsertarDocumento
    @pC_Codigo NVARCHAR(255),
    @pC_Asunto NVARCHAR(255),
    @pC_Descripcion NVARCHAR(1000),
    @pC_PalabraClave NVARCHAR(255),
    @pN_CategoriaID INT,
    @pN_TipoDocumento INT,
    @pN_OficinaID INT,
    @pC_Vigencia NVARCHAR(255),
    @pN_EtapaID INT,
    @pN_SubClasificacionID INT,
	@pB_Activo BIT,
	@pB_Descargable BIT,
	@pN_DocToID INT,
    @pC_Doctos NVARCHAR(MAX) -- JSON con m�ltiples registros de documentos
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Validar que todas las referencias existan
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Categoria WHERE TN_Id = @pN_CategoriaID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TN_Id = @pN_TipoDocumento)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        --IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Oficina WHERE TN_Id = @pN_OficinaID)
        --BEGIN
        --    ROLLBACK TRANSACTION;
        --    RETURN 1;
        --END

        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pN_EtapaID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pN_SubClasificacionID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar el nuevo documento
        INSERT INTO GD.TGESTORDOCUMENTAL_Documento (TC_Codigo, TC_Asunto, TC_Descripcion, TC_PalabraClave, TN_CategoriaID, TN_TipoDocumento, TN_OficinaID, TC_Vigencia, TN_EtapaID, TN_SubClasificacionID, TN_DocTo, TB_Activo,TB_Descargable)
        VALUES (@pC_Codigo, @pC_Asunto, @pC_Descripcion, @pC_PalabraClave, @pN_CategoriaID, @pN_TipoDocumento, @pN_OficinaID, @pC_Vigencia, @pN_EtapaID, @pN_SubClasificacionID,@pN_DocToID,@pB_Activo,@pB_Descargable);

        DECLARE @TN_DocumentoID INT = SCOPE_IDENTITY(); -- Obtener el ID del nuevo documento

        -- Insertar relaciones en GD.TGESTORDOCUMENTAL_Documento_Documento desde el JSON
        DECLARE @JSON NVARCHAR(MAX) = @pC_Doctos;
        DECLARE @i INT = 0;
        DECLARE @total_records INT = (SELECT COUNT(*) FROM OPENJSON(@JSON));
        
        WHILE @i < @total_records
        BEGIN
            DECLARE @docto INT = JSON_VALUE(@JSON, CONCAT('$[', @i, '].docto'));
            DECLARE @docRelacionado NVARCHAR(255) = JSON_VALUE(@JSON, CONCAT('$[', @i, '].docRelacionado'));
			select @docto
			select @docRelacionado
            -- Validar que el documento exista
            IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @docto)
            BEGIN
                ROLLBACK TRANSACTION;
                RETURN 1;
            END

            INSERT INTO GD.TGESTORDOCUMENTAL_Documento_Documento (TN_DocumentoID, TN_DocTo, TC_DocRelaciona)
            VALUES (@TN_DocumentoID, @docto, @docRelacionado);

            SET @i = @i + 1;
        END

        COMMIT TRANSACTION;
        RETURN 0; -- �xito
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1; -- Error
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE GD.PA_ActualizarDocumento
    @pN_Id INT,
    @pC_Codigo NVARCHAR(255),
    @pC_Asunto NVARCHAR(255),
    @pC_Descripcion NVARCHAR(1000),
    @pC_PalabraClave NVARCHAR(255),
    @pN_CategoriaID INT,
    @pN_TipoDocumento INT,
    @pN_OficinaID INT,
    @pC_Vigencia NVARCHAR(255),
    @pN_EtapaID INT,
    @pN_DocToID INT,
    @pN_SubClasificacionID INT,
	@pB_Activo BIT,
	@pB_Descargable BIT,
    @pC_Doctos NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Validar que el documento exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento WHERE TN_Id = @pN_Id)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;  -- Documento no existe
        END

        -- Validar que la categoría exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Categoria WHERE TN_Id = @pN_CategoriaID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;  -- Categoría no existe
        END

        -- Validar que el tipo de documento exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TN_Id = @pN_TipoDocumento)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;  -- Tipo de documento no existe
        END

        -- Validar que la oficina exista
        --IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Oficina WHERE TN_Id = @pN_OficinaID)
        --BEGIN
        --    ROLLBACK TRANSACTION;
        --    RETURN 1;  -- Oficina no existe
        --END

        -- Validar que la etapa exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pN_EtapaID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;  -- Etapa no existe
        END

        -- Validar que el DocTo exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @pN_DocToID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;  -- DocTo no existe
        END

        -- Validar que la subclasificación exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pN_SubClasificacionID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;  -- Subclasificación no existe
        END

        -- Actualizar el documento
        UPDATE GD.TGESTORDOCUMENTAL_Documento
        SET TC_Codigo = @pC_Codigo,
            TC_Asunto = @pC_Asunto,
            TC_Descripcion = @pC_Descripcion,
            TC_PalabraClave = @pC_PalabraClave,
            TN_CategoriaID = @pN_CategoriaID,
            TN_TipoDocumento = @pN_TipoDocumento,
            TN_OficinaID = @pN_OficinaID,
            TC_Vigencia = @pC_Vigencia,
            TN_EtapaID = @pN_EtapaID,
            TN_DocTo = @pN_DocToID,
			TB_Activo = @pB_Activo,
			TB_Descargable = @pB_Descargable,
            TN_SubClasificacionID = @pN_SubClasificacionID
        WHERE TN_Id = @pN_Id;

        -- Eliminar relaciones anteriores
        DELETE FROM GD.TGESTORDOCUMENTAL_Documento_Documento
        WHERE TN_DocumentoID = @pN_Id;

        -- Insertar nuevas relaciones desde el JSON
        DECLARE @i INT = 0;
        DECLARE @total_records INT;
        SET @total_records = (SELECT COUNT(*) FROM OPENJSON(@pC_Doctos));

        DECLARE @DoctoID INT;
        DECLARE @DocRelacionado NVARCHAR(255);

        WHILE @i < @total_records
        BEGIN
            SET @DoctoID = JSON_VALUE(@pC_Doctos, CONCAT('$[', @i, '].docto'));
            SET @DocRelacionado = JSON_VALUE(@pC_Doctos, CONCAT('$[', @i, '].docRelacionado'));

            INSERT INTO GD.TGESTORDOCUMENTAL_Documento_Documento (TN_DocumentoID, TN_DocTo, TC_DocRelaciona)
            VALUES (@pN_Id, @DoctoID, @DocRelacionado);

            SET @i = @i + 1;
        END

        COMMIT TRANSACTION;
        RETURN 0;  -- Actualización exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1;  -- Error en la transacción
    END CATCH
END;
GO



-- Procedimiento para eliminar un documento (eliminado l�gico)
CREATE PROCEDURE GD.PA_EliminarDocumento
    @pN_Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el documento exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('El documento con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminar el documento (eliminado l�gico)
        UPDATE GD.TGESTORDOCUMENTAL_Documento
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

		DELETE FROM GD.TGESTORDOCUMENTAL_Documento_Documento
        WHERE TN_DocumentoID = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para listar todos los documentos no eliminados
CREATE or alter PROCEDURE GD.PA_ListarDocumentos
AS
BEGIN
    SELECT 
		D.TN_Id AS Id, --
        D.TC_Codigo AS Codigo, --
        D.TC_Asunto AS Nombre, --
        D.TN_CategoriaID AS CategoriaID, --
        D.TN_TipoDocumento AS TipoDocumento, --
        D.TN_OficinaID AS OficinaID, --
        D.TC_Vigencia AS Vigencia, --
        D.TN_EtapaID AS EtapaID, --
        D.TN_DocTo AS DocToID, --
        D.TN_SubClasificacionID AS SubClasificacionID,
		N.TN_Id AS NormaID,--
		ISNULL(V.TN_Id,0) AS VersionID,--
		C.TN_Id AS ClasificacionID--
    FROM GD.TGESTORDOCUMENTAL_Documento D
	JOIN GD.TGESTORDOCUMENTAL_Etapa E on e.TN_Id = d.TN_EtapaID
	JOIN GD.TGESTORDOCUMENTAL_Norma N ON N.TN_Id = E.TN_NormaID
	LEFT JOIN GD.TGESTORDOCUMENTAL_Version V ON V.TN_DocumentoID = D.TN_Id
	JOIN GD.TGESTORDOCUMENTAL_Subclasificacion SC ON SC.TN_Id = D.TN_SubClasificacionID
	JOIN GD.TGESTORDOCUMENTAL_Clasificacion C ON C.TN_Id = SC.TN_ClasificacionID
	WHERE D.TB_Eliminado = 0
	ORDER BY V.TN_NumeroVersion DESC, V.TF_FechaCreacion DESC;
END;
GO

-- Procedimiento para obtener un documento por su Id
CREATE OR ALTER PROCEDURE GD.PA_ObtenerDocumentoPorId
    @pN_Id INT
AS
BEGIN
    -- Validar que el documento exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('El documento con el Id especificado no existe.', 16, 1);
        RETURN 1; -- Documento no existe, retorna 1
    END

    -- Devolver el documento con todas las columnas y las relaciones en formato JSON
    SELECT 
        TN_Id AS Id, 
        TC_Codigo AS Codigo, 
        TC_Asunto AS Asunto, 
        TC_Descripcion AS Descripcion, 
        TC_PalabraClave AS PalabraClave, 
        TN_CategoriaID AS CategoriaID, 
        TN_TipoDocumento AS TipoDocumento, 
        TN_OficinaID AS OficinaID, 
        TC_Vigencia AS Vigencia, 
        TN_EtapaID AS EtapaID, 
        TN_DocTo AS DocToID, 
        TB_Activo AS Activo, 
        TB_Descargable AS Descargable, 
        TB_Eliminado AS Eliminado, 
        TN_SubClasificacionID AS SubClasificacionID,
        (SELECT 
            JSON_QUERY((SELECT TN_DocTo AS docto, TC_DocRelaciona AS docRelacionado
                        FROM GD.TGESTORDOCUMENTAL_Documento_Documento
                        WHERE TN_DocumentoID = @pN_Id
                        FOR JSON PATH)) 
        ) AS doctos
    FROM GD.TGESTORDOCUMENTAL_Documento
    WHERE TN_Id = @pN_Id;

    RETURN 0; -- Operación exitosa
END;
GO


