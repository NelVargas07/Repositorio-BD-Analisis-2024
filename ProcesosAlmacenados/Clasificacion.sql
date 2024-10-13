--USE GESTORDOCUMENTALOIJ

-- Procedimiento para insertar en GD.TGESTORDOCUMENTAL_Clasificacion
CREATE PROCEDURE GD.PA_InsertarClasificacion
    @pNNombre NVARCHAR(255),
    @pNDescripcion NVARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que no exista una clasificaci�n con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TC_Nombre = @pNNombre)
        BEGIN
            RAISERROR('Ya existe una clasificaci�n con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva clasificaci�n
        INSERT INTO GD.TGESTORDOCUMENTAL_Clasificacion (TC_Nombre, TC_Descripcion, TB_Eliminado)
        VALUES (@pNNombre, @pNDescripcion, 0);

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre alg�n error, deshacer la transacci�n
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para actualizar en GD.TGESTORDOCUMENTAL_Clasificacion
CREATE PROCEDURE GD.PA_ActualizarClasificacion
    @pNId INT,
    @pNNombre NVARCHAR(255),
    @pNDescripcion NVARCHAR(500),
    @pBEliminado BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la clasificaci�n exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pNId)
        BEGIN
            RAISERROR('La clasificaci�n con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que el nombre no exista para otra clasificaci�n
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TC_Nombre = @pNNombre AND TN_Id != @pNId)
        BEGIN
            RAISERROR('Ya existe una clasificaci�n con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar la clasificaci�n
        UPDATE GD.TGESTORDOCUMENTAL_Clasificacion
        SET TC_Nombre = @pNNombre,
            TC_Descripcion = @pNDescripcion,
            TB_Eliminado = @pBEliminado
        WHERE TN_Id = @pNId;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre alg�n error, deshacer la transacci�n
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para eliminar en GD.TGESTORDOCUMENTAL_Clasificacion (eliminaci�n l�gica)
CREATE PROCEDURE GD.PA_EliminarClasificacion
    @pNId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la clasificaci�n exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pNId)
        BEGIN
            RAISERROR('La clasificaci�n con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Marcar la clasificaci�n como eliminada
        UPDATE GD.TGESTORDOCUMENTAL_Clasificacion
        SET TB_Eliminado = 1
        WHERE TN_Id = @pNId;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre alg�n error, deshacer la transacci�n
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

-- Procedimiento para obtener una clasificaci�n por ID
CREATE PROCEDURE GD.PA_ObtenerClasificacionPorId
    @pNId INT
AS
BEGIN
    -- Validar que la clasificaci�n exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pNId)
    BEGIN
        RAISERROR('La clasificaci�n con el Id especificado no existe.', 16, 1);
        RETURN;
    END

    -- Devolver la clasificaci�n
    SELECT TN_Id, TC_Nombre, TC_Descripcion, TB_Eliminado
    FROM GD.TGESTORDOCUMENTAL_Clasificacion
    WHERE TN_Id = @pNId;
END;
GO
