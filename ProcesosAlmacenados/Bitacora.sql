--USE GestorDocumentalOIJ

-- Procedimiento para insertar un registro en la bitacora
CREATE PROCEDURE GD.PA_InsertarBitacora 
    @pN_UsuarioID INT,
    @pC_Operacion NVARCHAR(255),
    @pC_Comando NVARCHAR(255),
    @pN_OficinaID INT
AS
BEGIN
    BEGIN TRY
        -- Iniciar la transacción
        BEGIN TRANSACTION;

        -- Validar que el usuario exista, esté activo y no esté eliminado
        IF NOT EXISTS (
            SELECT 1 
            FROM SC.TGESTORDOCUMENTAL_Usuario 
            WHERE TN_Id = @pN_UsuarioID 
            AND TB_Activo = 1
            AND TB_Eliminado = 0
        )
        BEGIN
            -- Usuario no válido o inactivo
            ROLLBACK TRANSACTION;
            RETURN 1; -- Retornar 1 si falla la validación
        END

        -- Validar que la oficina exista y no esté eliminada
        IF NOT EXISTS (
            SELECT 1 
            FROM SC.TGESTORDOCUMENTAL_Oficina 
            WHERE TN_Id = @pN_OficinaID 
            AND TB_Eliminado = 0
        )
        BEGIN
            -- Oficina no válida o eliminada
            ROLLBACK TRANSACTION;
            RETURN 1; -- Retornar 1 si falla la validación
        END

        -- Validar que la oficina esté ligada al usuario y no esté eliminada
        IF NOT EXISTS (
            SELECT 1 
            FROM SC.TGESTORDOCUMENTAL_Oficina_Usuario 
            WHERE TN_UsuarioID = @pN_UsuarioID 
            AND TN_OficinaID = @pN_OficinaID
            AND TB_Eliminado = 0
        )
        BEGIN
            -- No hay relación válida entre la oficina y el usuario
            ROLLBACK TRANSACTION;
            RETURN 1; -- Retornar 1 si falla la validación
        END

        -- Insertar en la tabla de bitácora
        INSERT INTO GD.TGESTORDOCUMENTAL_Bitacora 
        (TC_Operacion, TN_UsuarioID, TC_Comando, TN_OficinaID, TF_FechaHora)
        VALUES (@pC_Operacion, @pN_UsuarioID, @pC_Comando, @pN_OficinaID, DEFAULT);

        -- Confirmar la transacción
        COMMIT TRANSACTION;
        RETURN 0; -- Retornar 0 si la inserción fue exitosa
    END TRY
    BEGIN CATCH
        -- Si ocurre algún error, deshacer la transacción
        ROLLBACK TRANSACTION;
        RETURN 1; -- Retornar 1 si hay un error
    END CATCH
END;
GO


-- Procedimiento para listar los registros de la bitacora
CREATE PROCEDURE GD.PA_ListarBitacora
AS
BEGIN
    -- Devolver todos los registros de la bitacora
    SELECT TN_Id, TC_Operacion, TN_UsuarioID, TC_Comando, TF_FechaHora, TN_OficinaID
    FROM GD.TGESTORDOCUMENTAL_Bitacora;
END;
GO
