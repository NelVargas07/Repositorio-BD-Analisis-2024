--USE GestorDocumentalOIJ

CREATE PROCEDURE sp_ActualizarNorma
    @Id INT,
    @Nombre NVARCHAR(255),
    @Descripcion NVARCHAR(500),
    @Eliminado BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la norma exista
        IF NOT EXISTS (SELECT 1 FROM Norma WHERE Id = @Id)
        BEGIN
            RAISERROR('La norma con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END
        
        -- Validar que el nombre no exista para otra norma
        IF EXISTS (SELECT 1 FROM Norma WHERE Nombre = @Nombre AND Id != @Id)
        BEGIN
            RAISERROR('Ya existe una norma con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar la norma
        UPDATE Norma
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

CREATE PROCEDURE sp_InsertarNorma
    @Nombre NVARCHAR(255),
    @Descripcion NVARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que no exista una norma con el mismo nombre
        IF EXISTS (SELECT 1 FROM Norma WHERE Nombre = @Nombre)
        BEGIN
            RAISERROR('Ya existe una norma con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva norma
        INSERT INTO Norma (Nombre, Descripcion, Eliminado)
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

CREATE PROCEDURE sp_ListarNormas
AS
BEGIN
    -- Devolver todas las normas que no han sido eliminadas
    SELECT Id, Nombre, Descripcion, Eliminado
    FROM Norma
    WHERE Eliminado = 0;
END;
GO

CREATE PROCEDURE sp_ObtenerNormaPorId
    @Id INT
AS
BEGIN
    -- Validar que la norma exista
    IF NOT EXISTS (SELECT 1 FROM Norma WHERE Id = @Id)
    BEGIN
        RAISERROR('La norma con el Id especificado no existe.', 16, 1);
        RETURN 1;
    END

    -- Devolver la norma
    SELECT Id, Nombre, Descripcion, Eliminado
    FROM Norma
    WHERE Id = @Id;
END;
GO

CREATE PROCEDURE sp_EliminarNorma
    @Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la norma exista
        IF NOT EXISTS (SELECT 1 FROM Norma WHERE Id = @Id)
        BEGIN
            RAISERROR('La norma con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que no existan etapas asociadas a esta norma
        IF EXISTS (SELECT 1 FROM Etapa WHERE NormaID = @Id AND Eliminado = 0)
        BEGIN
            RAISERROR('No se puede eliminar la norma porque existen etapas asociadas.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminar la norma (eliminado lógico)
        UPDATE Norma
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
