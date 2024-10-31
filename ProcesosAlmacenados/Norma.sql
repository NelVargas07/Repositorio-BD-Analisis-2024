--USE GestorDocumentalOIJ

CREATE OR ALTER PROCEDURE GD.PA_ActualizarNorma
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
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La norma con el Id '+ CAST(@pN_Id AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END
        
        -- Validar que el nombre no exista para otra norma
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TC_Nombre = @pC_Nombre AND TN_Id != @pN_Id)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'Ya existe una norma con el mismo nombre: ' + @pC_Nombre;
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
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
		ROLLBACK TRANSACTION;
        -- Registrar el error en la bitácora
        SET @pC_Comando = ERROR_MESSAGE();
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE GD.PA_InsertarNorma
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
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'Ya existe una norma con el mismo nombre ' + @pC_Nombre;
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
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

CREATE OR ALTER PROCEDURE GD.PA_EliminarNorma
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
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La norma con el Id '+ + CAST(@pN_Id AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

		IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_NormaID = @pN_Id and TB_Eliminado = 0)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La norma con el Id '+ CAST(@pN_Id AS NVARCHAR(10)) +' esta ligada a una etapa por lo cual no se puede eliminar.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
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

CREATE OR ALTER PROCEDURE GD.PA_ListarNormas
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


CREATE OR ALTER PROCEDURE GD.PA_ObtenerNormaPorId
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


CREATE OR ALTER PROCEDURE GD.PA_InsertarEtapa
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pN_EtapaPadreID INT,
    @pC_Color VARCHAR(500),
    @pN_NormaID INT = NULL ,
	@pN_UsuarioID INT, 
    @pN_OficinaID INT  
AS
BEGIN

	DECLARE @pC_Operacion NVARCHAR(255) = 'Insertar Etapa';
    DECLARE @pC_Comando NVARCHAR(255);

	BEGIN TRANSACTION;
    BEGIN TRY
     

        -- Validar que TN_NormaID exista en la tabla GD.TGESTORDOCUMENTAL_Norma, si no es NULL
        IF @pN_NormaID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TN_Id = @pN_NormaID)
        BEGIN
            SET @pC_Comando = 'La norma con el Id '+ CAST(@pN_NormaID AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;

            commit TRANSACTION;
            RETURN 1;
        END

        -- Validar que no exista una etapa con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TC_Nombre = @pC_Nombre AND TN_NormaID = @pN_NormaID)
        BEGIN
            SET @pC_Comando = 'Ya existe una etapa asignada a esa norma con el mismo nombre ' + @pC_Nombre;
			print @pC_Comando;
			EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

            commit TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva etapa
        INSERT INTO GD.TGESTORDOCUMENTAL_Etapa (TC_Nombre, TC_Descripcion, TB_Eliminado, TC_Color, TN_NormaID)
        VALUES (@pC_Nombre, @pC_Descripcion, 0, @pC_Color, @pN_NormaID); 

        SET @pC_Comando = 'Insertar nueva Etapa: ' + @pC_Nombre;
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        -- Obtener el Id de la etapa insertada
        DECLARE @NewId INT = SCOPE_IDENTITY();

        -- Insertar la relación en GD.TGESTORDOCUMENTAL_Etapa_Etapa si hay un padre
        IF @pN_EtapaPadreID IS NOT NULL 
        BEGIN

		IF not EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pN_EtapaPadreID and TB_Eliminado = 0)
        BEGIN
            SET @pC_Comando = 'La etapa con el Id '+ CAST(@pN_EtapaPadreID AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;

            commit TRANSACTION;
            RETURN 1;
			end
		else
		begin
            EXEC GD.PA_InsertarEtapa_Etapa @pN_EtapaPadreID, @NewId
			SET @pC_Comando = 'Agregacion de la relacion etapa padre con la etapa con Id '+ CAST(@NewId AS NVARCHAR(10));
				EXEC GD.PA_InsertarBitacora 
					@pN_UsuarioID = @pN_UsuarioID,
					@pC_Operacion = @pC_Operacion,
					@pC_Comando = @pC_Comando,
					@pN_OficinaID = @pN_OficinaID;
			 COMMIT TRANSACTION;
		end
        END
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