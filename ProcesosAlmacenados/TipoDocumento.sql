--USE GestorDocumentalOIJ

CREATE OR ALTER PROCEDURE GD.PA_ActualizarTipoDocumento
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT,
    @pN_UsuarioID INT, 
    @pN_OficinaID INT  
AS
BEGIN
    DECLARE @pC_Operacion NVARCHAR(255) = 'Actualizar Tipo Documento';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que el tipo de documento exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TN_Id = @pN_Id)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'El tipo documento con el Id '+ CAST(@pN_Id AS NVARCHAR(10))+ ' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END
        
        -- Validar que el nombre no exista para otro tipo de documento
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TC_Nombre = @pC_Nombre AND TN_Id != @pN_Id)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'Ya existe un tipo de documento con el mismo nombre: '++@pC_Nombre;
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Actualizar el tipo de documento
        SET @pC_Comando = 'Actualizar el tipo documento con ID ' + CAST(@pN_Id AS NVARCHAR(10));
        UPDATE GD.TGESTORDOCUMENTAL_TipoDocumento
        SET TC_Nombre = @pC_Nombre,
            TC_Descripcion = @pC_Descripcion,
            TB_Eliminado = @pB_Eliminado
        WHERE TN_Id = @pN_Id;

        -- Intentar registrar la operaci�n en la bit�cora
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        -- Verificar si la inserci�n en la bit�cora fue exitosa
        IF @@ERROR <> 0
        BEGIN
            -- Si hubo un error en la inserci�n en la bit�cora, deshacer la transacci�n
            ROLLBACK TRANSACTION;
            RETURN 1; -- Retornar 1 si falla la inserci�n en la bit�cora
        END

        COMMIT TRANSACTION;
        RETURN 0;
        
    END TRY
    BEGIN CATCH
		ROLLBACK TRANSACTION;
        -- Registrar el error en la bit�cora
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

CREATE OR ALTER PROCEDURE GD.PA_InsertarTipoDocumento
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pN_UsuarioID INT, -- ID del usuario
    @pN_OficinaID INT  -- ID de la oficina
AS
BEGIN
    DECLARE @pC_Operacion NVARCHAR(255) = 'Insertar TipoDocumento';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que no exista un tipo de documento con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TC_Nombre = @pC_Nombre)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'Ya existe un tipo documento con el mismo nombre: '+ @pC_Nombre;
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Insertar el nuevo tipo de documento
        INSERT INTO GD.TGESTORDOCUMENTAL_TipoDocumento (TC_Nombre, TC_Descripcion, TB_Eliminado)
        VALUES (@pC_Nombre, @pC_Descripcion, 0);

        -- Registrar la operaci�n en la bit�cora
        SET @pC_Comando = 'Insertar el tipo documento: ' + @pC_Nombre;
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        -- Verificar si la inserci�n en la bit�cora fue exitosa
        IF @@ERROR <> 0
        BEGIN
            -- Si hubo un error en la inserci�n en la bit�cora, deshacer la transacci�n
            ROLLBACK TRANSACTION;
            RETURN 1; -- Retornar 1 si falla la inserci�n en la bit�cora
        END

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
		ROLLBACK TRANSACTION;
        -- Registrar el error en la bit�cora
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

CREATE OR ALTER PROCEDURE GD.PA_EliminarTipoDocumento
    @pN_Id INT,
    @pN_UsuarioID INT, -- ID del usuario
    @pN_OficinaID INT  -- ID de la oficina
AS
BEGIN
    DECLARE @pC_Operacion NVARCHAR(255) = 'Eliminar TipoDocumento';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el tipo de documento exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TN_Id = @pN_Id)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'El tipo documento con el Id '+ CAST(@pN_Id AS NVARCHAR(10))+ ' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Validar que no existan documentos asociados al tipo de documento y que no estén eliminados
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento 
                   WHERE TN_TipoDocumento = @pN_Id AND TB_Eliminado = 0)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'No se puede eliminar el tipo de documento con el Id '+ CAST(@pN_Id AS NVARCHAR(10)) +' esta ligada a un documento por lo cual no se puede eliminar.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Eliminado lógico
        UPDATE GD.TGESTORDOCUMENTAL_TipoDocumento
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

        -- Registrar la operación en la bitácora
        SET @pC_Comando = 'Eliminar el tipo de documento con ID ' + CAST(@pN_Id AS NVARCHAR(10));
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        -- Verificar si la inserción en la bitácora fue exitosa
        IF @@ERROR <> 0
        BEGIN
            -- Si hubo un error en la inserción en la bitácora, deshacer la transacción
            ROLLBACK TRANSACTION;
            RETURN 1; -- Retornar 1 si falla la inserción en la bitácora
        END

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
		ROLLBACK TRANSACTION;
        -- Registrar el error en la bitácora
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

CREATE OR ALTER PROCEDURE GD.PA_ListarTiposDocumento
AS
BEGIN
        -- Devolver todos los tipos de documento que no han sido eliminados
        SELECT TN_Id AS Id, 
               TC_Nombre AS Nombre, 
               TC_Descripcion AS Descripcion, 
               TB_Eliminado AS Eliminado
        FROM GD.TGESTORDOCUMENTAL_TipoDocumento
        WHERE TB_Eliminado = 0;
END;
GO

CREATE OR ALTER PROCEDURE GD.PA_ObtenerTipoDocumentoPorId
    @pN_Id INT
AS
BEGIN
        -- Validar que el tipo de documento exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TN_Id = @pN_Id)
        BEGIN

            RAISERROR('El tipo de documento con el Id especificado no existe.', 16, 1);
            RETURN 1; -- Retornar 1 si falla la validaci�n
        END

        -- Devolver el tipo de documento
        SELECT TN_Id AS Id,
               TC_Nombre AS Nombre,
               TC_Descripcion AS Descripcion,
               TB_Eliminado AS Eliminado
        FROM GD.TGESTORDOCUMENTAL_TipoDocumento
        WHERE TN_Id = @pN_Id AND TB_Eliminado = 0;

END;
GO