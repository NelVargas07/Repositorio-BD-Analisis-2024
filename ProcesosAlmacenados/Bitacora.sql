--USE GestorDocumentalOIJ

-- Procedimiento para insertar un registro en la bitacora
CREATE PROCEDURE GD.PA_sp_InsertarBitacora
    @pN_UsuarioID INT,
    @pC_Operacion NVARCHAR(255),
    @pC_Comando NVARCHAR(255),
    @pN_OficinaID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Insertar en la tabla de bitacora
        INSERT INTO GD.TGESTORDOCUMENTAL_Bitacora (TC_Operacion, TN_UsuarioID, TC_Comando, TN_OficinaID, TF_FechaHora)
        VALUES (@pC_Operacion, @pN_UsuarioID, @pC_Comando, @pN_OficinaID,DEFAULT);
        
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        -- Si ocurre algun error, deshacer la transaccion
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para listar los registros de la bitacora
CREATE PROCEDURE GD.PA_sp_ListarBitacora
AS
BEGIN
    -- Devolver todos los registros de la bitacora
    SELECT TN_Id, TC_Operacion, TN_UsuarioID, TC_Comando, TF_FechaHora, TN_OficinaID
    FROM GD.TGESTORDOCUMENTAL_Bitacora;
END;
GO
