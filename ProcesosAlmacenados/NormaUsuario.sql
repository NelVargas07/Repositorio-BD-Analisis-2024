--USE GestorDocumentalOIJ

CREATE PROCEDURE GD.PA_InsertarNormaUsuario
    @pN_NormaID INT,
    @pN_UsuarioID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la norma exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma WHERE TN_Id = @pN_NormaID AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; -- Norma no encontrada
        END

        -- Validar que el usuario exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Usuario WHERE TN_Id = @pN_UsuarioID AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; -- Usuario no encontrado
        END

        -- Insertar la relación entre norma y usuario
        INSERT INTO GD.TGESTORDOCUMENTAL_Norma_Usuario (TN_NormaID, TN_UsuarioID)
        VALUES (@pN_NormaID, @pN_UsuarioID);

        COMMIT;
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; 
    END CATCH
END;
GO

CREATE PROCEDURE GD.PA_EliminarNormaUsuario
    @pN_NormaID INT,
    @pN_UsuarioID INT
AS
BEGIN
     BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la relación entre norma y usuario exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Norma_Usuario 
                       WHERE TN_NormaID = @pN_NormaID AND TN_UsuarioID = @pN_UsuarioID)
        BEGIN
            ROLLBACK;
            RETURN 1; -- Relación no encontrada
        END

        -- Eliminar la relación entre norma y usuario
        DELETE FROM GD.TGESTORDOCUMENTAL_Norma_Usuario 
        WHERE TN_NormaID = @pN_NormaID AND TN_UsuarioID = @pN_UsuarioID;

        COMMIT;
        RETURN 0; 
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; 
    END CATCH
END;
GO

CREATE PROCEDURE GD.PA_ListarNormaUsuario 
AS
BEGIN
    SELECT
	TN_NormaID AS NormaID,
	TN_UsuarioID AS UsuarioID	
	FROM GD.TGESTORDOCUMENTAL_Norma_Usuario 
	ORDER BY TN_NormaID DESC
END