CREATE PROCEDURE GD.PA_InsertarBitacoraMovimientos
    @pN_VersionID INT,
    @pN_UsuarioID INT,
    @pC_Movimiento NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validación de la existencia de la versión
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Version WHERE TN_Id = @pN_VersionID)
        BEGIN
            RAISERROR('La versión especificada no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validación de la existencia del usuario
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Usuario WHERE TN_Id = @pN_UsuarioID)
        BEGIN
            RAISERROR('El usuario especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Inserción en la bitácora de movimientos
        INSERT INTO GD.TGESTORDOCUMENTAL_BitacoraMovimientos (TN_VersionID, TF_FechaIngreso, TN_UsuarioID, TC_Movimiento)
        VALUES (@pN_VersionID, GETDATE(), @pN_UsuarioID, @pC_Movimiento);

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
