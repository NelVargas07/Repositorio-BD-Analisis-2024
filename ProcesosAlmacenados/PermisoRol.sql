--USE GestorDocumentalOIJ

CREATE PROCEDURE SC.PA_InsertarPermisoRol
    @pN_PermisoID INT,
    @pN_RolID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el permiso exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Permiso WHERE TN_Id = @pN_PermisoID AND TB_Activo = 1)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        -- Validar que el usuario exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Rol WHERE TN_Id = @pN_RolID AND TB_Activo = 1)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        -- Insertar la relación entre permiso y usuario
        INSERT INTO SC.TGESTORDOCUMENTAL_Permiso_Rol (TN_PermisoID, TN_RolID)
        VALUES (@pN_PermisoID, @pN_RolID);

        COMMIT;
        RETURN 0; -- Inserción exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; -- Error en la ejecución
    END CATCH
END;

CREATE PROCEDURE SC.PA_EliminarPermisoRol
    @pN_PermisoID INT,
    @pN_RolID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la relación entre permiso y usuario exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Permiso_Rol 
                       WHERE TN_PermisoID = @pN_PermisoID AND TN_RolID = @pN_RolID)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        -- Eliminar la relación entre permiso y usuario
        DELETE FROM SC.TGESTORDOCUMENTAL_Permiso_Rol 
        WHERE TN_PermisoID = @pN_PermisoID AND TN_Rol = @pN_RolID;

        COMMIT;
        RETURN 0; -- Eliminación exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; -- Error en la ejecución
    END CATCH
END;
