--USE GestorDocumentalOIJ

CREATE PROCEDURE SC.PA_InsertarUsuario
    @pC_Correo NVARCHAR(255),
    @pC_Nombre NVARCHAR(255),
    @pC_Password NVARCHAR(255),
    @pC_Apellido NVARCHAR(255),
    @pN_RolID INT,
    @pB_Activo BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Usuario WHERE TC_Correo = @pC_Correo AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        -- Validar que el rol exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Rol WHERE TN_Id = @pN_RolID AND TB_Activo = 1)
        BEGIN
            ROLLBACK;
            RETURN 1;
        END

        -- Insertar el usuario
        INSERT INTO SC.TGESTORDOCUMENTAL_Usuario (TC_Correo, TC_Nombre, TC_Password, TC_Apellido, TN_RolID, TB_Activo, TB_Eliminado)
        VALUES (@pC_Correo, @pC_Nombre, @pC_Password, @pC_Apellido, @pN_RolID, @pB_Activo, 0);

        COMMIT;
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1;
    END CATCH
END;
GO

CREATE PROCEDURE SC.PA_ActualizarUsuario
    @pN_Id INT,
    @pC_Correo NVARCHAR(255),
    @pC_Nombre NVARCHAR(255),
    @pC_Password NVARCHAR(255),
    @pC_Apellido NVARCHAR(255),
    @pN_RolID INT,
    @pB_Activo BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el usuario exista y no est� eliminado
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Usuario WHERE TN_Id = @pN_Id AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        -- Validar que el correo no est� en uso por otro usuario activo
        IF EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Usuario WHERE TC_Correo = @pC_Correo AND TN_Id <> @pN_Id AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        -- Validar que el rol exista y est� activo
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Rol WHERE TN_Id = @pN_RolID AND TB_Activo = 1)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        -- Actualizar el usuario
        UPDATE SC.TGESTORDOCUMENTAL_Usuario
        SET TC_Correo = @pC_Correo,
            TC_Nombre = @pC_Nombre,
            TC_Password = @pC_Password,
            TC_Apellido = @pC_Apellido,
            TN_RolID = @pN_RolID,
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
GO

CREATE PROCEDURE SC.PA_EliminarUsuario
    @pN_Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
		
		IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Version WHERE TN_UsuarioID = @pN_Id AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1;
        END

        -- Validar que el usuario exista y no est� eliminado
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Usuario WHERE TN_Id = @pN_Id AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        UPDATE SC.TGESTORDOCUMENTAL_Usuario
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

		delete from SC.TGESTORDOCUMENTAL_Oficina_Usuario WHERE TN_UsuarioID = @pN_Id

        COMMIT;
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1;
    END CATCH
END;

CREATE OR ALTER PROCEDURE SC.PA_ListarUsuarios
AS
BEGIN
       
        SELECT TN_Id AS Id, TC_Correo AS Correo, TC_Password as Password,TC_Nombre AS Nombre, TC_Apellido as Apellido, TN_RolID as RolID, TB_Activo AS Activo, TB_Eliminado as Eliminado
        FROM SC.TGESTORDOCUMENTAL_Usuario
        WHERE TB_Eliminado = 0;

END;
GO

CREATE OR ALTER PROCEDURE SC.PA_ListarUsuarioPorId
    @pN_Id INT
AS
BEGIN
        -- Validar que el usuario exista y est� activo
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Usuario WHERE TN_Id = @pN_Id AND TB_Eliminado = 0)
        BEGIN
            RETURN ; 
        END

        -- Seleccionar el usuario
        SELECT TN_Id AS Id, TC_Correo AS Correo, TC_Password as Password, TC_Nombre AS Nombre, TC_Apellido as Apellido, TN_RolID as RolID, TB_Activo AS Activo, TB_Eliminado as Eliminado
        FROM SC.TGESTORDOCUMENTAL_Usuario
        WHERE TN_Id = @pN_Id AND TB_Eliminado = 0;

END;
GO

CREATE PROCEDURE SC.PA_ValidarLoginUsuario
    @pC_Correo NVARCHAR(255),
    @pC_Password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el usuario exista, est� activo y no est� eliminado
        IF EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Usuario WHERE TC_Correo = @pC_Correo AND TC_Password = @pC_Password 
              AND TB_Activo = 1 AND TB_Eliminado = 0)
        BEGIN
            COMMIT;
            RETURN 0; 
        END
        ELSE
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; 
    END CATCH
END;
