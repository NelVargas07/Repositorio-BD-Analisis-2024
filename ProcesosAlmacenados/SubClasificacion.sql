--USE GestorDocumentalOIJ

-- Procedimiento para insertar en GD.TGESTORDOCUMENTAL_Subclasificacion
CREATE PROCEDURE GD.PA_InsertarSubclasificacion
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pN_ClasificacionID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la clasificacion exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pN_ClasificacionID)
        BEGIN
            RAISERROR('La clasificaci�n con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que no exista una subclasificacion con el mismo nombre para la misma clasificacion
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TC_Nombre = @pC_Nombre AND TN_ClasificacionID = @pN_ClasificacionID)
        BEGIN
            RAISERROR('Ya existe una subclasificaci�n con el mismo nombre en esta clasificaci�n.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva subclasificacion
        INSERT INTO GD.TGESTORDOCUMENTAL_Subclasificacion (TC_Nombre, TC_Descripcion, TB_Eliminado, TN_ClasificacionID)
        VALUES (@pC_Nombre, @pC_Descripcion, 0, @pN_ClasificacionID);

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

-- Procedimiento para actualizar en GD.TGESTORDOCUMENTAL_Subclasificacion
CREATE PROCEDURE GD.PA_ActualizarSubclasificacion
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT,
    @pN_ClasificacionID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la subclasificacion exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('La subclasificacion con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que la clasificacion exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pN_ClasificacionID)
        BEGIN
            RAISERROR('La clasificacion con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que el nombre no exista para otra subclasificacion en la misma clasificacion
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TC_Nombre = @pC_Nombre AND TN_ClasificacionID = @pN_ClasificacionID AND TN_Id != @pN_Id)
        BEGIN
            RAISERROR('Ya existe una subclasificacion con el mismo nombre en esta clasificacion.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar la subclasificacion
        UPDATE GD.TGESTORDOCUMENTAL_Subclasificacion
        SET TC_Nombre = @pC_Nombre,
            TC_Descripcion = @pC_Descripcion,
            TB_Eliminado = @pB_Eliminado,
            TN_ClasificacionID = @pN_ClasificacionID
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

-- Procedimiento para eliminar en GD.TGESTORDOCUMENTAL_Subclasificacion (eliminacion logica)
CREATE PROCEDURE GD.PA_EliminarSubclasificacion
    @pN_Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la subclasificacion exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('La subclasificacion con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Marcar la subclasificacion como eliminada
        UPDATE GD.TGESTORDOCUMENTAL_Subclasificacion
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

-- Procedimiento para listar todas las subclasificaciones no eliminadas
CREATE PROCEDURE GD.PA_ListarSubclasificaciones
AS
BEGIN
    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado,
	TN_ClasificacionID as ClasificacionID
    FROM GD.TGESTORDOCUMENTAL_Subclasificacion
    WHERE TB_Eliminado = 0;
END;
GO

-- Procedimiento para obtener una subclasificacion por ID
CREATE PROCEDURE GD.PA_ObtenerSubclasificacionPorId
    @pN_Id INT
AS
BEGIN
    -- Validar que la subclasificacion exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('La subclasificacion con el Id especificado no existe.', 16, 1);
        RETURN;
    END

    -- Devolver la subclasificacion
    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado,
	TN_ClasificacionID as ClasificacionID
    FROM GD.TGESTORDOCUMENTAL_Subclasificacion
    WHERE TN_Id = @pN_Id;
END;
GO

---------nuevos-------------

--USE GestorDocumentalOIJ

-- Procedimiento para insertar en GD.TGESTORDOCUMENTAL_Subclasificacion
CREATE PROCEDURE GD.PA_InsertarSubclasificacion
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pN_ClasificacionID INT = NULL,
	@pN_UsuarioID INT, 
    @pN_OficinaID INT  
AS
BEGIN

	DECLARE @pC_Operacion NVARCHAR(255) = 'Insertar SubClasificacion';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la clasificacion exista
        IF @pN_ClasificacionID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pN_ClasificacionID)
        BEGIN
            SET @pC_Comando = 'La clasificacion con el Id '+ CAST(@pN_ClasificacionID AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;

            RAISERROR(@pC_Comando, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que no exista una subclasificacion con el mismo nombre para la misma clasificacion
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TC_Nombre = @pC_Nombre AND TN_ClasificacionID = @pN_ClasificacionID)
        BEGIN
            SET @pC_Comando = 'Ya existe una subclasificacion asignada a esa clasificacion con el mismo nombre ' + @pC_Nombre;
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;

            RAISERROR(@pC_Comando, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva subclasificacion
        INSERT INTO GD.TGESTORDOCUMENTAL_Subclasificacion (TC_Nombre, TC_Descripcion, TB_Eliminado, TN_ClasificacionID)
        VALUES (@pC_Nombre, @pC_Descripcion, 0, @pN_ClasificacionID);

		SET @pC_Comando = 'Insertar nueva subclasificacion: ' + @pC_Nombre;
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        SET @pC_Comando = ERROR_MESSAGE();
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para actualizar en GD.TGESTORDOCUMENTAL_Subclasificacion
CREATE PROCEDURE GD.PA_ActualizarSubclasificacion
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT,
    @pN_ClasificacionID INT = NULL,
	@pN_UsuarioID INT, -- ID del usuario
    @pN_OficinaID INT  -- ID de la oficina
AS
BEGIN

	DECLARE @pC_Operacion NVARCHAR(255) = 'Actualizar SubClasificacion';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la subclasificacion exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pN_Id)
        BEGIN
            SET @pC_Comando = 'La subclasificacaion con el Id '+ CAST(@pN_Id AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;

            RAISERROR(@pC_Comando, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

		-- Validar que la norma exista o si viene nula
        IF @pN_ClasificacionID IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pN_ClasificacionID)
            BEGIN
                SET @pC_Comando = 'La clasificacion con el Id '+ CAST(@pN_ClasificacionID AS NVARCHAR(10)) +' no existe.';
                EXEC GD.PA_InsertarBitacora 
                    @pN_UsuarioID = @pN_UsuarioID,
                    @pC_Operacion = @pC_Operacion,
                    @pC_Comando = @pC_Comando,
                    @pN_OficinaID = @pN_OficinaID;

                RAISERROR(@pC_Comando, 16, 1);
                ROLLBACK TRANSACTION;
                RETURN 1;
            END
        END
        ELSE
        BEGIN
            SET @pN_ClasificacionID = (SELECT TN_Id FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pN_ClasificacionID);
        END

		-- Validar que el nombre no exista para otra subclasificacion en la misma clasificacion
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TC_Nombre = @pC_Nombre AND TN_ClasificacionID = @pN_ClasificacionID AND TN_Id != @pN_Id)
        BEGIN
            SET @pC_Comando = 'Ya existe una subclasificacion asignada a esa clasificacion con ese nombre '+ @pC_Nombre;
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;

            RAISERROR(@pC_Comando, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar la subclasificacion
        UPDATE GD.TGESTORDOCUMENTAL_Subclasificacion
        SET TC_Nombre = @pC_Nombre,
            TC_Descripcion = @pC_Descripcion,
            TB_Eliminado = @pB_Eliminado,
            TN_ClasificacionID = @pN_ClasificacionID
        WHERE TN_Id = @pN_Id;

		SET @pC_Comando = 'Actualizado la subclasificacion con Id '+ CAST(@pN_Id AS NVARCHAR(10));
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        SET @pC_Comando = ERROR_MESSAGE();
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para eliminar en GD.TGESTORDOCUMENTAL_Subclasificacion (eliminacion logica)
CREATE PROCEDURE GD.PA_EliminarSubclasificacion
    @pN_Id INT,
	@pN_UsuarioID INT, -- ID del usuario
    @pN_OficinaID INT  -- ID de la oficina
AS
BEGIN

	DECLARE @pC_Operacion NVARCHAR(255) = 'Eliminar Subclasificacion';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la subclasificacion exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pN_Id)
        BEGIN
            SET @pC_Comando = 'La etapa con el Id '+ + CAST(@pN_Id AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;

            RAISERROR(@pC_Comando, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

		IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento 
                   WHERE TN_SubClasificacionID = @pN_Id AND TB_Eliminado = 0)
        BEGIN
            SET @pC_Comando = 'No se puede eliminar la subclasificacion porque existen documentos asociados que no han sido eliminados.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;

            RAISERROR(@pC_Comando, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Marcar la subclasificacion como eliminada
        UPDATE GD.TGESTORDOCUMENTAL_Subclasificacion
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        SET @pC_Comando = ERROR_MESSAGE();
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para listar todas las subclasificaciones no eliminadas
CREATE PROCEDURE GD.PA_ListarSubclasificaciones
AS
BEGIN
    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado,
	TN_ClasificacionID as ClasificacionID
    FROM GD.TGESTORDOCUMENTAL_Subclasificacion
    WHERE TB_Eliminado = 0;
END;
GO

-- Procedimiento para obtener una subclasificacion por ID
CREATE PROCEDURE GD.PA_ObtenerSubclasificacionPorId
    @pN_Id INT
AS
BEGIN
    -- Validar que la subclasificacion exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('La subclasificacion con el Id especificado no existe.', 16, 1);
        RETURN;
    END

    -- Devolver la subclasificacion
    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado,
	TN_ClasificacionID as ClasificacionID
    FROM GD.TGESTORDOCUMENTAL_Subclasificacion
    WHERE TN_Id = @pN_Id;
END;
GO
