--USE GestorDocumentalOIJ

CREATE PROCEDURE GD.PA_ActualizarNorma
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la norma exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('La norma con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END
        
        -- Validar que el nombre no exista para otra norma
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TC_Nombre = @pC_Nombre AND TN_Id != @pN_Id)
        BEGIN
            RAISERROR('Ya existe una norma con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar la norma
        UPDATE GD.TGESTORDOCUMENTAL_Norma
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

CREATE PROCEDURE GD.PA_InsertarNorma
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que no exista una norma con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TC_Nombre = @pC_Nombre)
        BEGIN
            RAISERROR('Ya existe una norma con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva norma
        INSERT INTO GD.TGESTORDOCUMENTAL_Norma (TC_Nombre, TC_Descripcion, TB_Eliminado)
        VALUES (@pC_Nombre, @pC_Descripcion, 0);

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

CREATE PROCEDURE GD.PA_ListarNormas
AS
BEGIN
    -- Devolver todas las normas que no han sido eliminadas
    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado
    FROM GD.TGESTORDOCUMENTAL_Norma
    WHERE TB_Eliminado = 0;
END;
GO

CREATE PROCEDURE GD.PA_ObtenerNormaPorId
    @pN_Id INT
AS
BEGIN
    -- Validar que la norma exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('La norma con el Id especificado no existe.', 16, 1);
        RETURN 1;
    END

    -- Devolver la norma
    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado
    FROM GD.TGESTORDOCUMENTAL_Norma
    WHERE TN_Id = @pN_Id;
END;
GO

CREATE PROCEDURE GD.PA_EliminarNorma
    @pN_Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la norma exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('La norma con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que no existan etapas asociadas a esta norma
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_NormaID = @pN_Id AND TB_Eliminado = 0)
        BEGIN
            RAISERROR('No se puede eliminar la norma porque existen etapas asociadas.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminado lógico
        UPDATE GD.TGESTORDOCUMENTAL_Norma
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

-----------nuevos-------------

CREATE PROCEDURE GD.PA_ActualizarNorma
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT,
    @pN_UsuarioID INT, -- ID del usuario
    @pN_OficinaID INT  -- ID de la oficina
AS
BEGIN
    DECLARE @pC_Operacion NVARCHAR(255) = 'Actualizar Norma';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la norma exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TN_Id = @pN_Id)
        BEGIN
            SET @pC_Comando = 'La norma con el Id '+ CAST(@pN_Id AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;

            RAISERROR(@pC_Comando, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END
        
        -- Validar que el nombre no exista para otra norma
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TC_Nombre = @pC_Nombre AND TN_Id != @pN_Id)
        BEGIN
            SET @pC_Comando = 'Ya existe una norma con el mismo nombre' + @pC_Nombre;
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;

            RAISERROR(@pC_Comando, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar la norma
        UPDATE GD.TGESTORDOCUMENTAL_Norma
        SET TC_Nombre = @pC_Nombre,
            TC_Descripcion = @pC_Descripcion,
            TB_Eliminado = @pB_Eliminado
        WHERE TN_Id = @pN_Id;

        -- Registrar la operación en la bitácora
        SET @pC_Comando = 'Actualizar la norma con ID ' + CAST(@pN_Id AS NVARCHAR(10));
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Registrar el error en la bitácora
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

CREATE PROCEDURE GD.PA_InsertarNorma
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pN_UsuarioID INT, -- ID del usuario
    @pN_OficinaID INT  -- ID de la oficina
AS
BEGIN
    DECLARE @pC_Operacion NVARCHAR(255) = 'Insertar Norma';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que no exista una norma con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TC_Nombre = @pC_Nombre)
        BEGIN
            SET @pC_Comando = 'Ya existe una norma con el mismo nombre ' + @pC_Nombre;
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;

            RAISERROR(@pC_Comando, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva norma
        INSERT INTO GD.TGESTORDOCUMENTAL_Norma (TC_Nombre, TC_Descripcion, TB_Eliminado)
        VALUES (@pC_Nombre, @pC_Descripcion, 0);

        -- Registrar la operación en la bitácora
        SET @pC_Comando = 'Insertar nueva norma: ' + @pC_Nombre;
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Registrar el error en la bitácora
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

CREATE PROCEDURE GD.PA_EliminarNorma
    @pN_Id INT,
    @pN_UsuarioID INT, 
    @pN_OficinaID INT  
AS
BEGIN
    DECLARE @pC_Operacion NVARCHAR(255) = 'Eliminar Norma';
    DECLARE @pC_Comando NVARCHAR(255);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la norma exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TN_Id = @pN_Id)
        BEGIN
            SET @pC_Comando = 'La norma con el Id '+ + CAST(@pN_Id AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;

            RAISERROR(@pC_Comando, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

		IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_NormaID = @pN_Id and TB_Eliminado = 0)
        BEGIN
            SET @pC_Comando = 'La norma con el Id '+ + CAST(@pN_Id AS NVARCHAR(10) +' esta ligada a una etapa por lo cual no se puede eliminar.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;

            RAISERROR(@pC_Comando, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminado lógico
        UPDATE GD.TGESTORDOCUMENTAL_Norma
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

        -- Registrar la operación en la bitácora
        SET @pC_Comando = 'Eliminar norma con ID ' + CAST(@pN_Id AS NVARCHAR(10));
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Registrar el error en la bitácora
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

CREATE PROCEDURE GD.PA_ListarNormas
AS
BEGIN
    -- Devolver todas las normas que no han sido eliminadas
    SELECT TN_Id as Id,
           TC_Nombre as Nombre,
           TC_Descripcion as Descripcion,
           TB_Eliminado as Eliminado
    FROM GD.TGESTORDOCUMENTAL_Norma
    WHERE TB_Eliminado = 0;
END;
GO


CREATE PROCEDURE GD.PA_ObtenerNormaPorId
    @pN_Id INT
AS
BEGIN

    -- Validar que la norma exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TN_Id = @pN_Id)
    BEGIN

        RAISERROR('La norma con el Id especificado no existe.', 16, 1);
        RETURN 1;
    END

    -- Devolver la norma
    SELECT TN_Id as Id,
           TC_Nombre as Nombre,
           TC_Descripcion as Descripcion,
           TB_Eliminado as Eliminado
    FROM GD.TGESTORDOCUMENTAL_Norma
    WHERE TN_Id = @pN_Id;
END;
GO

