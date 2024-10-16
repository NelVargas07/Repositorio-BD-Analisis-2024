--USE GESTORDOCUMENTALOIJ
CREATE OR ALTER PROCEDURE GD.PA_ActualizarEtapa
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT,
    @pN_EtapaPadreID INT = NULL,
    @pC_Color VARCHAR(500),
    @pN_NormaID INT = NULL 
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la etapa exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('La etapa con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que el nombre no exista para otra etapa
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TC_Nombre = @pC_Nombre AND TN_Id != @pN_Id)
        BEGIN
            RAISERROR('Ya existe una etapa con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar la etapa
        UPDATE GD.TGESTORDOCUMENTAL_Etapa
        SET TC_Nombre = @pC_Nombre,
            TC_Descripcion = @pC_Descripcion,
            TB_Eliminado = @pB_Eliminado,
            TC_Color = @pC_Color,
            TN_NormaID = @pN_NormaID -- Actualizar TN_NormaID
        WHERE TN_Id = @pN_Id;

        -- Actualizar la relación en GD.TGESTORDOCUMENTAL_Etapa_Etapa si se proporciona un EtapaPadreID
        IF @pN_EtapaPadreID IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa_Etapa WHERE TN_EtapaID = @pN_Id)
            BEGIN
                -- Actualizar la relación si ya existe
                EXEC GD.PA_ActualizarEtapa_Etapa @pN_EtapaPadreID, @pN_Id
            END
            ELSE
            BEGIN
                -- Insertar la relación si no existe
                EXEC GD.PA_InsertarEtapa_Etapa @pN_EtapaPadreID, @pN_Id
            END
        END

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre algún error, deshacer la transacción
        ROLLBACK TRANSACTION;

        -- Retornar código de error
        RETURN 1;
    END CATCH
END;
GO


CREATE PROCEDURE GD.PA_InsertarEtapa
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pN_EtapaPadreID INT = NULL,
    @pC_Color VARCHAR(500),
    @pN_NormaID INT = NULL 
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que no exista una etapa con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TC_Nombre = @pC_Nombre)
        BEGIN
            RAISERROR('Ya existe una etapa con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que TN_NormaID exista en la tabla GD.TGESTORDOCUMENTAL_Norma, si no es NULL
        IF @pN_NormaID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TN_Id = @pN_NormaID)
        BEGIN
            RAISERROR('La norma con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva etapa
        INSERT INTO GD.TGESTORDOCUMENTAL_Etapa (TC_Nombre, TC_Descripcion, TB_Eliminado, TC_Color, TN_NormaID)
        VALUES (@pC_Nombre, @pC_Descripcion, 0, @pC_Color, @pN_NormaID); -- Insertar TN_NormaID

        -- Obtener el Id de la etapa insertada
        DECLARE @NewId INT = SCOPE_IDENTITY();

        -- Insertar la relación en GD.TGESTORDOCUMENTAL_Etapa_Etapa si hay un padre
        IF @pN_EtapaPadreID IS NOT NULL
        BEGIN
            EXEC GD.PA_InsertarEtapa_Etapa @pN_EtapaPadreID, @NewId
        END

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre algún error, deshacer la transacción
        ROLLBACK TRANSACTION;

        -- Retornar código de error
        RETURN 1;
    END CATCH
END;
GO


CREATE PROCEDURE GD.PA_EliminarEtapa
    @pN_Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la etapa exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('La etapa con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminar las relaciones en GD.TGESTORDOCUMENTAL_Etapa_Etapa donde esta etapa sea padre o hijo
        DELETE FROM GD.TGESTORDOCUMENTAL_Etapa_Etapa WHERE TN_EtapaPadreID = @pN_Id OR TN_EtapaID = @pN_Id;

        -- Eliminar la etapa (eliminado lógico)
        UPDATE GD.TGESTORDOCUMENTAL_Etapa
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre algún error, deshacer la transacción
        ROLLBACK TRANSACTION;

        -- Retornar código de error
        RETURN 1;
    END CATCH
END;
GO

CREATE PROCEDURE GD.PA_ListarEtapas
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
	isnull(EE.TN_EtapaPadreID,0) as EtapaPadreID
    FROM GD.TGESTORDOCUMENTAL_Etapa E
    left JOIN GD.TGESTORDOCUMENTAL_Etapa_Etapa EE ON EE.TN_EtapaID = E.TN_Id
    WHERE E.TB_Eliminado = 0;
END;
GO


CREATE PROCEDURE GD.PA_ObtenerEtapaPorId
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
	EE.TN_EtapaPadreID as EtapaPadreID
    FROM GD.TGESTORDOCUMENTAL_Etapa E
    JOIN GD.TGESTORDOCUMENTAL_Etapa_Etapa EE ON EE.TN_EtapaID = E.TN_Id
    WHERE E.TN_Id = @pN_Id;
END;
GO


CREATE PROCEDURE GD.PA_ObtenerEtapasPorPadreId
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
	EE.TN_EtapaPadreID as EtapaPadreID
    FROM GD.TGESTORDOCUMENTAL_Etapa E
    JOIN GD.TGESTORDOCUMENTAL_Etapa_Etapa EE ON EE.TN_EtapaID = E.TN_Id
    WHERE EE.TN_EtapaPadreID = @pN_EtapaPadreID AND E.TB_Eliminado = 0;
END;
GO

