--USE GestorDocumentalOIJ

-- SP para insertar un nuevo registro en GD.TGESTORDOCUMENTAL_DocTo
CREATE PROCEDURE GD.PA_sp_InsertarDocTo
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que no exista un DocTo con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TC_Nombre = @pC_Nombre)
        BEGIN
            RAISERROR('Ya existe un DocTo con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar el nuevo DocTo
        INSERT INTO GD.TGESTORDOCUMENTAL_DocTo (TC_Nombre, TC_Descripcion, TB_Eliminado)
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

-- SP para actualizar un registro en GD.TGESTORDOCUMENTAL_DocTo
CREATE PROCEDURE GD.PA_sp_ActualizarDocTo
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el DocTo exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('El DocTo con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END
        
        -- Validar que el nombre no exista para otro DocTo
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TC_Nombre = @pC_Nombre AND TN_Id != @pN_Id)
        BEGIN
            RAISERROR('Ya existe un DocTo con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar el DocTo
        UPDATE GD.TGESTORDOCUMENTAL_DocTo
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

-- SP para eliminar un registro en GD.TGESTORDOCUMENTAL_DocTo (eliminado lógico)
CREATE PROCEDURE GD.PA_sp_EliminarDocTo
    @pN_Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el DocTo exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('El DocTo con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminar lógicamente el DocTo
        UPDATE GD.TGESTORDOCUMENTAL_DocTo
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

-- SP para listar todos los registros no eliminados en GD.TGESTORDOCUMENTAL_DocTo
CREATE PROCEDURE GD.PA_sp_ListarDocTos
AS
BEGIN
    SELECT TN_Id, TC_Nombre, TC_Descripcion, TB_Eliminado
    FROM GD.TGESTORDOCUMENTAL_DocTo
    WHERE TB_Eliminado = 0;
END;
GO

-- SP para obtener un registro específico en GD.TGESTORDOCUMENTAL_DocTo por su ID
CREATE PROCEDURE GD.PA_sp_ObtenerDocToPorId
    @pN_Id INT
AS
BEGIN
    -- Validar que el DocTo exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('El DocTo con el Id especificado no existe.', 16, 1);
        RETURN;
    END

    -- Devolver el DocTo
    SELECT TN_Id, TC_Nombre, TC_Descripcion, TB_Eliminado
    FROM GD.TGESTORDOCUMENTAL_DocTo
    WHERE TN_Id = @pN_Id AND TB_Eliminado = 0;
END;
GO
