--USE GestorDocumentalOIJ

CREATE PROCEDURE GD.PA_ActualizarEtapa
    @pIId INT,
    @pINombre NVARCHAR(255),
    @pIDescripcion NVARCHAR(500),
    @pIEliminado BIT,
    @pINormaID INT,
    @pIColor VARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la etapa exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pIId)
        BEGIN
            RAISERROR('La etapa con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que la norma exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TN_Id = @pINormaID)
        BEGIN
            RAISERROR('La norma con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que el nombre no exista para otra etapa
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TC_Nombre = @pINombre AND TN_Id != @pIId)
        BEGIN
            RAISERROR('Ya existe una etapa con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar la etapa
        UPDATE GD.TGESTORDOCUMENTAL_Etapa
        SET TC_Nombre = @pINombre,
            TC_Descripcion = @pIDescripcion,
            TB_Eliminado = @pIEliminado,
            TN_NormaID = @pINormaID,
            TC_Color = @pIColor
        WHERE TN_Id = @pIId;

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
    @pINombre NVARCHAR(255),
    @pIDescripcion NVARCHAR(500),
    @pINormaID INT,
    @pIColor VARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la norma exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TN_Id = @pINormaID)
        BEGIN
            RAISERROR('La norma con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END
        
        -- Validar que no exista una etapa con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TC_Nombre = @pINombre)
        BEGIN
            RAISERROR('Ya existe una etapa con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva etapa
        INSERT INTO GD.TGESTORDOCUMENTAL_Etapa (TC_Nombre, TC_Descripcion, TB_Eliminado, TN_NormaID, TC_Color)
        VALUES (@pINombre, @pIDescripcion, 0, @pINormaID, @pIColor);

        -- Obtener el Id de la etapa insertada
        DECLARE @NewId INT = SCOPE_IDENTITY();

        -- Insertar relación en GD.TGESTORDOCUMENTAL_Etapa_Etapa si hay un padre
        IF @pINormaID IS NOT NULL
        BEGIN
            INSERT INTO GD.TGESTORDOCUMENTAL_Etapa_Etapa (TN_EtapaPadreID, TN_EtapaID)
            VALUES (@pINormaID, @NewId);
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
    @pIId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la etapa exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pIId)
        BEGIN
            RAISERROR('La etapa con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminar las relaciones en GD.TGESTORDOCUMENTAL_Etapa_Etapa donde esta etapa sea padre o hijo
        DELETE FROM GD.TGESTORDOCUMENTAL_Etapa_Etapa WHERE TN_EtapaPadreID = @pIId OR TN_EtapaID = @pIId;

        -- Eliminar la etapa (eliminado lógico)
        UPDATE GD.TGESTORDOCUMENTAL_Etapa
        SET TB_Eliminado = 1
        WHERE TN_Id = @pIId;

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
    SELECT E.TN_Id, E.TC_Nombre, E.TC_Descripcion, E.TB_Eliminado, E.TN_NormaID, E.TC_Color, EE.TN_EtapaPadreID
    FROM GD.TGESTORDOCUMENTAL_Etapa E
    LEFT JOIN GD.TGESTORDOCUMENTAL_Etapa_Etapa EE ON EE.TN_EtapaID = E.TN_Id
    WHERE E.TB_Eliminado = 0;
END;
GO

CREATE PROCEDURE GD.PA_ObtenerEtapaPorId
    @pIId INT
AS
BEGIN
    -- Validar que la etapa exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pIId)
    BEGIN
        RAISERROR('La etapa con el Id especificado no existe.', 16, 1);
        RETURN 1;
    END

    -- Devolver la etapa y su etapa padre si existe
    SELECT E.TN_Id, E.TC_Nombre, E.TC_Descripcion, E.TB_Eliminado, E.TN_NormaID, E.TC_Color, EE.TN_EtapaPadreID
    FROM GD.TGESTORDOCUMENTAL_Etapa E
    LEFT JOIN GD.TGESTORDOCUMENTAL_Etapa_Etapa EE ON EE.TN_EtapaID = E.TN_Id
    WHERE E.TN_Id = @pIId;
END;
GO

CREATE PROCEDURE GD.PA_ObtenerEtapasPorNormaId
    @pINormaID INT
AS
BEGIN
    -- Validar que la norma exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TN_Id = @pINormaID)
    BEGIN
        RAISERROR('La norma con el Id especificado no existe.', 16, 1);
        RETURN 1;
    END

    -- Devolver todas las etapas que corresponden al NormaID y no están eliminadas
    SELECT E.TN_Id, E.TC_Nombre, E.TC_Descripcion, E.TB_Eliminado, E.TN_NormaID, E.TC_Color
    FROM GD.TGESTORDOCUMENTAL_Etapa E
    WHERE E.TN_NormaID = @pINormaID AND E.TB_Eliminado = 0;
END;
GO
