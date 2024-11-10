--USE GESTORDOCUMENTALOIJ

-- Procedimiento para insertar en GD.TGESTORDOCUMENTAL_Clasificacion
CREATE OR ALTER PROCEDURE GD.PA_InsertarClasificacion
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pN_UsuarioID INT, -- ID del usuario
    @pN_OficinaID INT  -- ID de la oficina
AS
BEGIN
	
	DECLARE @pC_Operacion NVARCHAR(255) = 'Insertar Clasificacion';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que no exista una clasificacion con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TC_Nombre = @pC_Nombre)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'Ya existe una clasificacion con el mismo nombre ' + @pC_Nombre;
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Insertar la nueva clasificacion
        INSERT INTO GD.TGESTORDOCUMENTAL_Clasificacion (TC_Nombre, TC_Descripcion, TB_Eliminado)
        VALUES (@pC_Nombre, @pC_Descripcion, 0);

		SET @pC_Comando = 'Insertar nueva clasificacion: ' + @pC_Nombre;
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
		ROLLBACK TRANSACTION;
        SET @pC_Comando = ERROR_MESSAGE();
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;
		RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para actualizar en GD.TGESTORDOCUMENTAL_Clasificacion
CREATE OR ALTER PROCEDURE GD.PA_ActualizarClasificacion
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT,
    @pN_UsuarioID INT, -- ID del usuario
    @pN_OficinaID INT  -- ID de la oficina
AS
BEGIN
	
	DECLARE @pC_Operacion NVARCHAR(255) = 'Actualizar Clasificacion';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la clasificacion exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pN_Id)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La clasificacion con el Id '+ CAST(@pN_Id AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Validar que el nombre no exista para otra clasificacion
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TC_Nombre = @pC_Nombre AND TN_Id != @pN_Id)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @pC_Comando = 'Ya existe una clasificacion con el mismo nombre: ' + @pC_Nombre;
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Actualizar la clasificacion
        UPDATE GD.TGESTORDOCUMENTAL_Clasificacion
        SET TC_Nombre = @pC_Nombre,
            TC_Descripcion = @pC_Descripcion,
            TB_Eliminado = @pB_Eliminado
        WHERE TN_Id = @pN_Id;

		SET @pC_Comando = 'Actualizar la clasificacion con ID ' + CAST(@pN_Id AS NVARCHAR(10));
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
	ROLLBACK TRANSACTION;
        SET @pC_Comando = ERROR_MESSAGE();
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;
		RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para eliminar en GD.TGESTORDOCUMENTAL_Clasificacion (eliminacion logica)
CREATE OR ALTER PROCEDURE GD.PA_EliminarClasificacion
    @pN_Id INT,
    @pN_UsuarioID INT, -- ID del usuario
    @pN_OficinaID INT  -- ID de la oficina
AS
BEGIN

	DECLARE @pC_Operacion NVARCHAR(255) = 'Eliminar Clasificacion';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la clasificacion exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pN_Id)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La clasificacion con el Id '+ + CAST(@pN_Id AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

		IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_ClasificacionID = @pN_Id and TB_Eliminado = 0)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La clasificacion con el Id ' + CAST(@pN_Id AS NVARCHAR(10)) +' esta ligada a una subclasificacion por lo cual no se puede eliminar.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Marcar la clasificacion como eliminada
        UPDATE GD.TGESTORDOCUMENTAL_Clasificacion
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

		SET @pC_Comando = 'Eliminar clasificacion con ID ' + CAST(@pN_Id AS NVARCHAR(10));
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
	ROLLBACK TRANSACTION;
        SET @pC_Comando = ERROR_MESSAGE();
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;
		RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para listar todas las clasificaciones no eliminadas
CREATE OR ALTER PROCEDURE GD.PA_ListarClasificaciones
AS
BEGIN
    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado
    FROM GD.TGESTORDOCUMENTAL_Clasificacion
    WHERE TB_Eliminado = 0;
END;
GO

-- Procedimiento para obtener una clasificacion por ID
CREATE OR ALTER PROCEDURE GD.PA_ObtenerClasificacionPorId
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
    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado
    FROM GD.TGESTORDOCUMENTAL_Clasificacion
    WHERE TN_Id = @pN_Id;
END;
GO
