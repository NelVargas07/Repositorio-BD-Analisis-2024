--USE GESTORDOCUMENTALOIJ

CREATE OR ALTER PROCEDURE GD.PA_ActualizarEtapa
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT,
    @pN_EtapaPadreID INT = NULL,
    @pC_Color VARCHAR(500),
    @pN_NormaID INT = NULL,
	@pN_UsuarioID INT, -- ID del usuario
    @pN_OficinaID INT  -- ID de la oficina
AS
BEGIN

	DECLARE @pC_Operacion NVARCHAR(255) = 'Actualizar Etapa';
    DECLARE @pC_Comando NVARCHAR(255);
	DECLARE @Resultado INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la etapa exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pN_Id AND TB_Eliminado = 0)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La etapa con el Id '+ CAST(@pN_Id AS NVARCHAR(10)) +' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Validar que la norma exista o si viene nula
        IF @pN_NormaID IS NOT NULL AND @pN_NormaID > 0
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TN_Id = @pN_NormaID AND TB_Eliminado = 0)
            BEGIN
				ROLLBACK TRANSACTION;
                SET @pC_Comando = 'La norma con el Id '+ CAST(@pN_NormaID AS NVARCHAR(10)) +' no existe.';
                EXEC GD.PA_InsertarBitacora 
                    @pN_UsuarioID = @pN_UsuarioID,
                    @pC_Operacion = @pC_Operacion,
                    @pC_Comando = @pC_Comando,
                    @pN_OficinaID = @pN_OficinaID;
                RETURN 1;
            END
        END
        ELSE
        BEGIN
            SET @pN_NormaID = (SELECT TN_NormaID FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pN_Id);
        END

        -- Validar que el nombre no exista para otra etapa en la misma norma
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TC_Nombre = @pC_Nombre AND TN_NormaID = @pN_NormaID AND TN_Id != @pN_Id AND TB_Eliminado = 0)
        BEGIN
			ROLLBACK TRANSACTION;
            SET @pC_Comando = 'Ya existe una etapa asignada a la norma con id '+CAST(@pN_NormaID AS NVARCHAR(10))+' con ese nombre '+ @pC_Nombre;
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Actualizar la etapa
        UPDATE GD.TGESTORDOCUMENTAL_Etapa
        SET TC_Nombre = @pC_Nombre,
            TC_Descripcion = @pC_Descripcion,
            TB_Eliminado = @pB_Eliminado,
            TC_Color = @pC_Color,
            TN_NormaID = @pN_NormaID 
        WHERE TN_Id = @pN_Id;

		SET @pC_Comando = 'Actualizado la etapa con Id '+ CAST(@pN_Id AS NVARCHAR(10));
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;

        -- Actualizar la relación en GD.TGESTORDOCUMENTAL_Etapa_Etapa si se proporciona un EtapaPadreID
        IF @pN_EtapaPadreID IS NOT NULL OR @pN_EtapaPadreID > 0
        BEGIN
            IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa_Etapa WHERE TN_EtapaID = @pN_Id)
            BEGIN
                -- Actualizar la relación si ya existe
                UPDATE GD.TGESTORDOCUMENTAL_Etapa_Etapa
				SET TN_EtapaPadreID = @pN_EtapaPadreID
				WHERE TN_EtapaID = @pN_Id

				SET @pC_Comando = 'Actualizada la relacion etapa padre de la etapa con Id '+ CAST(@pN_Id AS NVARCHAR(10));
				EXEC GD.PA_InsertarBitacora 
					@pN_UsuarioID = @pN_UsuarioID,
					@pC_Operacion = @pC_Operacion,
					@pC_Comando = @pC_Comando,
					@pN_OficinaID = @pN_OficinaID;
            END
            ELSE
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pN_EtapaPadreID AND TB_Eliminado = 0)
				BEGIN
					ROLLBACK TRANSACTION;
					SET @pC_Comando = 'La etapa padre con el Id '+ CAST(@pN_EtapaPadreID AS NVARCHAR(10)) +' no existe.';
					EXEC GD.PA_InsertarBitacora 
						@pN_UsuarioID = @pN_UsuarioID,
						@pC_Operacion = @pC_Operacion,
						@pC_Comando = @pC_Comando,
						@pN_OficinaID = @pN_OficinaID;
					RETURN 1;
				END
			
            EXEC @Resultado = GD.PA_InsertarEtapa_Etapa @pN_EtapaPadreID, @pN_Id;

            IF @Resultado = 1
            BEGIN
                ROLLBACK TRANSACTION;
                SET @pC_Comando = 'Error al agregar relación entre etapa padre e hija.';
                EXEC GD.PA_InsertarBitacora 
                    @pN_UsuarioID = @pN_UsuarioID,
                    @pC_Operacion = @pC_Operacion,
                    @pC_Comando = @pC_Comando,
                    @pN_OficinaID = @pN_OficinaID;
                RETURN 1;
            END
            END
        END

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

CREATE OR ALTER PROCEDURE GD.PA_InsertarEtapa
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pN_EtapaPadreID INT = NULL,
    @pC_Color VARCHAR(500),
    @pN_NormaID INT = NULL,
    @pN_UsuarioID INT,
    @pN_OficinaID INT  
AS
BEGIN
    DECLARE @pC_Operacion NVARCHAR(255) = 'Insertar Etapa';
    DECLARE @pC_Comando NVARCHAR(255);
    DECLARE @Resultado INT;
    DECLARE @Consecutivo INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que TN_NormaID exista en la tabla GD.TGESTORDOCUMENTAL_Norma, si no es NULL
        IF @pN_NormaID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TN_Id = @pN_NormaID AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La norma con el Id ' + CAST(@pN_NormaID AS NVARCHAR(10)) + ' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Validar que no exista una etapa con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TC_Nombre = @pC_Nombre AND TN_NormaID = @pN_NormaID)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @pC_Comando = 'Ya existe una etapa asignada a esa norma con el mismo nombre ' + @pC_Nombre;
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Calcular el valor del consecutivo
        IF @pN_EtapaPadreID IS NULL OR @pN_EtapaPadreID = 0
        BEGIN
            SET @Consecutivo = 1;
        END
        ELSE
        BEGIN
            SELECT @Consecutivo = COUNT(*) + 2
            FROM GD.TGESTORDOCUMENTAL_Etapa_Etapa
            WHERE TN_EtapaPadreID = @pN_EtapaPadreID;
        END

        -- Insertar la nueva etapa con el consecutivo calculado
        INSERT INTO GD.TGESTORDOCUMENTAL_Etapa (TC_Nombre, TC_Descripcion, TB_Eliminado, TC_Color, TN_NormaID, TN_Consecutivo)
        VALUES (@pC_Nombre, @pC_Descripcion, 0, @pC_Color, @pN_NormaID, @Consecutivo);

        SET @pC_Comando = 'Insertar nueva Etapa: ' + @pC_Nombre;
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        -- Obtener el Id de la etapa insertada
        DECLARE @NewId INT = SCOPE_IDENTITY();

        -- Insertar la relación en GD.TGESTORDOCUMENTAL_Etapa_Etapa si hay un padre
        IF @pN_EtapaPadreID IS NOT NULL AND @pN_EtapaPadreID > 0
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pN_EtapaPadreID AND TB_Eliminado = 0)
            BEGIN
                ROLLBACK TRANSACTION;
                SET @pC_Comando = 'La etapa padre con el Id ' + CAST(@pN_EtapaPadreID AS NVARCHAR(10)) + ' no existe.';
                EXEC GD.PA_InsertarBitacora 
                    @pN_UsuarioID = @pN_UsuarioID,
                    @pC_Operacion = @pC_Operacion,
                    @pC_Comando = @pC_Comando,
                    @pN_OficinaID = @pN_OficinaID;
                RETURN 1;
            END

            EXEC @Resultado = GD.PA_InsertarEtapa_Etapa @pN_EtapaPadreID, @NewId;

            IF @Resultado = 1
            BEGIN
                ROLLBACK TRANSACTION;
                SET @pC_Comando = 'Error al agregar relación entre etapa padre e hija.';
                EXEC GD.PA_InsertarBitacora 
                    @pN_UsuarioID = @pN_UsuarioID,
                    @pC_Operacion = @pC_Operacion,
                    @pC_Comando = @pC_Comando,
                    @pN_OficinaID = @pN_OficinaID;
                RETURN 1;
            END

            SET @pC_Comando = 'Agregación de la relación etapa padre con la etapa con Id ' + CAST(@NewId AS NVARCHAR(10));
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
        END

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


CREATE OR ALTER PROCEDURE GD.PA_EliminarEtapa
    @pN_Id INT,
    @pN_UsuarioID INT,
    @pN_OficinaID INT
AS
BEGIN

    DECLARE @pC_Operacion NVARCHAR(255) = 'Eliminar Etapa';
    DECLARE @pC_Comando NVARCHAR(255);
    DECLARE @pN_EtapaPadreID INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la etapa exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pN_Id)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @pC_Comando = 'La etapa con el Id ' + CAST(@pN_Id AS NVARCHAR(10)) + ' no existe.';
            EXEC GD.PA_InsertarBitacora 
                @pN_UsuarioID = @pN_UsuarioID,
                @pC_Operacion = @pC_Operacion,
                @pC_Comando = @pC_Comando,
                @pN_OficinaID = @pN_OficinaID;
            RETURN 1;
        END

        -- Obtener el ID del padre de la etapa
        SELECT @pN_EtapaPadreID = TN_EtapaPadreID
        FROM GD.TGESTORDOCUMENTAL_Etapa_Etapa
        WHERE TN_EtapaID = @pN_Id;

        -- Eliminar relaciones en GD.TGESTORDOCUMENTAL_Etapa_Etapa
        DELETE FROM GD.TGESTORDOCUMENTAL_Etapa_Etapa WHERE TN_EtapaPadreID = @pN_Id OR TN_EtapaID = @pN_Id;

        SET @pC_Comando = 'Eliminar etapa con ID ' + CAST(@pN_Id AS NVARCHAR(10)) + ' y relaciones con etapa padre';
        EXEC GD.PA_InsertarBitacora 
            @pN_UsuarioID = @pN_UsuarioID,
            @pC_Operacion = @pC_Operacion,
            @pC_Comando = @pC_Comando,
            @pN_OficinaID = @pN_OficinaID;

        -- Eliminar la etapa (eliminado lógico)
        UPDATE GD.TGESTORDOCUMENTAL_Etapa
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

        -- Ajustar el consecutivo de las etapas hermanas si existe un padre
        IF @pN_EtapaPadreID IS NOT NULL
        BEGIN
            -- Crear una tabla temporal para asignar consecutivos
            DECLARE @TempConsecutivo TABLE (TN_Id INT, NuevoConsecutivo INT);

            INSERT INTO @TempConsecutivo (TN_Id, NuevoConsecutivo)
            SELECT TN_Id, ROW_NUMBER() OVER (ORDER BY TN_Consecutivo)
            FROM GD.TGESTORDOCUMENTAL_Etapa E
            INNER JOIN GD.TGESTORDOCUMENTAL_Etapa_Etapa EE ON E.TN_Id = EE.TN_EtapaID
            WHERE EE.TN_EtapaPadreID = @pN_EtapaPadreID AND E.TB_Eliminado = 0;

            -- Actualizar el consecutivo usando la tabla temporal
            UPDATE E
            SET E.TN_Consecutivo = T.NuevoConsecutivo
            FROM GD.TGESTORDOCUMENTAL_Etapa E
            INNER JOIN @TempConsecutivo T ON E.TN_Id = T.TN_Id;
        END

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


CREATE OR ALTER PROCEDURE GD.PA_ListarEtapas
AS
BEGIN
    -- Devolver todas las etapas que no han sido eliminadas y sus relaciones de padre si existen
    SELECT 
	E.TN_Id as Id,
	E.TC_Nombre as Nombre,
	E.TC_Descripcion as Descripcion,
	E.TB_Eliminado as eliminado,
	E.TC_Color as color,
	E.TN_NormaID as normaID, 
	isnull(EE.TN_EtapaPadreID,0) as EtapaPadreID,
    E.TN_Consecutivo AS Consecutivo
    FROM GD.TGESTORDOCUMENTAL_Etapa E
    left JOIN GD.TGESTORDOCUMENTAL_Etapa_Etapa EE ON EE.TN_EtapaID = E.TN_Id
    WHERE E.TB_Eliminado = 0
    ORDER BY E.TN_Consecutivo ASC;
END;
GO

CREATE OR ALTER PROCEDURE GD.PA_ListarEtapasHuerfanas
AS
BEGIN
    -- Devolver todas las etapas que no han sido eliminadas y que no tienen registros asociados en TN_EtapaID en la tabla GD.TGESTORDOCUMENTAL_Etapa_Etapa
    SELECT 
        E.TN_Id as Id,
        E.TC_Nombre as Nombre,
        E.TC_Descripcion as Descripcion,
        E.TB_Eliminado as eliminado,
        E.TC_Color as color,
        E.TN_NormaID as normaID,
        isnull(EE.TN_EtapaPadreID,0) as EtapaPadreID,
        E.TN_Consecutivo AS Consecutivo
    FROM GD.TGESTORDOCUMENTAL_Etapa E
    LEFT JOIN GD.TGESTORDOCUMENTAL_Etapa_Etapa EE ON EE.TN_EtapaID = E.TN_Id
    WHERE E.TB_Eliminado = 0
      AND EE.TN_EtapaID IS NULL; -- Filtrar solo las etapas sin relación en TN_EtapaID
END;
GO


CREATE OR ALTER PROCEDURE GD.PA_ObtenerEtapaPorId
    @pN_Id INT
AS
BEGIN
    -- Validar que la etapa exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('La etapa con el Id especificado no existe.', 16, 1);
        RETURN 1;
    END

    -- Devolver la etapa y su etapa padre si existe, junto con TN_NormaID
    SELECT E.TN_Id as Id,
	E.TC_Nombre as Nombre,
	E.TC_Descripcion as Descripcion,
	E.TB_Eliminado as eliminado,
	E.TC_Color as color,
	E.TN_NormaID as normaID, 
	ISNULL(EE.TN_EtapaPadreID,0) as EtapaPadreID,
    E.TN_Consecutivo AS Consecutivo
    FROM GD.TGESTORDOCUMENTAL_Etapa E
	LEFT JOIN GD.TGESTORDOCUMENTAL_Etapa_Etapa EE ON EE.TN_EtapaID = E.TN_Id
    WHERE E.TN_Id = @pN_Id;
END;
GO


CREATE OR ALTER PROCEDURE GD.PA_ObtenerEtapasPorPadreId
    @pN_EtapaPadreID INT
AS
BEGIN
    -- Validar que la etapa padre exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pN_EtapaPadreID)
    BEGIN
        RAISERROR('La etapa padre con el Id especificado no existe.', 16, 1);
        RETURN 1;
    END

    -- Devolver todas las etapas hijas correspondientes al EtapaPadreID y que no estén eliminadas
    SELECT E.TN_Id as Id,
	E.TC_Nombre as Nombre,
	E.TC_Descripcion as Descripcion,
	E.TB_Eliminado as eliminado,
	E.TC_Color as color,
	E.TN_NormaID as normaID, 
	ISNULL(EE.TN_EtapaPadreID,0) as EtapaPadreID,
    E.TN_Consecutivo AS Consecutivo
    FROM GD.TGESTORDOCUMENTAL_Etapa E
    LEFT JOIN GD.TGESTORDOCUMENTAL_Etapa_Etapa EE ON EE.TN_EtapaID = E.TN_Id
    WHERE EE.TN_EtapaPadreID = @pN_EtapaPadreID AND E.TB_Eliminado = 0;
END;
GO

CREATE OR ALTER PROCEDURE GD.PA_ObtenerEtapasPorNormaId
    @pN_NormaID INT
AS
BEGIN
    -- Validar que la etapa padre exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TN_Id = @pN_NormaID)
    BEGIN
        RAISERROR('La etapa padre con el Id especificado no existe.', 16, 1);
        RETURN 1;
    END

    -- Devolver todas las etapas hijas correspondientes al EtapaPadreID y que no estén eliminadas
    SELECT E.TN_Id as Id,
	E.TC_Nombre as Nombre,
	E.TC_Descripcion as Descripcion,
	E.TB_Eliminado as eliminado,
	E.TC_Color as color,
	E.TN_NormaID as normaID, 
	ISNULL(EE.TN_EtapaPadreID,0) as EtapaPadreID,
    E.TN_Consecutivo AS Consecutivo
    FROM GD.TGESTORDOCUMENTAL_Etapa E
    LEFT JOIN GD.TGESTORDOCUMENTAL_Etapa_Etapa EE ON EE.TN_EtapaID = E.TN_Id
    WHERE E.TN_NormaID = @pN_NormaID AND E.TB_Eliminado = 0;
END;
GO
