--USE GestorDocumentalOIJ

CREATE PROCEDURE GD.PA_ActualizarTipoDocumento
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que el tipo de documento exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('El tipo de documento con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END
        
        -- Validar que el nombre no exista para otro tipo de documento
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TC_Nombre = @pC_Nombre AND TN_Id != @pN_Id)
        BEGIN
            RAISERROR('Ya existe un tipo de documento con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar el tipo de documento
        UPDATE GD.TGESTORDOCUMENTAL_TipoDocumento
        SET TC_Nombre = @pC_Nombre,
            TC_Descripcion = @pC_Descripcion,
            TB_Eliminado = @pB_Eliminado
        WHERE TN_Id = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

CREATE PROCEDURE GD.PA_InsertarTipoDocumento
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que no exista un tipo de documento con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TC_Nombre = @pC_Nombre)
        BEGIN
            RAISERROR('Ya existe un tipo de documento con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar el nuevo tipo de documento
        INSERT INTO GD.TGESTORDOCUMENTAL_TipoDocumento (TC_Nombre, TC_Descripcion, TB_Eliminado)
        VALUES (@pC_Nombre, @pC_Descripcion, 0);

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

CREATE PROCEDURE GD.PA_EliminarTipoDocumento
    @pN_Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el tipo de documento exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('El tipo de documento con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminado logico
        UPDATE GD.TGESTORDOCUMENTAL_TipoDocumento
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

CREATE PROCEDURE GD.PA_ListarTiposDocumento
AS
BEGIN
    -- Devolver todos los tipos de documento que no han sido eliminados
    SELECT TN_Id, TC_Nombre, TC_Descripcion, TB_Eliminado
    FROM GD.TGESTORDOCUMENTAL_TipoDocumento
    WHERE TB_Eliminado = 0;
END;
GO

CREATE PROCEDURE GD.PA_ObtenerTipoDocumentoPorId
    @pN_Id INT
AS
BEGIN
    -- Validar que el tipo de documento exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('El tipo de documento con el Id especificado no existe.', 16, 1);
        RETURN 1;
    END

    -- Devolver el tipo de documento
    SELECT TN_Id, TC_Nombre, TC_Descripcion, TB_Eliminado
    FROM GD.TGESTORDOCUMENTAL_TipoDocumento
    WHERE TN_Id = @pN_Id AND TB_Eliminado = 0;
END;
GO
