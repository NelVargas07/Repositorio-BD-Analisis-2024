--USE GestorDocumentalOIJ

CREATE PROCEDURE SC.PA_InsertarOficinaGestor
    @pN_GestorID INT,
    @pN_OficinaID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la oficina exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina WHERE TN_Id = @pN_OficinaID AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        -- Validar que el gestor exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina WHERE TN_Id = @pN_GestorID AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; -- Gestor no encontrado
        END

        -- Insertar la relación entre oficina y gestor
        INSERT INTO SC.TGESTORDOCUMENTAL_Oficina_Gestor (TN_GestorID, TN_OficinaID)
        VALUES (@pN_GestorID, @pN_OficinaID);

        COMMIT;
        RETURN 0; -- Inserción exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; -- Error en la ejecución
    END CATCH
END;
GO

CREATE PROCEDURE SC.PA_EliminarOficinaGestor
    @pN_GestorID INT,
    @pN_OficinaID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la relación entre gestor y oficina exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina_Gestor 
                       WHERE TN_GestorID = @pN_GestorID AND TN_OficinaID = @pN_OficinaID)
        BEGIN
            ROLLBACK;
            RETURN 1; -- Relación no encontrada
        END

        -- Eliminar la relación entre gestor y oficina
        DELETE FROM SC.TGESTORDOCUMENTAL_Oficina_Gestor 
        WHERE TN_GestorID = @pN_GestorID AND TN_OficinaID = @pN_OficinaID;

        COMMIT;
        RETURN 0; -- Eliminación exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; -- Error en la ejecución
    END CATCH
END;
GO

CREATE PROCEDURE SC.PA_ListarGestorOficina
AS
BEGIN
    SELECT
	TN_GestorID AS GestorID,
	TN_OficinaID AS OficinaID	
	FROM SC.TGESTORDOCUMENTAL_Oficina_Gestor 
	ORDER BY TN_GestorID DESC
END