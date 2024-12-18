--USE GestorDocumentalOIJ

-- Procedimiento para insertar un nuevo documento
CREATE or alter PROCEDURE GD.PA_InsertarDocumento
    @pC_Codigo NVARCHAR(255),
    @pC_Asunto NVARCHAR(255),
    @pC_Descripcion NVARCHAR(1000) = NULL,
    @pN_CategoriaID INT,
    @pN_TipoDocumento INT,
    @pN_OficinaID INT,
    @pC_Vigencia NVARCHAR(255) = NULL,
    @pN_EtapaID INT,
    @pN_SubClasificacionID INT = NULL,
	@pB_Activo BIT,
	@pB_Descargable BIT,
	@pN_DocToID INT = NULL,
    @pN_UsuarioID INT, 
    @pN_OficinaBitacoraID INT,
    @pC_PalabrasClave NVARCHAR(MAX),
    @pC_Doctos NVARCHAR(MAX)
AS
BEGIN

	DECLARE @pC_Operacion NVARCHAR(255) = 'Insertar Documento';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Validar que todas las referencias existan

        BEGIN
            IF @pN_SubClasificacionID = 0 SET @pN_SubClasificacionID = NULL
            IF @pN_DocToID = 0 SET @pN_DocToID = NULL
            IF @pC_Descripcion = '' SET @pC_Descripcion = NULL
            IF @pC_Vigencia ='' SET @pC_Vigencia = NULL
        END;

        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Categoria WHERE TN_Id = @pN_CategoriaID)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La categoria con el Id '+ + CAST(@pN_CategoriaID AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;

            RETURN 1;
        END

        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento WHERE TC_Codigo  = @pC_Codigo)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @pC_Comando = 'Ya existe un documento con ese codigo: '+  @pC_Codigo;
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;

            RETURN 1;
        END

        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TN_Id = @pN_TipoDocumento)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'El tipo de documento con el Id '+ + CAST(@pN_TipoDocumento AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;
            RETURN 1;
        END

        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina WHERE TN_Id = @pN_OficinaID)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La oficina con el Id '+ + CAST(@pN_OficinaID AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;
            RETURN 1;
        END

        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pN_EtapaID)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La etapa con el Id '+ + CAST(@pN_EtapaID AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;
            RETURN 1;
        END

        IF @pN_SubClasificacionID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pN_SubClasificacionID)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La subclasificacion con el Id '+ + CAST(@pN_SubClasificacionID AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;
            RETURN 1;
        END

		IF @pN_DocToID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @pN_DocToID)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'El docto con el Id '+ + CAST(@pN_DocToID AS NVARCHAR(10)) +' no existe.';
			EXEC GD.PA_InsertarBitacora 
				@pN_UsuarioID = @pN_UsuarioID,
				@pC_Operacion = @pC_Operacion,
				@pC_Comando = @pC_Comando,
				@pN_OficinaID = @pN_OficinaBitacoraID;
			RETURN 1;
        END

        -- Insertar el nuevo documento
        INSERT INTO GD.TGESTORDOCUMENTAL_Documento (TC_Codigo, TC_Asunto, TC_Descripcion, TN_CategoriaID, TN_TipoDocumento, TN_OficinaID, TC_Vigencia, TN_EtapaID, TN_SubClasificacionID, TN_DocTo, TB_Activo,TB_Descargable)
        VALUES (@pC_Codigo, @pC_Asunto, @pC_Descripcion, @pN_CategoriaID, @pN_TipoDocumento, @pN_OficinaID, @pC_Vigencia, @pN_EtapaID, @pN_SubClasificacionID,@pN_DocToID,@pB_Activo,@pB_Descargable);

        DECLARE @TN_DocumentoID INT = SCOPE_IDENTITY(); -- Obtener el ID del nuevo documento

		SET @pC_Comando = 'Insertar nuevo documento con id: '+ CAST(@TN_DocumentoID AS NVARCHAR(10));
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaBitacoraID;

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
            IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @docto AND TB_Eliminado = 0)
            BEGIN
				ROLLBACK TRANSACTION;
                SET @pC_Comando = 'El docto con el Id '+ + CAST(@docto AS NVARCHAR(10)) +' no existe.';
				EXEC GD.PA_InsertarBitacora 
					@pN_UsuarioID = @pN_UsuarioID,
					@pC_Operacion = @pC_Operacion,
					@pC_Comando = @pC_Comando,
					@pN_OficinaID = @pN_OficinaBitacoraID;
				RETURN 1;
            END

            INSERT INTO GD.TGESTORDOCUMENTAL_Documento_Documento (TN_DocumentoID, TN_DocTo, TC_DocRelaciona)
            VALUES (@TN_DocumentoID, @docto, @docRelacionado);

            SET @i = @i + 1;
        END

        IF @total_records > 0
        BEGIN
		    SET @pC_Comando = 'Insertar relaciones de documento del documento: ' + CAST(@TN_DocumentoID AS NVARCHAR(10));
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;
        END

        DECLARE @JSONPalabra NVARCHAR(MAX) = @pC_PalabrasClave;
        DECLARE @j INT = 0;
        DECLARE @total_palabras INT = (SELECT COUNT(*) FROM OPENJSON(@JSONPalabra));

        WHILE @j < @total_palabras
        BEGIN

            DECLARE @PalabraClave NVARCHAR(255) = JSON_VALUE(@JSONPalabra, CONCAT('$[', @j, ']'));
			select @PalabraClave

            INSERT INTO GD.TGESTORDOCUMENTAL_Documento_PalabraClave (TN_DocumentoID, TC_PalabraClave)
            VALUES (@TN_DocumentoID, @PalabraClave);

            SET @j = @j + 1;
        END   

        IF @total_palabras > 0
        BEGIN
		    SET @pC_Comando = 'Insertar palabras clave del documento: ' + CAST(@TN_DocumentoID AS NVARCHAR(10));
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;
        END

        COMMIT TRANSACTION;
        RETURN 0; -- �xito
    END TRY
    BEGIN CATCH
		ROLLBACK TRANSACTION;
        SET @pC_Comando = ERROR_MESSAGE();
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaBitacoraID;
        RETURN 1;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE GD.PA_ActualizarDocumento
    @pN_Id INT,
    @pC_Codigo NVARCHAR(255),
    @pC_Asunto NVARCHAR(255),
    @pC_Descripcion NVARCHAR(1000) = NULL,
    @pN_CategoriaID INT,
    @pN_TipoDocumento INT,
    @pN_OficinaID INT,
    @pC_Vigencia NVARCHAR(255) = NULL,
    @pN_EtapaID INT,
    @pN_DocToID INT = NULL,
    @pN_SubClasificacionID INT = NULL,
	@pB_Activo BIT,
	@pB_Descargable BIT,
    @pN_UsuarioID INT,  
    @pN_OficinaBitacoraID INT,
    @pC_PalabrasClave NVARCHAR(MAX),
    @pC_Doctos NVARCHAR(MAX)
AS
BEGIN
	
	DECLARE @pC_Operacion NVARCHAR(255) = 'Actualizar Documento';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRANSACTION;
    BEGIN TRY

        BEGIN
            IF @pN_SubClasificacionID = 0 SET @pN_SubClasificacionID = NULL
            IF @pN_DocToID = 0 SET @pN_DocToID = NULL
            IF @pC_Descripcion = '' SET @pC_Descripcion = NULL
            IF @pC_Vigencia ='' SET @pC_Vigencia = NULL
        END;

        -- Validar que el documento exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento WHERE TN_Id = @pN_Id)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'El documento con el Id '+ + CAST(@pN_CategoriaID AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;
            RETURN 1;
        END

        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento WHERE TC_Codigo  = @pC_Codigo AND TN_Id <> @pN_Id)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @pC_Comando = 'Ya existe un documento con ese codigo: '+  @pC_Codigo;
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;
            RETURN 1;
        END

        -- Validar que la categoría exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Categoria WHERE TN_Id = @pN_CategoriaID AND TB_Eliminado = 0)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La categoria con el Id '+ + CAST(@pN_CategoriaID AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;
            RETURN 1;
        END

        -- Validar que el tipo de documento exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TN_Id = @pN_TipoDocumento AND TB_Eliminado = 0)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'El tipo de documento con el Id '+ + CAST(@pN_TipoDocumento AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;
            RETURN 1;
        END

        -- Validar que la oficina exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina WHERE TN_Id = @pN_OficinaID AND TB_Eliminado = 0)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La oficina con el Id '+ + CAST(@pN_OficinaID AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;
            RETURN 1;
        END

        -- Validar que la etapa exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pN_EtapaID AND TB_Eliminado = 0)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La etapa con el Id '+ + CAST(@pN_EtapaID AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;
            RETURN 1;
        END

        -- Validar que el DocTo exista
        IF @pN_DocToID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @pN_DocToID AND TB_Eliminado = 0)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'El docto con el Id '+ CAST(@pN_DocToID AS NVARCHAR(10)) +' no existe.';
			EXEC GD.PA_InsertarBitacora 
				@pN_UsuarioID = @pN_UsuarioID,
				@pC_Operacion = @pC_Operacion,
				@pC_Comando = @pC_Comando,
				@pN_OficinaID = @pN_OficinaBitacoraID;
			RETURN 1;
        END

        -- Validar que la subclasificación exista
        IF @pN_SubClasificacionID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pN_SubClasificacionID AND TB_Eliminado = 0)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La subclasificacion con el Id '+ CAST(@pN_SubClasificacionID AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;
            RETURN 1;
        END

        -- Actualizar el documento
        UPDATE GD.TGESTORDOCUMENTAL_Documento
        SET TC_Codigo = @pC_Codigo,
            TC_Asunto = @pC_Asunto,
            TC_Descripcion = @pC_Descripcion,
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

		SET @pC_Comando = 'Actualiza documento con id: ' + CAST(@pN_Id AS NVARCHAR(10));
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaBitacoraID;

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

			IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @DoctoID AND TB_Eliminado = 0)
            BEGIN
				ROLLBACK TRANSACTION;
                SET @pC_Comando = 'El docto con el Id '+ + CAST(@DoctoID AS NVARCHAR(10)) +' no existe.';
				EXEC GD.PA_InsertarBitacora 
					@pN_UsuarioID = @pN_UsuarioID,
					@pC_Operacion = @pC_Operacion,
					@pC_Comando = @pC_Comando,
					@pN_OficinaID = @pN_OficinaBitacoraID;
				RETURN 1;
            END

            INSERT INTO GD.TGESTORDOCUMENTAL_Documento_Documento (TN_DocumentoID, TN_DocTo, TC_DocRelaciona)
            VALUES (@pN_Id, @DoctoID, @DocRelacionado);

            SET @i = @i + 1;
        END

        IF @total_records > 0
        BEGIN
            SET @pC_Comando = 'Actualizar relaciones de documento del documento: ' + CAST(@pN_Id AS NVARCHAR(10));
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;
        END

        DELETE FROM GD.TGESTORDOCUMENTAL_Documento_PalabraClave
        WHERE TN_DocumentoID = @pN_Id;

        DECLARE @JSONPalabra NVARCHAR(MAX) = @pC_PalabrasClave;
        DECLARE @j INT = 0;
        DECLARE @total_palabras INT = (SELECT COUNT(*) FROM OPENJSON(@JSONPalabra));

        WHILE @j < @total_palabras
        BEGIN

            DECLARE @PalabraClave NVARCHAR(255) = JSON_VALUE(@JSONPalabra, CONCAT('$[', @j, ']'));
			select @PalabraClave

            INSERT INTO GD.TGESTORDOCUMENTAL_Documento_PalabraClave (TN_DocumentoID, TC_PalabraClave)
            VALUES (@pN_Id, @PalabraClave);

            SET @j = @j + 1;
        END   

        IF @total_palabras > 0
        BEGIN
		    SET @pC_Comando = 'Insertar palabras clave del documento: ' + CAST(@pN_Id AS NVARCHAR(10));
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaBitacoraID;
        END

        COMMIT TRANSACTION;
        RETURN 0;  -- Actualización exitosa
    END TRY
    BEGIN CATCH
		ROLLBACK TRANSACTION;
        SET @pC_Comando = ERROR_MESSAGE();
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaBitacoraID;
        RETURN 1;
    END CATCH
END;
GO



-- Procedimiento para eliminar un documento (eliminado l�gico)
CREATE OR ALTER PROCEDURE GD.PA_EliminarDocumento
    @pN_Id INT,
    @pN_UsuarioID INT, 
    @pN_OficinaID INT  
AS
BEGIN
	
	DECLARE @pC_Operacion NVARCHAR(255) = 'Eliminar Documento';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el documento exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento WHERE TN_Id = @pN_Id)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'El documento con el Id '+ + CAST(@pN_Id AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

		IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Version WHERE TN_DocumentoID = @pN_Id and TB_Eliminado = 0)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'El documento con el Id '+ CAST(@pN_Id AS NVARCHAR(10)) +' esta ligada a una version por lo cual no se puede eliminar.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Eliminar el documento (eliminado l�gico)
        UPDATE GD.TGESTORDOCUMENTAL_Documento
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

		SET @pC_Comando = 'Eliminar documento con ID ' + CAST(@pN_Id AS NVARCHAR(10));
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

		DELETE FROM GD.TGESTORDOCUMENTAL_Documento_Documento
        WHERE TN_DocumentoID = @pN_Id;

		SET @pC_Comando = 'Eliminar relaciones de documento con ID ' + CAST(@pN_Id AS NVARCHAR(10));
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        DELETE FROM GD.TGESTORDOCUMENTAL_Documento_PalabraClave
        WHERE TN_DocumentoID = @pN_Id;

        SET @pC_Comando = 'Eliminar palabras claves de documento con ID ' + CAST(@pN_Id AS NVARCHAR(10));
        EXEC GD.PA_InsertarBitacora 
        @pN_UsuarioID = @pN_UsuarioID,
        @pC_Operacion = @pC_Operacion,
        @pC_Comando = @pC_Comando,
        @pN_OficinaID = @pN_OficinaID;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
		ROLLBACK TRANSACTION;
        SET @pC_Comando = ERROR_MESSAGE();
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para listar todos los documentos no eliminados
CREATE or alter PROCEDURE GD.PA_ListarDocumentos
AS
BEGIN
	WITH Versiones AS (
		SELECT 
			V.TN_Id AS VersionID,
			V.TN_DocumentoID,   
			V.TN_NumeroVersion,
			V.TF_FechaCreacion,
            V.TB_Eliminado,
			ROW_NUMBER() OVER (PARTITION BY V.TN_DocumentoID ORDER BY V.TN_NumeroVersion DESC, V.TF_FechaCreacion DESC) AS rn
		FROM GD.TGESTORDOCUMENTAL_Version V
	)
    SELECT 
		D.TN_Id AS Id, --
        D.TC_Codigo AS Codigo, --
        D.TC_Asunto AS Nombre, --
        D.TB_Descargable AS descargable,
        D.TB_Activo AS Activo,
        D.TN_CategoriaID AS CategoriaID, --
        D.TN_TipoDocumento AS TipoDocumento, --
        D.TN_OficinaID AS OficinaID, --
        ISNULL(D.TC_Vigencia,'') AS Vigencia, --
        D.TN_EtapaID AS EtapaID, --
        ISNULL(D.TN_DocTo,0) AS DocToID, --
        ISNULL(D.TN_SubClasificacionID,0) AS SubClasificacionID,
		N.TN_Id AS NormaID,--
		ISNULL(V.VersionID,0) AS VersionID,--
        ISNULL(V.TN_NumeroVersion,0) AS NumeroVersion,
		ISNULL(C.TN_Id,0) AS ClasificacionID,
        ISNULL((SELECT 
            JSON_QUERY((SELECT TC_PalabraClave AS palabraClave
                        FROM GD.TGESTORDOCUMENTAL_Documento_PalabraClave
                        WHERE TN_DocumentoID = D.TN_Id
                        FOR JSON PATH)) 
        ),'[]') AS PalabrasClave
    FROM GD.TGESTORDOCUMENTAL_Documento D
	JOIN GD.TGESTORDOCUMENTAL_Etapa E on e.TN_Id = d.TN_EtapaID
	JOIN GD.TGESTORDOCUMENTAL_Norma N ON N.TN_Id = E.TN_NormaID
	LEFT JOIN Versiones V ON V.TN_DocumentoID = D.TN_Id AND V.rn = 1 AND V.TB_Eliminado = 0
	LEFT JOIN GD.TGESTORDOCUMENTAL_Subclasificacion SC ON SC.TN_Id = D.TN_SubClasificacionID
	LEFT JOIN GD.TGESTORDOCUMENTAL_Clasificacion C ON C.TN_Id = SC.TN_ClasificacionID
	WHERE D.TB_Eliminado = 0 AND D.TB_Activo = 1
END;
GO

CREATE OR ALTER PROCEDURE GD.PA_ListarDocumentosConsulta

    @pN_UsuarioID INT
AS
BEGIN
    WITH Versiones AS (
        SELECT 
            V.TN_Id AS VersionID,
            V.TN_DocumentoID,
            V.TC_UrlVersion,
            V.TN_NumeroVersion,
            V.TF_FechaCreacion,
            V.TB_Eliminado,
            ROW_NUMBER() OVER (PARTITION BY V.TN_DocumentoID ORDER BY V.TN_NumeroVersion DESC, V.TF_FechaCreacion DESC) AS rn
        FROM GD.TGESTORDOCUMENTAL_Version V
    )
    SELECT 
        D.TN_Id AS Id,
        D.TC_Codigo AS Codigo,
        D.TC_Asunto AS Nombre,
        ISNULL(D.TC_Descripcion,'') AS Descripcion,
        D.TN_CategoriaID AS CategoriaID,
        D.TN_TipoDocumento AS TipoDocumento,
        D.TN_OficinaID AS OficinaID,
        ISNULL(D.TC_Vigencia,'') AS Vigencia,
        D.TN_EtapaID AS EtapaID,
        ISNULL(D.TN_DocTo,0) AS DocToID, 
        ISNULL(D.TN_SubClasificacionID,0) AS SubClasificacionID,
        N.TN_Id AS NormaID,
        ISNULL(V.VersionID, 0) AS VersionID,
        ISNULL(V.TN_NumeroVersion,0) AS NumeroVersion,
        ISNULL(C.TN_Id,0) AS ClasificacionID,
        D.TB_Descargable AS descargable,
        V.TC_UrlVersion AS urlVersion,
        ISNULL((SELECT 
            JSON_QUERY((SELECT TC_PalabraClave AS palabraClave
                        FROM GD.TGESTORDOCUMENTAL_Documento_PalabraClave
                        WHERE TN_DocumentoID = D.TN_Id
                        FOR JSON PATH)) 
        ),'[]') AS PalabrasClave
    FROM GD.TGESTORDOCUMENTAL_Documento D
	JOIN GD.TGESTORDOCUMENTAL_Etapa E ON E.TN_Id = D.TN_EtapaID
    JOIN GD.TGESTORDOCUMENTAL_Norma N ON N.TN_Id = E.TN_NormaID
	JOIN GD.TGESTORDOCUMENTAL_Subclasificacion SC ON SC.TN_Id = D.TN_SubClasificacionID
    JOIN GD.TGESTORDOCUMENTAL_Clasificacion C ON C.TN_Id = SC.TN_ClasificacionID
    JOIN Versiones V ON V.TN_DocumentoID = D.TN_Id AND V.rn = 1
    JOIN SC.TGESTORDOCUMENTAL_Oficina_Usuario OU ON OU.TN_UsuarioID = @pN_UsuarioID
    JOIN SC.TGESTORDOCUMENTAL_Oficina_Gestor OGUsuario ON OGUsuario.TN_OficinaID = OU.TN_OficinaID
    JOIN SC.TGESTORDOCUMENTAL_Oficina_Gestor OGDocumento ON OGDocumento.TN_OficinaID = D.TN_OficinaID
    JOIN GD.TGESTORDOCUMENTAL_Categoria CA ON CA.TN_Id = D.TN_CategoriaID
    WHERE D.TB_Eliminado = 0
        AND D.TB_Activo = 1
        AND (
            CA.TC_Nombre = 'Publico' 
            OR (
                CA.TC_Nombre = 'Privado' 
                AND D.TN_OficinaID = OU.TN_OficinaID
            )
            OR (
                CA.TC_Nombre = 'Publico centro gestor'
                AND (
                    D.TN_OficinaID = OU.TN_OficinaID
                    OR OGUsuario.TN_GestorID = OGDocumento.TN_GestorID
                )
            )
        )
    ORDER BY D.TN_Id;
END;
GO


/*
CREATE or alter PROCEDURE GD.PA_ListarDocumentosConsultaHorizontal
AS
BEGIN
    SELECT 
		D.TN_Id AS Id, --
        D.TC_Codigo AS Codigo, --
        D.TN_CategoriaID AS CategoriaID, --
        D.TN_TipoDocumento AS TipoDocumento, --
        D.TN_OficinaID AS OficinaID, --
        D.TC_Vigencia AS Vigencia, --
        D.TN_DocTo AS DocToID, --
		N.TN_Id AS NormaID,--
		ISNULL(V.TN_Id,0) AS VersionID,--
		V.TC_UrlVersion AS urlVersion, 
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

CREATE or alter PROCEDURE GD.PA_ListarDocumentosConsultaVerticalProceso
AS
BEGIN
    SELECT 
		D.TN_Id AS Id, --
        D.TN_OficinaID AS OficinaID, --
		ISNULL(V.TN_Id,0) AS VersionID,--
		V.TC_UrlVersion AS urlVersion
    FROM GD.TGESTORDOCUMENTAL_Documento D
	LEFT JOIN GD.TGESTORDOCUMENTAL_Version V ON V.TN_DocumentoID = D.TN_Id
	WHERE D.TB_Eliminado = 0
	ORDER BY V.TN_NumeroVersion DESC, V.TF_FechaCreacion DESC;
END;
GO

CREATE or alter PROCEDURE GD.PA_ListarDocumentosConsultaVerticalFiltro
AS
BEGIN
    SELECT 
		D.TN_Id AS Id, --
        D.TN_OficinaID AS OficinaID, --
		ISNULL(V.TN_Id,0) AS VersionID,--
		V.TC_UrlVersion AS urlVersion
    FROM GD.TGESTORDOCUMENTAL_Documento D
	LEFT JOIN GD.TGESTORDOCUMENTAL_Version V ON V.TN_DocumentoID = D.TN_Id
	WHERE D.TB_Eliminado = 0
	ORDER BY V.TN_NumeroVersion DESC, V.TF_FechaCreacion DESC;
END;
GO*/

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
        D.TN_Id AS Id, 
        D.TC_Codigo AS Codigo, 
        D.TC_Asunto AS Asunto, 
        ISNULL(D.TC_Descripcion, '') AS Descripcion, 
        D.TN_CategoriaID AS CategoriaID, 
        D.TN_TipoDocumento AS TipoDocumento, 
        D.TN_OficinaID AS OficinaID, 
        ISNULL(D.TC_Vigencia, '') AS Vigencia, 
        D.TN_EtapaID AS EtapaID, 
        ISNULL(D.TN_DocTo, 0) AS DocToID, 
        D.TB_Activo AS Activo, 
        D.TB_Descargable AS Descargable, 
        D.TB_Eliminado AS Eliminado, 
        ISNULL(D.TN_SubClasificacionID, 0) AS SubClasificacionID,
        N.TN_Id AS NormaID,
        ISNULL(C.TN_Id, 0) AS ClasificacionID,
        ISNULL(V.TN_Id, 0) AS VersionID,
        ISNULL(
            (SELECT 
                JSON_QUERY((SELECT TN_DocTo AS docto, TC_DocRelaciona AS docRelacionado
                            FROM GD.TGESTORDOCUMENTAL_Documento_Documento
                            WHERE TN_DocumentoID = @pN_Id
                            FOR JSON PATH))
            ), '[]'
        ) AS doctos,
        ISNULL(
            (SELECT 
                JSON_QUERY((SELECT TC_PalabraClave AS palabraClave
                            FROM GD.TGESTORDOCUMENTAL_Documento_PalabraClave
                            WHERE TN_DocumentoID = @pN_Id
                            FOR JSON PATH))
            ), '[]'
        ) AS PalabrasClave
    FROM GD.TGESTORDOCUMENTAL_Documento D
    LEFT JOIN GD.TGESTORDOCUMENTAL_Version V ON V.TN_DocumentoID = D.TN_Id
    JOIN GD.TGESTORDOCUMENTAL_Etapa E ON E.TN_Id = D.TN_EtapaID
    JOIN GD.TGESTORDOCUMENTAL_Norma N ON N.TN_Id = E.TN_NormaID
    LEFT JOIN GD.TGESTORDOCUMENTAL_Subclasificacion SC ON SC.TN_Id = D.TN_SubClasificacionID
    LEFT JOIN GD.TGESTORDOCUMENTAL_Clasificacion C ON C.TN_Id = SC.TN_ClasificacionID
    WHERE D.TN_Id = @pN_Id;

END;
GO
