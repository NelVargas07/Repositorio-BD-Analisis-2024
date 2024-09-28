--USE GestorDocumentalOIJ

CREATE PROCEDURE sp_ActualizarEtapa
    @Id INT,
    @Nombre NVARCHAR(255),
    @Descripcion NVARCHAR(500),
    @Eliminado BIT,
    @NormaID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la etapa exista
        IF NOT EXISTS (SELECT 1 FROM Etapa WHERE Id = @Id)
        BEGIN
            RAISERROR('La etapa con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END
        
        -- Validar que la norma exista
        IF NOT EXISTS (SELECT 1 FROM Norma WHERE Id = @NormaID)
        BEGIN
            RAISERROR('La norma con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END
        
        -- Validar que el nombre no exista para otra etapa
        IF EXISTS (SELECT 1 FROM Etapa WHERE Nombre = @Nombre AND Id != @Id)
        BEGIN
            RAISERROR('Ya existe una etapa con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar la etapa
        UPDATE Etapa
        SET Nombre = @Nombre,
            Descripcion = @Descripcion,
            Eliminado = @Eliminado,
            NormaID = @NormaID
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

CREATE PROCEDURE sp_InsertarEtapa
    @Nombre NVARCHAR(255),
    @Descripcion NVARCHAR(500),
    @NormaID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la norma exista
        IF NOT EXISTS (SELECT 1 FROM Norma WHERE Id = @NormaID)
        BEGIN
            RAISERROR('La norma con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END
        
        -- Validar que no exista una etapa con el mismo nombre
        IF EXISTS (SELECT 1 FROM Etapa WHERE Nombre = @Nombre)
        BEGIN
            RAISERROR('Ya existe una etapa con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva etapa
        INSERT INTO Etapa (Nombre, Descripcion, Eliminado, NormaID)
        VALUES (@Nombre, @Descripcion, 0, @NormaID);

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

CREATE PROCEDURE sp_EliminarEtapa
    @Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la etapa exista
        IF NOT EXISTS (SELECT 1 FROM Etapa WHERE Id = @Id)
        BEGIN
            RAISERROR('La etapa con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminar la etapa (eliminado lógico)
        UPDATE Etapa
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

CREATE PROCEDURE sp_ListarEtapas
AS
BEGIN
    -- Devolver todas las etapas que no han sido eliminadas
    SELECT Id, Nombre, Descripcion, Eliminado, NormaID
    FROM Etapa
    WHERE Eliminado = 0;
END;
GO

CREATE PROCEDURE sp_ObtenerEtapaPorId
    @Id INT
AS
BEGIN
    -- Validar que la etapa exista
    IF NOT EXISTS (SELECT 1 FROM Etapa WHERE Id = @Id)
    BEGIN
        RAISERROR('La etapa con el Id especificado no existe.', 16, 1);
        RETURN 1;
    END

    -- Devolver la etapa
    SELECT Id, Nombre, Descripcion, Eliminado, NormaID
    FROM Etapa
    WHERE Id = @Id;
END;
GO

CREATE PROCEDURE sp_ObtenerEtapasPorNormaId
    @NormaID INT
AS
BEGIN
    -- Validar que la norma exista
    IF NOT EXISTS (SELECT 1 FROM Norma WHERE Id = @NormaID)
    BEGIN
        RAISERROR('La norma con el Id especificado no existe.', 16, 1);
        RETURN 1;
    END

    -- Devolver todas las etapas que corresponden al NormaID y no están eliminadas
    SELECT Id, Nombre, Descripcion, Eliminado, NormaID
    FROM Etapa
    WHERE NormaID = @NormaID AND Eliminado = 0;
END;
GO
