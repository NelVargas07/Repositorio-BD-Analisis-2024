--USE GestorDocumentalOIJ

-- Procedimiento para actualizar categoría
CREATE PROCEDURE GD.PA_ActualizarCategoria
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la categoría exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Categoria WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('La categoría con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END
        
        -- Validar que el nombre no exista para otra categoría
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Categoria WHERE TC_Nombre = @pC_Nombre AND TN_Id != @pN_Id)
        BEGIN
            RAISERROR('Ya existe una categoría con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar la categoría
        UPDATE GD.TGESTORDOCUMENTAL_Categoria
        SET TC_Nombre = @pC_Nombre,
            TC_Descripcion = @pC_Descripcion,
            TB_Eliminado = @pB_Eliminado
        WHERE TN_Id = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        -- Si ocurre algún error, deshacer la transacción
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para insertar nueva categoría
CREATE PROCEDURE GD.PA_InsertarCategoria
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que no exista una categoría con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Categoria WHERE TC_Nombre = @pC_Nombre)
        BEGIN
            RAISERROR('Ya existe una categoría con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva categoría
        INSERT INTO GD.TGESTORDOCUMENTAL_Categoria (TC_Nombre, TC_Descripcion, TB_Eliminado)
        VALUES (@pC_Nombre, @pC_Descripcion, 0);

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre algún error, deshacer la transacción
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para eliminar categoría
CREATE PROCEDURE GD.PA_EliminarCategoria
    @pN_Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la categoría exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Categoria WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('La categoría con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminar la categoría (eliminado lógico)
        UPDATE GD.TGESTORDOCUMENTAL_Categoria
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre algún error, deshacer la transacción
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para listar categorías activas
CREATE PROCEDURE GD.PA_ListarCategorias
AS
BEGIN
    SELECT TN_Id, TC_Nombre, TC_Descripcion, TB_Eliminado
    FROM GD.TGESTORDOCUMENTAL_Categoria
    WHERE TB_Eliminado = 0;
END;
GO

-- Procedimiento para obtener categoría por Id
CREATE PROCEDURE GD.PA_ObtenerCategoriaPorId
    @pN_Id INT
AS
BEGIN
    -- Validar que la categoría exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Categoria WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('La categoría con el Id especificado no existe.', 16, 1);
        RETURN;
    END

    -- Devolver la categoría
    SELECT TN_Id, TC_Nombre, TC_Descripcion, TB_Eliminado
    FROM GD.TGESTORDOCUMENTAL_Categoria
    WHERE TN_Id = @pN_Id;
END;
GO
