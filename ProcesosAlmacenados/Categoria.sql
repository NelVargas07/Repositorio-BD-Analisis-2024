--USE GestorDocumentalOIJ

CREATE PROCEDURE sp_ActualizarCategoria
    @Id INT,
    @Nombre NVARCHAR(255),
    @Descripcion NVARCHAR(500),
    @Eliminado BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la categoría exista
        IF NOT EXISTS (SELECT 1 FROM Categoria WHERE Id = @Id)
        BEGIN
            RAISERROR('La categoría con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END
        
        -- Validar que el nombre no exista para otra categoría
        IF EXISTS (SELECT 1 FROM Categoria WHERE Nombre = @Nombre AND Id != @Id)
        BEGIN
            RAISERROR('Ya existe una categoría con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar la categoría
        UPDATE Categoria
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

CREATE PROCEDURE sp_InsertarCategoria
    @Nombre NVARCHAR(255),
    @Descripcion NVARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que no exista una categoría con el mismo nombre
        IF EXISTS (SELECT 1 FROM Categoria WHERE Nombre = @Nombre)
        BEGIN
            RAISERROR('Ya existe una categoría con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva categoría
        INSERT INTO Categoria (Nombre, Descripcion, Eliminado)
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

CREATE PROCEDURE sp_EliminarCategoria
    @Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la categoría exista
        IF NOT EXISTS (SELECT 1 FROM Categoria WHERE Id = @Id)
        BEGIN
            RAISERROR('La categoría con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminar la categoría (eliminado lógico)
        UPDATE Categoria
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

CREATE PROCEDURE sp_ListarCategorias
AS
BEGIN
    SELECT Id, Nombre, Descripcion, Eliminado
    FROM Categoria
    WHERE Eliminado = 0;
END;
GO

CREATE PROCEDURE sp_ObtenerCategoriaPorId
    @Id INT
AS
BEGIN
    -- Validar que la categoría exista
    IF NOT EXISTS (SELECT 1 FROM Categoria WHERE Id = @Id)
    BEGIN
        RAISERROR('La categoría con el Id especificado no existe.', 16, 1);
        RETURN;
    END

    -- Devolver la categoría
    SELECT Id, Nombre, Descripcion, Eliminado
    FROM Categoria
    WHERE Id = @Id;
END;
GO
