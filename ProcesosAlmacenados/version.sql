--USE GestorDocumentalOIJ

CREATE PROCEDURE GD.PA_InsertarVersion
    @pN_DocumentoID INT,
    @pN_NumeroVersion INT,
    @pC_UrlVersion NVARCHAR(500),
    @pC_NumeroSCD NVARCHAR(200),
    @pC_Justificacion NVARCHAR(500),
    @pN_UsuarioID INT,
    @pB_DocDinamico BIT,
    @pB_Obsoleto BIT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Validar que el documento y el usuario existan
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento WHERE TN_Id = @pN_DocumentoID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1; -- Documento no existe
        END

        -- Insertar nueva versión
        INSERT INTO GD.TGESTORDOCUMENTAL_Version 
        (TN_DocumentoID, TN_NumeroVersion, TC_UrlVersion, TN_UsuarioID, TB_DocDinamico, TB_Obsoleto, TC_NumeroSCD, TC_Justificacion)
        VALUES 
        (@pN_DocumentoID, @pN_NumeroVersion, @pC_UrlVersion, @pN_UsuarioID, @pB_DocDinamico, @pB_Obsoleto, @pC_NumeroSCD, @pC_Justificacion);

        COMMIT TRANSACTION;
        RETURN 0; -- Inserción exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1; -- Error
    END CATCH
END;
GO


CREATE PROCEDURE GD.PA_ActualizarVersion
    @pN_Id INT,
    @pN_NumeroVersion INT,
    @pC_UrlVersion NVARCHAR(500),
    @pC_NumeroSCD NVARCHAR(200),
    @pC_Justificacion NVARCHAR(500),
    @pN_UsuarioID INT,
    @pB_DocDinamico BIT,
    @pB_Obsoleto BIT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Validar que la versión exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Version WHERE TN_Id = @pN_Id)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1; -- Versión no existe
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

        COMMIT TRANSACTION;
        RETURN 0; -- Actualización exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1; -- Error
    END CATCH
END;
GO


CREATE PROCEDURE GD.PA_EliminarVersion
    @pN_Id INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Validar que la versión exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Version WHERE TN_Id = @pN_Id)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1; -- Versión no existe
        END

        -- Marcar como eliminada
        UPDATE GD.TGESTORDOCUMENTAL_Version
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0; -- Eliminación exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1; -- Error
    END CATCH
END;
GO


CREATE PROCEDURE GD.PA_ObtenerVersionPorId
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

CREATE PROCEDURE GD.PA_ListarVersiones
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

CREATE PROCEDURE GD.PA_ListarVersionPorDocumentoID
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


