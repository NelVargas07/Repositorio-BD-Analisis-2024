--USE GESTORDOCUMENTALOIJ

CREATE PROCEDURE GD.PA_ActualizarEtapa
    @pIId INT,
    @pINombre NVARCHAR(255),
    @pIDescripcion NVARCHAR(500),
    @pIEliminado BIT,
    @pIEtapaPadreID INT = NULL,
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
            TC_Color = @pIColor
        WHERE TN_Id = @pIId;

        -- Actualizar la relación en GD.TGESTORDOCUMENTAL_Etapa_Etapa si se proporciona un EtapaPadreID
        IF @pIEtapaPadreID IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa_Etapa WHERE TN_EtapaID = @pIId)
            BEGIN
                -- Actualizar la relación si ya existe
				EXEC GD.PA_ActualizarEtapa_Etapa @pIEtapaPadreID, @pIId
            END
            ELSE
            BEGIN
                -- Insertar la relación si no existe
				EXEC GD.PA_InsertarEtapa_Etapa @pIEtapaPadreID,@pIId
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
    @pINombre NVARCHAR(255),
    @pIDescripcion NVARCHAR(500),
    @pIEtapaPadreID INT = NULL,
    @pIColor VARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que no exista una etapa con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TC_Nombre = @pINombre)
        BEGIN
            RAISERROR('Ya existe una etapa con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva etapa
        INSERT INTO GD.TGESTORDOCUMENTAL_Etapa (TC_Nombre, TC_Descripcion, TB_Eliminado, TC_Color)
        VALUES (@pINombre, @pIDescripcion, 0, @pIColor);

        -- Obtener el Id de la etapa insertada
        DECLARE @NewId INT = SCOPE_IDENTITY();

        -- Insertar la relación en GD.TGESTORDOCUMENTAL_Etapa_Etapa si hay un padre
        IF @pIEtapaPadreID IS NOT NULL
        BEGIN
            EXEC GD.PA_InsertarEtapa_Etapa @pIEtapaPadreID,@NewId
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
    SELECT E.TN_Id, E.TC_Nombre, E.TC_Descripcion, E.TB_Eliminado, E.TC_Color, EE.TN_EtapaPadreID
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
    SELECT E.TN_Id, E.TC_Nombre, E.TC_Descripcion, E.TB_Eliminado, E.TC_Color, EE.TN_EtapaPadreID
    FROM GD.TGESTORDOCUMENTAL_Etapa E
    JOIN GD.TGESTORDOCUMENTAL_Etapa_Etapa EE ON EE.TN_EtapaID = E.TN_Id
    WHERE E.TN_Id = @pIId;
END;
GO

CREATE PROCEDURE GD.PA_ObtenerEtapasPorPadreId
    @pIEtapaPadreID INT
AS
BEGIN
    -- Validar que la etapa padre exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pIEtapaPadreID)
    BEGIN
        RAISERROR('La etapa padre con el Id especificado no existe.', 16, 1);
        RETURN 1;
    END

    -- Devolver todas las etapas hijas correspondientes al EtapaPadreID y que no estén eliminadas
    SELECT E.TN_Id, E.TC_Nombre, E.TC_Descripcion, E.TB_Eliminado, E.TC_Color
    FROM GD.TGESTORDOCUMENTAL_Etapa E
    JOIN GD.TGESTORDOCUMENTAL_Etapa_Etapa EE ON EE.TN_EtapaID = E.TN_Id
    WHERE EE.TN_EtapaPadreID = @pIEtapaPadreID AND E.TB_Eliminado = 0;
END;
GO
