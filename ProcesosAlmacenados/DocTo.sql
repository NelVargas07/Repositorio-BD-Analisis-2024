--USE GestorDocumentalOIJ

CREATE OR ALTER PROCEDURE GD.PA_sp_InsertarDocTo
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
	@pN_UsuarioID INT, -- ID del usuario
    @pN_OficinaID INT  -- ID de la oficina
AS
BEGIN

	DECLARE @pC_Operacion NVARCHAR(255) = 'Insertar DocTo';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que no exista un DocTo con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TC_Nombre = @pC_Nombre)
        BEGIN
			ROLLBACK TRANSACTION;
			SET @pC_Comando = 'Ya existe un DocTo con el mismo nombre: ' + @pC_Nombre;
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Insertar el nuevo DocTo
        INSERT INTO GD.TGESTORDOCUMENTAL_DocTo (TC_Nombre, TC_Descripcion, TB_Eliminado)
        VALUES (@pC_Nombre, @pC_Descripcion, 0);

		SET @pC_Comando = 'Insertar nuevo DocTo: ' + @pC_Nombre;
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

-- SP para actualizar un registro en GD.TGESTORDOCUMENTAL_DocTo
CREATE OR ALTER PROCEDURE GD.PA_sp_ActualizarDocTo
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT,
	@pN_UsuarioID INT, -- ID del usuario
    @pN_OficinaID INT  -- ID de la oficina
AS
BEGIN

	DECLARE @pC_Operacion NVARCHAR(255) = 'Actualizar DocTo';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el DocTo exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @pN_Id)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'El DocTo con el Id '+ CAST(@pN_Id AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END
        
        -- Validar que el nombre no exista para otro DocTo
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TC_Nombre = @pC_Nombre AND TN_Id != @pN_Id)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'Ya existe un DocTo con ese nombre '+ @pC_Nombre;
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Actualizar el DocTo
        UPDATE GD.TGESTORDOCUMENTAL_DocTo
        SET TC_Nombre = @pC_Nombre,
            TC_Descripcion = @pC_Descripcion,
            TB_Eliminado = @pB_Eliminado
        WHERE TN_Id = @pN_Id;

		SET @pC_Comando = 'Actualizado el DocTo con Id '+ CAST(@pN_Id AS NVARCHAR(10));
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

-- SP para eliminar un registro en GD.TGESTORDOCUMENTAL_DocTo (eliminado l�gico)
CREATE OR ALTER PROCEDURE GD.PA_sp_EliminarDocTo
    @pN_Id INT,
	@pN_UsuarioID INT, -- ID del usuario
    @pN_OficinaID INT  -- ID de la oficina
AS
BEGIN

	DECLARE @pC_Operacion NVARCHAR(255) = 'Eliminar DocTo';
    DECLARE @pC_Comando NVARCHAR(255);
	
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el DocTo exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @pN_Id)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'El docto con el Id '+ + CAST(@pN_Id AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

		-- Validar que no existan documentos asociados al tipo de documento y que no est�n eliminados
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento 
                   WHERE TN_DocTo = @pN_Id AND TB_Eliminado = 0)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'No se puede eliminar el docto con id ' + CAST(@pN_Id AS NVARCHAR(10)) +' porque existen documentos asociados que no han sido eliminados.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Eliminar l�gicamente el DocTo
        UPDATE GD.TGESTORDOCUMENTAL_DocTo
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

		SET @pC_Comando = 'Eliminar docto con ID ' + CAST(@pN_Id AS NVARCHAR(10));
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

-- SP para listar todos los registros no eliminados en GD.TGESTORDOCUMENTAL_DocTo
CREATE OR ALTER PROCEDURE GD.PA_sp_ListarDocTos
AS
BEGIN

    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado
    FROM GD.TGESTORDOCUMENTAL_DocTo
    WHERE TB_Eliminado = 0;
END;
GO

-- SP para obtener un registro espec�fico en GD.TGESTORDOCUMENTAL_DocTo por su ID
CREATE OR ALTER PROCEDURE GD.PA_sp_ObtenerDocToPorId
    @pN_Id INT
AS
BEGIN

    -- Validar que el DocTo exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('El docto con el Id especificado no existe.', 16, 1);
        RETURN 1;
    END

    -- Devolver el DocTo
    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado
    FROM GD.TGESTORDOCUMENTAL_DocTo
    WHERE TN_Id = @pN_Id AND TB_Eliminado = 0;
END;
GO
