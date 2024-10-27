--USE GestorDocumentalOIJ

CREATE PROCEDURE SC.PA_InsertarOficina
    @pC_Nombre NVARCHAR(255),
    @pC_CodigoOficina NVARCHAR(255),
    @pB_Gestor BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que no exista una oficina con el mismo nombre
        IF EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina WHERE TC_Nombre = @pC_Nombre AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

		IF EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina WHERE TC_CodigoOficina = @pC_CodigoOficina AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        -- Insertar nueva oficina
        INSERT INTO SC.TGESTORDOCUMENTAL_Oficina (TC_Nombre, TC_CodigoOficina, TB_Gestor, TB_Eliminado)
        VALUES (@pC_Nombre, @pC_CodigoOficina, @pB_Gestor, 0);

        COMMIT;
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; 
    END CATCH
END;

CREATE PROCEDURE SC.PA_ActualizarOficina
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_CodigoOficina NVARCHAR(255),
    @pB_Gestor BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la oficina exista
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina WHERE TN_Id = @pN_Id AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

		IF EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina WHERE TC_CodigoOficina = @pC_CodigoOficina AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        -- Validar que no exista otra oficina con el mismo nombre
        IF EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina WHERE TC_Nombre = @pC_Nombre AND TN_Id <> @pN_Id AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

		--validar si se hace gestor borrar relacion

        -- Actualizar la oficina
        UPDATE SC.TGESTORDOCUMENTAL_Oficina
        SET TC_Nombre = @pC_Nombre,
            TC_CodigoOficina = @pC_CodigoOficina,
            TB_Gestor = @pB_Gestor
        WHERE TN_Id = @pN_Id;

        COMMIT;
        RETURN 0; -- Actualización exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; -- Error en la ejecución
    END CATCH
END;

CREATE PROCEDURE SC.PA_EliminarOficina
    @pN_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la oficina exista y no esté ya eliminada
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina WHERE TN_Id = @pN_Id AND TB_Eliminado = 0 AND TB_Gestor = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

		IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento WHERE TN_OficinaID = @pN_Id AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1;
        END

		IF EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina_Usuario WHERE TN_OficinaID = @pN_Id)
        BEGIN
            ROLLBACK;
            RETURN 1;
        END

        UPDATE SC.TGESTORDOCUMENTAL_Oficina
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

		delete from SC.TGESTORDOCUMENTAL_Permiso_Oficina WHERE TN_OficinaID = @pN_Id
		delete from SC.TGESTORDOCUMENTAL_Oficina_Gestor WHERE TN_OficinaID = @pN_Id



        COMMIT;
        RETURN 0; -- Eliminación exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1; -- Error en la ejecución
    END CATCH
END;


CREATE PROCEDURE SC.PA_ListarOficinas
AS
BEGIN
    SELECT TN_Id, TC_Nombre, TC_CodigoOficina, TB_Gestor
    FROM SC.TGESTORDOCUMENTAL_Oficina
    WHERE TB_Eliminado = 0;
END;

CREATE PROCEDURE SC.PA_ListarOficinasGestor
AS
BEGIN
    SELECT TN_Id, TC_Nombre, TC_CodigoOficina, TB_Gestor
    FROM SC.TGESTORDOCUMENTAL_Oficina
    WHERE TB_Eliminado = 0 AND TB_Gestor = 1;
END;

CREATE PROCEDURE SC.PA_ListarOficinaPorID
    @pN_Id INT
AS
BEGIN
	BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el usuario exista y esté activo
        IF NOT EXISTS (SELECT 1 FROM SC.TGESTORDOCUMENTAL_Oficina WHERE TN_Id = @pN_Id AND TB_Eliminado = 0)
        BEGIN
            ROLLBACK;
            RETURN 1; 
        END

        SELECT TN_Id, TC_Nombre, TC_CodigoOficina, TB_Gestor
		FROM SC.TGESTORDOCUMENTAL_Oficina
		WHERE TN_Id = @pN_Id AND TB_Eliminado = 0;

        COMMIT;
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RETURN 1;
    END CATCH
END;
