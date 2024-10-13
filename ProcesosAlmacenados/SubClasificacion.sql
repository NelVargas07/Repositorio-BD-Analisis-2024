--USE GestorDocumentalOIJ

-- Procedimiento para insertar en GD.TGESTORDOCUMENTAL_Subclasificacion
CREATE PROCEDURE GD.PA_InsertarSubclasificacion
    @pNNombre NVARCHAR(255),
    @pNDescripcion NVARCHAR(500),
    @pNClasificacionID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la clasificación exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pNClasificacionID)
        BEGIN
            RAISERROR('La clasificación con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que no exista una subclasificación con el mismo nombre para la misma clasificación
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TC_Nombre = @pNNombre AND TN_ClasificacionID = @pNClasificacionID)
        BEGIN
            RAISERROR('Ya existe una subclasificación con el mismo nombre en esta clasificación.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva subclasificación
        INSERT INTO GD.TGESTORDOCUMENTAL_Subclasificacion (TC_Nombre, TC_Descripcion, TB_Eliminado, TN_ClasificacionID)
        VALUES (@pNNombre, @pNDescripcion, 0, @pNClasificacionID);

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

-- Procedimiento para actualizar en GD.TGESTORDOCUMENTAL_Subclasificacion
CREATE PROCEDURE GD.PA_ActualizarSubclasificacion
    @pNId INT,
    @pNNombre NVARCHAR(255),
    @pNDescripcion NVARCHAR(500),
    @pBEliminado BIT,
    @pNClasificacionID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la subclasificación exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pNId)
        BEGIN
            RAISERROR('La subclasificación con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que la clasificación exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pNClasificacionID)
        BEGIN
            RAISERROR('La clasificación con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que el nombre no exista para otra subclasificación en la misma clasificación
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TC_Nombre = @pNNombre AND TN_ClasificacionID = @pNClasificacionID AND TN_Id != @pNId)
        BEGIN
            RAISERROR('Ya existe una subclasificación con el mismo nombre en esta clasificación.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar la subclasificación
        UPDATE GD.TGESTORDOCUMENTAL_Subclasificacion
        SET TC_Nombre = @pNNombre,
            TC_Descripcion = @pNDescripcion,
            TB_Eliminado = @pBEliminado,
            TN_ClasificacionID = @pNClasificacionID
        WHERE TN_Id = @pNId;

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

-- Procedimiento para eliminar en GD.TGESTORDOCUMENTAL_Subclasificacion (eliminación lógica)
CREATE PROCEDURE GD.PA_EliminarSubclasificacion
    @pNId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la subclasificación exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pNId)
        BEGIN
            RAISERROR('La subclasificación con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Marcar la subclasificación como eliminada
        UPDATE GD.TGESTORDOCUMENTAL_Subclasificacion
        SET TB_Eliminado = 1
        WHERE TN_Id = @pNId;

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

-- Procedimiento para listar todas las subclasificaciones no eliminadas
CREATE PROCEDURE GD.PA_ListarSubclasificaciones
AS
BEGIN
    SELECT TN_Id, TC_Nombre, TC_Descripcion, TB_Eliminado, TN_ClasificacionID
    FROM GD.TGESTORDOCUMENTAL_Subclasificacion
    WHERE TB_Eliminado = 0;
END;
GO

-- Procedimiento para obtener una subclasificación por ID
CREATE PROCEDURE GD.PA_ObtenerSubclasificacionPorId
    @pNId INT
AS
BEGIN
    -- Validar que la subclasificación exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pNId)
    BEGIN
        RAISERROR('La subclasificación con el Id especificado no existe.', 16, 1);
        RETURN;
    END

    -- Devolver la subclasificación
    SELECT TN_Id, TC_Nombre, TC_Descripcion, TB_Eliminado, TN_ClasificacionID
    FROM GD.TGESTORDOCUMENTAL_Subclasificacion
    WHERE TN_Id = @pNId;
END;
GO
