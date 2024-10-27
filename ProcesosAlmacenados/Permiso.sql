--USE GestorDocumentalOIJ

CREATE PROCEDURE SC.PA_InsertarPermiso
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que no exista un permiso con el mismo nombre
        IF EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Permiso WHERE TC_Nombre = @pC_Nombre AND TB_Activo = 1)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        -- Insertar nuevo permiso
        INSERT INTO SC.TGESTORDOCUMENTAL_Permiso (TC_Nombre, TC_Descripcion, TB_Activo)
        VALUES (@pC_Nombre, @pC_Descripcion, 1);

        COMMIT;
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; 
    END CATCH
END;

CREATE PROCEDURE SC.PA_ActualizarPermiso
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el permiso exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Permiso WHERE TN_Id = @pN_Id AND TB_Activo = 1)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        -- Validar que no exista otro permiso con el mismo nombre
        IF EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Permiso WHERE TC_Nombre = @pC_Nombre AND TN_Id <> @pN_Id AND TB_Activo = 1)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        -- Actualizar el permiso
        UPDATE SC.TGESTORDOCUMENTAL_Permiso
        SET TC_Nombre = @pC_Nombre,
            TC_Descripcion = @pC_Descripcion
        WHERE TN_Id = @pN_Id;

        COMMIT;
        RETURN 0; -- Actualización exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; -- Error en la ejecución
    END CATCH
END;

CREATE PROCEDURE SC.PA_EliminarPermiso
    @pN_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el permiso exista y no esté ya eliminado
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Permiso WHERE TN_Id = @pN_Id AND TB_Activo = 1)
        BEGIN
            ROLLBACK;
            RETURN 1; -- Permiso no encontrado o ya eliminado
        END

		--IF EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Usuario WHERE TN_RolID = @pN_Id AND TB_Eliminado = 0)
  --      BEGIN
  --          ROLLBACK;
  --          RETURN 1; 
  --      END

		--IF EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Usuario WHERE TN_RolID = @pN_Id AND TB_Eliminado = 0)
  --      BEGIN
  --          ROLLBACK;
  --          RETURN 1; 
  --      END

        -- Eliminar el permiso (soft delete)
        UPDATE SC.TGESTORDOCUMENTAL_Permiso
        SET TB_Activo = 0
        WHERE TN_Id = @pN_Id;

        COMMIT;
        RETURN 0; -- Eliminación exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; -- Error en la ejecución
    END CATCH
END;


CREATE PROCEDURE SC.PA_ListarPermisos
AS
BEGIN

    SELECT TN_Id, TC_Nombre, TC_Descripcion, TB_Activo
    FROM SC.TGESTORDOCUMENTAL_Permiso
    WHERE TB_Activo = 1;
END;

CREATE PROCEDURE SC.PA_ListarPermisoPorID
    @pN_Id INT
AS
BEGIN
    SELECT TN_Id, TC_Nombre, TC_Descripcion, TB_Activo
    FROM SC.TGESTORDOCUMENTAL_Permiso
    WHERE TN_Id = @pN_Id AND TB_Activo = 1;
END;
