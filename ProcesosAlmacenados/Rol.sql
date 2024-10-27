--USE GestorDocumentalOIJ

CREATE PROCEDURE SC.PA_InsertarRol
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500) = NULL,
    @pB_Activo BIT = 1
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que no exista un rol con el mismo nombre
        IF EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Rol WHERE TC_Nombre = @pC_Nombre AND TB_Activo = 1)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        -- Insertar el rol
        INSERT INTO SC.TGESTORDOCUMENTAL_Rol (TC_Nombre, TC_Descripcion, TB_Activo)
        VALUES (@pC_Nombre, @pC_Descripcion, @pB_Activo);

        COMMIT;
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1;
    END CATCH
END;
GO

CREATE PROCEDURE SC.PA_ActualizarRol
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Activo BIT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que exista el rol con el ID especificado
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Rol WHERE TN_Id = @pN_Id)
        BEGIN
            ROLLBACK;
            RETURN 1; -- Indica que el ID no existe
        END

        -- Validar que el nombre no esté en uso por otro rol activo
        IF EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Rol WHERE TC_Nombre = @pC_Nombre AND TN_Id <> @pN_Id AND TB_Activo = 1)
        BEGIN
            ROLLBACK;
            RETURN 1; -- Indica que el nombre ya está en uso por otro rol
        END

        -- Actualizar el rol
        UPDATE SC.TGESTORDOCUMENTAL_Rol
        SET TC_Nombre = @pC_Nombre,
            TC_Descripcion = @pC_Descripcion,
            TB_Activo = @pB_Activo
        WHERE TN_Id = @pN_Id;

        COMMIT;
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1;
    END CATCH
END;

CREATE PROCEDURE SC.PA_EliminarRol
    @pN_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar existencia del rol
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Rol WHERE TN_Id = @pN_Id)
        BEGIN
            ROLLBACK;
            RETURN 1; -- Indica que el ID del rol no existe
        END

        -- Validar que el rol no esté asignado a ningún usuario
        IF EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Usuario WHERE TN_RolID = @pN_Id AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        UPDATE SC.TGESTORDOCUMENTAL_Rol
        SET TB_Activo = 0
        WHERE TN_Id = @pN_Id;

		delete from SC.TGESTORDOCUMENTAL_Permiso_Rol WHERE TN_RolID = @pN_Id

        COMMIT;
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1;
    END CATCH
END;

CREATE PROCEDURE SC.SP_ListarRoles
AS
BEGIN
        -- Seleccionar todos los roles activos
        SELECT TN_Id, TC_Nombre, TC_Descripcion, TB_Activo
        FROM SC.TGESTORDOCUMENTAL_Rol
        WHERE TB_Activo = 1;
END;

CREATE PROCEDURE SC.SP_ListarRolPorId
    @pN_Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el rol especificado exista y esté activo
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Rol WHERE TN_Id = @pN_Id AND TB_Activo = 1)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        -- Seleccionar el rol por ID
        SELECT TN_Id, TC_Nombre, TC_Descripcion, TB_Activo
        FROM SC.TGESTORDOCUMENTAL_Rol
        WHERE TN_Id = @pN_Id AND TB_Activo = 1;

        COMMIT;
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1;
    END CATCH
END;
