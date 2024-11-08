--USE GestorDocumentalOIJ

CREATE OR ALTER PROCEDURE GD.PA_InsertarVersion
    @pN_DocumentoID INT,
    @pN_NumeroVersion INT,
    @pC_UrlVersion NVARCHAR(500),
    @pC_NumeroSCD NVARCHAR(200),
    @pC_Justificacion NVARCHAR(500),
    @pN_UsuarioID INT,
    @pB_DocDinamico BIT,
    @pB_Obsoleto BIT,
    @pN_UsuarioBitacoraID INT,
    @pN_OficinaID INT   
AS
BEGIN

	DECLARE @pC_Operacion NVARCHAR(255) = 'Insertar Version';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRANSACTION;
    BEGIN TRY
	 
        -- Validar que el documento y el usuario existan
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento WHERE TN_Id = @pN_DocumentoID AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @pC_Comando = 'El documento con el Id '+ CAST(@pN_DocumentoID AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_UsuarioBitacoraID;
            RETURN 1;
        END

		IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Usuario WHERE TN_Id = @pN_UsuarioID AND TB_Activo = 1)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @pC_Comando = 'El usuario con el Id '+ CAST(@pN_UsuarioID AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_UsuarioBitacoraID;
            RETURN 1;
        END

		IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina WHERE TN_Id = @pN_OficinaID AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La oficina con el Id '+ CAST(@pN_DocumentoID AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_UsuarioBitacoraID;
            RETURN 1;
        END

        -- Insertar nueva versión
        INSERT INTO GD.TGESTORDOCUMENTAL_Version 
        (TN_DocumentoID, TN_NumeroVersion, TC_UrlVersion, TN_UsuarioID, TB_DocDinamico, TB_Obsoleto, TC_NumeroSCD, TC_Justificacion)
        VALUES 
        (@pN_DocumentoID, @pN_NumeroVersion, @pC_UrlVersion, @pN_UsuarioID, @pB_DocDinamico, @pB_Obsoleto, @pC_NumeroSCD, @pC_Justificacion);

		DECLARE @TN_VersionID INT = SCOPE_IDENTITY();

		SET @pC_Comando = 'Insertar nueva version: ' + CAST(@TN_VersionID AS NVARCHAR(10));
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_UsuarioBitacoraID;

        COMMIT TRANSACTION;
        RETURN 0; -- Inserción exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @pC_Comando = ERROR_MESSAGE();
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_UsuarioBitacoraID;
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE GD.PA_ActualizarVersion
    @pN_Id INT,
    @pN_NumeroVersion INT,
    @pC_UrlVersion NVARCHAR(500),
    @pC_NumeroSCD NVARCHAR(200),
    @pC_Justificacion NVARCHAR(500),
    @pN_UsuarioID INT = NULL,
    @pB_DocDinamico BIT,
    @pB_Obsoleto BIT,
    @pN_UsuarioBitacoraID INT,
    @pN_OficinaID INT
AS
BEGIN
	
	DECLARE @pC_Operacion NVARCHAR(255) = 'Actualizar Version';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Validar que la versión exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Version WHERE TN_Id = @pN_Id)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La version con el Id '+ CAST(@pN_Id AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_UsuarioBitacoraID;
            RETURN 1;
        END

		-- Validar que la norma exista o si viene nula
        IF @pN_UsuarioID IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Usuario WHERE TN_Id = @pN_UsuarioID and TB_Activo = 1)
            BEGIN
                ROLLBACK TRANSACTION;
                SET @pC_Comando = 'El usuario con el Id '+ CAST(@pN_UsuarioID AS NVARCHAR(10)) +' no existe.';
                EXEC GD.PA_InsertarBitacora 
                    @pN_UsuarioID = @pN_UsuarioID,
                    @pC_Operacion = @pC_Operacion,
                    @pC_Comando = @pC_Comando,
                    @pN_OficinaID = @pN_UsuarioBitacoraID;
                RETURN 1;
            END
        END
        ELSE
        BEGIN
            SET @pN_UsuarioID = (SELECT TN_UsuarioID FROM GD.TGESTORDOCUMENTAL_Version WHERE TN_Id = @pN_Id);
        END

        -- Actualizar la versión
        UPDATE GD.TGESTORDOCUMENTAL_Version
        SET TN_NumeroVersion = @pN_NumeroVersion,
            TC_UrlVersion = @pC_UrlVersion,
            TN_UsuarioID = @pN_UsuarioID,
            TB_DocDinamico = @pB_DocDinamico,
            TB_Obsoleto = @pB_Obsoleto,
            TC_NumeroSCD = @pC_NumeroSCD,
            TC_Justificacion = @pC_Justificacion
        WHERE TN_Id = @pN_Id;

		SET @pC_Comando = 'Actualizado la version con Id '+ CAST(@pN_Id AS NVARCHAR(10));
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_UsuarioBitacoraID;

        COMMIT TRANSACTION;
        RETURN 0; -- Actualización exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @pC_Comando = ERROR_MESSAGE();
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_UsuarioBitacoraID;
        RETURN 1;
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE GD.PA_EliminarVersion
    @pN_Id INT,
	@pN_UsuarioID INT, -- ID del usuario
    @pN_OficinaID INT  -- ID de la oficina
AS
BEGIN
	
	DECLARE @pC_Operacion NVARCHAR(255) = 'Eliminar Version';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Validar que la versión exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Version WHERE TN_Id = @pN_Id)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La version con el Id '+ + CAST(@pN_Id AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Marcar como eliminada
        UPDATE GD.TGESTORDOCUMENTAL_Version
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

		SET @pC_Comando = 'Eliminar version con ID ' + CAST(@pN_Id AS NVARCHAR(10));
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        COMMIT TRANSACTION;
        RETURN 0; -- Eliminación exitosa
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


CREATE OR ALTER PROCEDURE GD.PA_ObtenerVersionPorId
    @pN_Id INT
AS
BEGIN
    -- Validar que la versión exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Version WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('La versión con el Id especificado no existe.', 16, 1);
        RETURN;
    END

    -- Devolver la versión
    SELECT TN_Id AS Id, 
            TN_DocumentoID AS DocumentoID, 
            TN_NumeroVersion AS NumeroVersion, 
            TF_FechaCreacion AS FechaCreacion, 
            TC_UrlVersion AS urlVersion, 
            TB_Eliminado AS eliminado, 
            TN_UsuarioID AS usuarioID,
            TB_DocDinamico AS DocDinamico,
            TB_Obsoleto AS Obsoleto,
            TC_NumeroSCD AS NumeroSCD,
            TC_Justificacion AS justificacion
    FROM GD.TGESTORDOCUMENTAL_Version
    WHERE TN_Id = @pN_Id;
END;
GO

CREATE OR ALTER PROCEDURE GD.PA_ListarVersiones
AS
BEGIN
    -- Devolver todas las versiones que no están marcadas como eliminadas
    SELECT TN_Id AS Id, 
            TN_DocumentoID AS DocumentoID, 
            TN_NumeroVersion AS NumeroVersion, 
            TF_FechaCreacion AS FechaCreacion, 
            TC_UrlVersion AS urlVersion, 
            TB_Eliminado AS eliminado, 
            TN_UsuarioID AS usuarioID,
            TB_DocDinamico AS DocDinamico,
            TB_Obsoleto AS Obsoleto,
            TC_NumeroSCD AS NumeroSCD,
            TC_Justificacion AS justificacion
    FROM GD.TGESTORDOCUMENTAL_Version
    WHERE TB_Eliminado = 0;
END;
GO

CREATE OR ALTER PROCEDURE GD.PA_ListarVersionPorDocumentoID
    @pN_DocumentoID INT
AS
BEGIN
    -- Validar que el documento exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento WHERE TN_Id = @pN_DocumentoID)
    BEGIN
        RAISERROR('El documento con el Id especificado no existe.', 16, 1);
        RETURN;
    END

    -- Devolver la versión más reciente del documento que no esté eliminada
    SELECT TN_Id AS Id, 
                 TN_DocumentoID AS DocumentoID, 
                 TN_NumeroVersion AS NumeroVersion, 
                 TF_FechaCreacion AS FechaCreacion, 
                 TC_UrlVersion AS urlVersion, 
                 TB_Eliminado AS eliminado, 
                 TN_UsuarioID AS usuarioID,
                 TB_DocDinamico AS DocDinamico,
                 TB_Obsoleto AS Obsoleto,
                 TC_NumeroSCD AS NumeroSCD,
                 TC_Justificacion AS justificacion
    FROM GD.TGESTORDOCUMENTAL_Version
    WHERE TN_DocumentoID = @pN_DocumentoID
      AND TB_Eliminado = 0
    ORDER BY TN_NumeroVersion DESC, TF_FechaCreacion DESC; -- Orden para obtener la más reciente
END;
GO


