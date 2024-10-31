-- Procedimiento para insertar en GD.TGESTORDOCUMENTAL_Etapa_Etapa
CREATE OR ALTER PROCEDURE GD.PA_InsertarEtapa_Etapa
    @pN_EtapaPadreID INT,
    @pN_EtapaID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la etapa padre exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_ID = @pN_EtapaPadreID AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que la etapa hija exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_ID = @pN_EtapaID AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva relación etapa-etapa
        INSERT INTO GD.TGESTORDOCUMENTAL_Etapa_Etapa (TN_EtapaPadreID, TN_EtapaID)
        VALUES (@pN_EtapaPadreID, @pN_EtapaID);

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para actualizar GD.TGESTORDOCUMENTAL_Etapa_Etapa
CREATE PROCEDURE GD.PA_ActualizarEtapa_Etapa
    @pN_EtapaPadreID INT,
    @pN_EtapaID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la relación exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa_Etapa WHERE TN_EtapaPadreID = @pN_EtapaPadreID AND TN_EtapaID = @pN_EtapaID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar (en este caso no hay campos adicionales que actualizar)
        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para eliminar GD.TGESTORDOCUMENTAL_Etapa_Etapa
CREATE PROCEDURE GD.PA_EliminarEtapa_Etapa
    @pN_EtapaPadreID INT,
    @pN_EtapaID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la relación exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa_Etapa WHERE TN_EtapaPadreID = @pN_EtapaPadreID AND TN_EtapaID = @pN_EtapaID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminar la relación
        DELETE FROM GD.TGESTORDOCUMENTAL_Etapa_Etapa
        WHERE TN_EtapaPadreID = @pN_EtapaPadreID AND TN_EtapaID = @pN_EtapaID;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para listar relaciones de etapas
CREATE PROCEDURE GD.PA_ListarEtapas_Etapas
AS
BEGIN
    SELECT TN_EtapaPadreID, TN_EtapaID
    FROM GD.TGESTORDOCUMENTAL_Etapa_Etapa;
END;
GO
