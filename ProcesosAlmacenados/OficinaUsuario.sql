--USE GestorDocumentalOIJ

CREATE PROCEDURE SC.PA_InsertarOficinaUsuario
    @pN_OficinaID INT,
    @pN_UsuarioID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la oficina exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina WHERE TN_Id = @pN_OficinaID AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; -- Oficina no encontrada
        END

        -- Validar que el usuario exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Usuario WHERE TN_Id = @pN_UsuarioID AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; -- Usuario no encontrado
        END

        -- Insertar la relación entre oficina y usuario
        INSERT INTO SC.TGESTORDOCUMENTAL_Oficina_Usuario (TN_OficinaID, TN_UsuarioID)
        VALUES (@pN_OficinaID, @pN_UsuarioID);

        COMMIT;
        RETURN 0; -- Inserción exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; -- Error en la ejecución
    END CATCH
END;

CREATE PROCEDURE SC.PA_EliminarOficinaUsuario
    @pN_OficinaID INT,
    @pN_UsuarioID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la relación entre oficina y usuario exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina_Usuario 
                       WHERE TN_OficinaID = @pN_OficinaID AND TN_UsuarioID = @pN_UsuarioID)
        BEGIN
            ROLLBACK;
            RETURN 1; -- Relación no encontrada
        END

        -- Eliminar la relación entre oficina y usuario
        DELETE FROM SC.TGESTORDOCUMENTAL_Oficina_Usuario 
        WHERE TN_OficinaID = @pN_OficinaID AND TN_UsuarioID = @pN_UsuarioID;

        COMMIT;
        RETURN 0; -- Eliminación exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; -- Error en la ejecución
    END CATCH
END;
