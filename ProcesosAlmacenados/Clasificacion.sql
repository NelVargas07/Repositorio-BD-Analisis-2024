--USE GESTORDOCUMENTALOIJ

-- Procedimiento para insertar en GD.TGESTORDOCUMENTAL_Clasificacion
CREATE PROCEDURE GD.PA_InsertarClasificacion
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que no exista una clasificacion con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TC_Nombre = @pC_Nombre)
        BEGIN
            RAISERROR('Ya existe una clasificacion con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva clasificacion
        INSERT INTO GD.TGESTORDOCUMENTAL_Clasificacion (TC_Nombre, TC_Descripcion, TB_Eliminado)
        VALUES (@pC_Nombre, @pC_Descripcion, 0);

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre algun error, deshacer la transaccion
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para actualizar en GD.TGESTORDOCUMENTAL_Clasificacion
CREATE PROCEDURE GD.PA_ActualizarClasificacion
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la clasificacion exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('La clasificacion con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que el nombre no exista para otra clasificacion
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TC_Nombre = @pC_Nombre AND TN_Id != @pN_Id)
        BEGIN
            RAISERROR('Ya existe una clasificacion con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar la clasificacion
        UPDATE GD.TGESTORDOCUMENTAL_Clasificacion
        SET TC_Nombre = @pC_Nombre,
            TC_Descripcion = @pC_Descripcion,
            TB_Eliminado = @pB_Eliminado
        WHERE TN_Id = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre algun error, deshacer la transaccion
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para eliminar en GD.TGESTORDOCUMENTAL_Clasificacion (eliminacion logica)
CREATE PROCEDURE GD.PA_EliminarClasificacion
    @pN_Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la clasificacion exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('La clasificacion con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Marcar la clasificacion como eliminada
        UPDATE GD.TGESTORDOCUMENTAL_Clasificacion
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre algun error, deshacer la transaccion
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para listar todas las clasificaciones no eliminadas
CREATE PROCEDURE GD.PA_ListarClasificaciones
AS
BEGIN
    SELECT TN_Id, TC_Nombre, TC_Descripcion, TB_Eliminado
    FROM GD.TGESTORDOCUMENTAL_Clasificacion
    WHERE TB_Eliminado = 0;
END;
GO

-- Procedimiento para obtener una clasificacion por ID
CREATE PROCEDURE GD.PA_ObtenerClasificacionPorId
    @pN_Id INT
AS
BEGIN
    -- Validar que la clasificacion exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('La clasificacion con el Id especificado no existe.', 16, 1);
        RETURN;
    END

    -- Devolver la clasificacion
    SELECT TN_Id, TC_Nombre, TC_Descripcion, TB_Eliminado
    FROM GD.TGESTORDOCUMENTAL_Clasificacion
    WHERE TN_Id = @pN_Id;
END;
GO
