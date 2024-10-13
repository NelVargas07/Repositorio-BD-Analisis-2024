--USE GestorDocumentalOIJ

-- Procedimiento para insertar un registro en la bitácora
CREATE PROCEDURE GD.PA_sp_InsertarBitacora
    @pN_UsuarioID INT,
    @pC_Operacion NVARCHAR(255),
    @pC_Comando NVARCHAR(255),
    @pN_OficinaID INT,
    @pN_InstitucionID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Insertar en la tabla de bitácora
        INSERT INTO GD.TGESTORDOCUMENTAL_Bitacora (TC_Operacion, TN_UsuarioID, TC_Comando, TN_OficinaID, TN_InstitucionID, TF_FechaHora)
        VALUES (@pC_Operacion, @pN_UsuarioID, @pC_Comando, @pN_OficinaID, @pN_InstitucionID, DEFAULT);
        
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        -- Si ocurre algún error, deshacer la transacción
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para listar los registros de la bitácora
CREATE PROCEDURE GD.PA_sp_ListarBitacora
AS
BEGIN
    -- Devolver todos los registros de la bitácora
    SELECT TN_Id, TC_Operacion, TN_UsuarioID, TC_Comando, TF_FechaHora, TN_OficinaID, TN_InstitucionID
    FROM GD.TGESTORDOCUMENTAL_Bitacora;
END;
GO
