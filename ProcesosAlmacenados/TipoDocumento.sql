--USE GestorDocumentalOIJ

CREATE PROCEDURE sp_ActualizarTipoDocumento
    @Id INT,
    @Nombre NVARCHAR(255),
    @Descripcion NVARCHAR(500),
    @Eliminado BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que el tipo de documento exista
        IF NOT EXISTS (SELECT 1 FROM TipoDocumento WHERE Id = @Id)
        BEGIN
            RAISERROR('El tipo de documento con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END
        
        -- Validar que el nombre no exista para otro tipo de documento
        IF EXISTS (SELECT 1 FROM TipoDocumento WHERE Nombre = @Nombre AND Id != @Id)
        BEGIN
            RAISERROR('Ya existe un tipo de documento con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar el tipo de documento
        UPDATE TipoDocumento
        SET Nombre = @Nombre,
            Descripcion = @Descripcion,
            Eliminado = @Eliminado
        WHERE Id = @Id;

        COMMIT TRANSACTION;
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        -- Si ocurre algún error, deshacer la transacción
        ROLLBACK TRANSACTION;

        -- Retornar código de error
        RETURN 1;
    END CATCH
END;
GO

CREATE PROCEDURE sp_InsertarTipoDocumento
    @Nombre NVARCHAR(255),
    @Descripcion NVARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que no exista un tipo de documento con el mismo nombre
        IF EXISTS (SELECT 1 FROM TipoDocumento WHERE Nombre = @Nombre)
        BEGIN
            RAISERROR('Ya existe un tipo de documento con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar el nuevo tipo de documento
        INSERT INTO TipoDocumento (Nombre, Descripcion, Eliminado)
        VALUES (@Nombre, @Descripcion, 0);

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre algún error, deshacer la transacción
        ROLLBACK TRANSACTION;

        -- Retornar código de error
        RETURN 1;
    END CATCH
END;
GO

CREATE PROCEDURE sp_EliminarTipoDocumento
    @Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el tipo de documento exista
        IF NOT EXISTS (SELECT 1 FROM TipoDocumento WHERE Id = @Id)
        BEGIN
            RAISERROR('El tipo de documento con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminar el tipo de documento (eliminado lógico)
        UPDATE TipoDocumento
        SET Eliminado = 1
        WHERE Id = @Id;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre algún error, deshacer la transacción
        ROLLBACK TRANSACTION;

        -- Retornar código de error
        RETURN 1;
    END CATCH
END;
GO

CREATE PROCEDURE sp_ListarTiposDocumento
AS
BEGIN
    -- Devolver todos los tipos de documento que no han sido eliminados
    SELECT Id, Nombre, Descripcion, Eliminado
    FROM TipoDocumento
    WHERE Eliminado = 0;
END;
GO

CREATE PROCEDURE sp_ObtenerTipoDocumentoPorId
    @Id INT
AS
BEGIN
    -- Validar que el tipo de documento exista
    IF NOT EXISTS (SELECT 1 FROM TipoDocumento WHERE Id = @Id)
    BEGIN
        RAISERROR('El tipo de documento con el Id especificado no existe.', 16, 1);
        RETURN 1;
    END

    -- Devolver el tipo de documento
    SELECT Id, Nombre, Descripcion, Eliminado
    FROM TipoDocumento
    WHERE Id = @Id;
END;
GO
