--USE GestorDocumentalOIJ

CREATE PROCEDURE SC.PA_InsertarPermisoOficina
    @pN_PermisoID INT,
    @pN_OficinaID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el permiso exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Permiso WHERE TN_Id = @pN_PermisoID AND TB_Activo = 1)
        BEGIN
            ROLLBACK;
            RETURN 1; -- Permiso no encontrado
        END

        -- Validar que el usuario exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina WHERE TN_Id = @pN_OficinaID AND TB_Eliminado = 1)
        BEGIN
            ROLLBACK;
            RETURN 1; -- Usuario no encontrado
        END

        -- Insertar la relación entre permiso y usuario
        INSERT INTO SC.TGESTORDOCUMENTAL_Permiso_Oficina (TN_PermisoID, TN_OficinaID)
        VALUES (@pN_PermisoID, @pN_OficinaID);

        COMMIT;
        RETURN 0; -- Inserción exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; -- Error en la ejecución
    END CATCH
END;
GO

CREATE PROCEDURE SC.PA_EliminarPermisoOficina
    @pN_PermisoID INT,
    @pN_OficinaID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la relación entre permiso y usuario exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Permiso_Oficina 
                       WHERE TN_PermisoID = @pN_PermisoID AND TN_OficinaID = @pN_OficinaID)
        BEGIN
            ROLLBACK;
            RETURN 1; -- Relación no encontrada
        END

        -- Eliminar la relación entre permiso y usuario
        DELETE FROM SC.TGESTORDOCUMENTAL_Permiso_Oficina
        WHERE TN_PermisoID = @pN_PermisoID AND TN_OficinaID = @pN_OficinaID;

        COMMIT;
        RETURN 0; -- Eliminación exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; -- Error en la ejecución
    END CATCH
END;
GO