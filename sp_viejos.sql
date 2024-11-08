---categorias

--USE GestorDocumentalOIJ

-- Procedimiento para actualizar categoría
CREATE PROCEDURE GD.PA_ActualizarCategoria
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la categoría exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Categoria WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('La categoría con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END
        
        -- Validar que el nombre no exista para otra categoría
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Categoria WHERE TC_Nombre = @pC_Nombre AND TN_Id != @pN_Id)
        BEGIN
            RAISERROR('Ya existe una categoría con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar la categoría
        UPDATE GD.TGESTORDOCUMENTAL_Categoria
        SET TC_Nombre = @pC_Nombre,
            TC_Descripcion = @pC_Descripcion,
            TB_Eliminado = @pB_Eliminado
        WHERE TN_Id = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        -- Si ocurre algún error, deshacer la transacción
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para insertar nueva categoría
CREATE PROCEDURE GD.PA_InsertarCategoria
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que no exista una categoría con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Categoria WHERE TC_Nombre = @pC_Nombre)
        BEGIN
            RAISERROR('Ya existe una categoría con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva categoría
        INSERT INTO GD.TGESTORDOCUMENTAL_Categoria (TC_Nombre, TC_Descripcion, TB_Eliminado)
        VALUES (@pC_Nombre, @pC_Descripcion, 0);

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre algún error, deshacer la transacción
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para eliminar categoría
CREATE PROCEDURE GD.PA_EliminarCategoria
    @pN_Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la categoría exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Categoria WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('La categoría con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminar la categoría (eliminado lógico)
        UPDATE GD.TGESTORDOCUMENTAL_Categoria
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre algún error, deshacer la transacción
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para listar categorías activas
CREATE PROCEDURE GD.PA_ListarCategorias
AS
BEGIN
    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado
    FROM GD.TGESTORDOCUMENTAL_Categoria
    WHERE TB_Eliminado = 0;
END;
GO

-- Procedimiento para obtener categoría por Id
CREATE PROCEDURE GD.PA_ObtenerCategoriaPorId
    @pN_Id INT
AS
BEGIN
    -- Validar que la categoría exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Categoria WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('La categoría con el Id especificado no existe.', 16, 1);
        RETURN;
    END

    -- Devolver la categoría
    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado
    FROM GD.TGESTORDOCUMENTAL_Categoria
    WHERE TN_Id = @pN_Id;
END;
GO

----docto

CREATE PROCEDURE GD.PA_sp_InsertarDocTo
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que no exista un DocTo con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TC_Nombre = @pC_Nombre)
        BEGIN
            RAISERROR('Ya existe un DocTo con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar el nuevo DocTo
        INSERT INTO GD.TGESTORDOCUMENTAL_DocTo (TC_Nombre, TC_Descripcion, TB_Eliminado)
        VALUES (@pC_Nombre, @pC_Descripcion, 0);

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre alg�n error, deshacer la transacci�n
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- SP para actualizar un registro en GD.TGESTORDOCUMENTAL_DocTo
CREATE PROCEDURE GD.PA_sp_ActualizarDocTo
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el DocTo exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('El DocTo con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END
        
        -- Validar que el nombre no exista para otro DocTo
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TC_Nombre = @pC_Nombre AND TN_Id != @pN_Id)
        BEGIN
            RAISERROR('Ya existe un DocTo con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar el DocTo
        UPDATE GD.TGESTORDOCUMENTAL_DocTo
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

-- SP para eliminar un registro en GD.TGESTORDOCUMENTAL_DocTo (eliminado l�gico)
CREATE PROCEDURE GD.PA_sp_EliminarDocTo
    @pN_Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el DocTo exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('El DocTo con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminar l�gicamente el DocTo
        UPDATE GD.TGESTORDOCUMENTAL_DocTo
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

-- SP para listar todos los registros no eliminados en GD.TGESTORDOCUMENTAL_DocTo
CREATE PROCEDURE GD.PA_sp_ListarDocTos
AS
BEGIN
    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado
    FROM GD.TGESTORDOCUMENTAL_DocTo
    WHERE TB_Eliminado = 0;
END;
GO

-- SP para obtener un registro espec�fico en GD.TGESTORDOCUMENTAL_DocTo por su ID
CREATE PROCEDURE GD.PA_sp_ObtenerDocToPorId
    @pN_Id INT
AS
BEGIN
    -- Validar que el DocTo exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('El DocTo con el Id especificado no existe.', 16, 1);
        RETURN;
    END

    -- Devolver el DocTo
    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado
    FROM GD.TGESTORDOCUMENTAL_DocTo
    WHERE TN_Id = @pN_Id AND TB_Eliminado = 0;
END;
GO

---norma

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

----tipoDocumento

CREATE PROCEDURE GD.PA_ActualizarTipoDocumento
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que el tipo de documento exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('El tipo de documento con el Id ' + CAST(@pN_Id AS NVARCHAR(10)) + ' no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END
        
        -- Validar que el nombre no exista para otro tipo de documento
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TC_Nombre = @pC_Nombre AND TN_Id != @pN_Id)
        BEGIN
            RAISERROR('Ya existe un tipo de documento con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar el tipo de documento
        UPDATE GD.TGESTORDOCUMENTAL_TipoDocumento
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

CREATE PROCEDURE GD.PA_InsertarTipoDocumento
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que no exista un tipo de documento con el mismo nombre
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TC_Nombre = @pC_Nombre)
        BEGIN
            RAISERROR('Ya existe un tipo de documento con el mismo nombre.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar el nuevo tipo de documento
        INSERT INTO GD.TGESTORDOCUMENTAL_TipoDocumento (TC_Nombre, TC_Descripcion, TB_Eliminado)
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

CREATE PROCEDURE GD.PA_EliminarTipoDocumento
    @pN_Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el tipo de documento exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('El tipo de documento con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminado logico
        UPDATE GD.TGESTORDOCUMENTAL_TipoDocumento
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

CREATE PROCEDURE GD.PA_ListarTiposDocumento
AS
BEGIN
    -- Devolver todos los tipos de documento que no han sido eliminados
    SELECT TN_Id as Id, 
	TC_Nombre as Nombre, 
	TC_Descripcion as Descripcion, 
	TB_Eliminado as Eliminado
    FROM GD.TGESTORDOCUMENTAL_TipoDocumento
    WHERE TB_Eliminado = 0;
END;
GO

CREATE PROCEDURE GD.PA_ObtenerTipoDocumentoPorId
    @pN_Id INT
AS
BEGIN
    -- Validar que el tipo de documento exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('El tipo de documento con el Id especificado no existe.', 16, 1);
        RETURN 1;
    END

    -- Devolver el tipo de documento
    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado
    FROM GD.TGESTORDOCUMENTAL_TipoDocumento
    WHERE TN_Id = @pN_Id AND TB_Eliminado = 0;
END;
GO

----etapa
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

-----SUBCLASIFICACION

--USE GestorDocumentalOIJ

-- Procedimiento para insertar en GD.TGESTORDOCUMENTAL_Subclasificacion
CREATE PROCEDURE GD.PA_InsertarSubclasificacion
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pN_ClasificacionID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la clasificacion exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pN_ClasificacionID)
        BEGIN
            RAISERROR('La clasificaci�n con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que no exista una subclasificacion con el mismo nombre para la misma clasificacion
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TC_Nombre = @pC_Nombre AND TN_ClasificacionID = @pN_ClasificacionID)
        BEGIN
            RAISERROR('Ya existe una subclasificaci�n con el mismo nombre en esta clasificaci�n.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar la nueva subclasificacion
        INSERT INTO GD.TGESTORDOCUMENTAL_Subclasificacion (TC_Nombre, TC_Descripcion, TB_Eliminado, TN_ClasificacionID)
        VALUES (@pC_Nombre, @pC_Descripcion, 0, @pN_ClasificacionID);

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre algun error, deshacer la transaccion
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para actualizar en GD.TGESTORDOCUMENTAL_Subclasificacion
CREATE PROCEDURE GD.PA_ActualizarSubclasificacion
    @pN_Id INT,
    @pC_Nombre NVARCHAR(255),
    @pC_Descripcion NVARCHAR(500),
    @pB_Eliminado BIT,
    @pN_ClasificacionID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la subclasificacion exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('La subclasificacion con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que la clasificacion exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Clasificacion WHERE TN_Id = @pN_ClasificacionID)
        BEGIN
            RAISERROR('La clasificacion con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Validar que el nombre no exista para otra subclasificacion en la misma clasificacion
        IF EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TC_Nombre = @pC_Nombre AND TN_ClasificacionID = @pN_ClasificacionID AND TN_Id != @pN_Id)
        BEGIN
            RAISERROR('Ya existe una subclasificacion con el mismo nombre en esta clasificacion.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Actualizar la subclasificacion
        UPDATE GD.TGESTORDOCUMENTAL_Subclasificacion
        SET TC_Nombre = @pC_Nombre,
            TC_Descripcion = @pC_Descripcion,
            TB_Eliminado = @pB_Eliminado,
            TN_ClasificacionID = @pN_ClasificacionID
        WHERE TN_Id = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre algun error, deshacer la transaccion
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para eliminar en GD.TGESTORDOCUMENTAL_Subclasificacion (eliminacion logica)
CREATE PROCEDURE GD.PA_EliminarSubclasificacion
    @pN_Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la subclasificacion exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('La subclasificacion con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Marcar la subclasificacion como eliminada
        UPDATE GD.TGESTORDOCUMENTAL_Subclasificacion
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        -- Si ocurre algun error, deshacer la transaccion
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para listar todas las subclasificaciones no eliminadas
CREATE PROCEDURE GD.PA_ListarSubclasificaciones
AS
BEGIN
    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado,
	TN_ClasificacionID as ClasificacionID
    FROM GD.TGESTORDOCUMENTAL_Subclasificacion
    WHERE TB_Eliminado = 0;
END;
GO

-- Procedimiento para obtener una subclasificacion por ID
CREATE PROCEDURE GD.PA_ObtenerSubclasificacionPorId
    @pN_Id INT
AS
BEGIN
    -- Validar que la subclasificacion exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('La subclasificacion con el Id especificado no existe.', 16, 1);
        RETURN;
    END

    -- Devolver la subclasificacion
    SELECT TN_Id as Id,
	TC_Nombre as Nombre,
	TC_Descripcion as Descripcion,
	TB_Eliminado as Eliminado,
	TN_ClasificacionID as ClasificacionID
    FROM GD.TGESTORDOCUMENTAL_Subclasificacion
    WHERE TN_Id = @pN_Id;
END;
GO

----DOCUMENTO

--USE GestorDocumentalOIJ
-- Procedimiento para insertar un nuevo documento
CREATE or alter PROCEDURE GD.PA_InsertarDocumento
    @pC_Codigo NVARCHAR(255),
    @pC_Asunto NVARCHAR(255),
    @pC_Descripcion NVARCHAR(1000),
    @pC_PalabraClave NVARCHAR(255),
    @pN_CategoriaID INT,
    @pN_TipoDocumento INT,
    @pN_OficinaID INT,
    @pC_Vigencia NVARCHAR(255),
    @pN_EtapaID INT,
    @pN_SubClasificacionID INT,
	@pB_Activo BIT,
	@pB_Descargable BIT,
	@pN_DocToID INT,
    @pC_Doctos NVARCHAR(MAX) -- JSON con m�ltiples registros de documentos
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Validar que todas las referencias existan
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Categoria WHERE TN_Id = @pN_CategoriaID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TN_Id = @pN_TipoDocumento)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        --IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Oficina WHERE TN_Id = @pN_OficinaID)
        --BEGIN
        --    ROLLBACK TRANSACTION;
        --    RETURN 1;
        --END

        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pN_EtapaID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pN_SubClasificacionID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Insertar el nuevo documento
        INSERT INTO GD.TGESTORDOCUMENTAL_Documento (TC_Codigo, TC_Asunto, TC_Descripcion, TC_PalabraClave, TN_CategoriaID, TN_TipoDocumento, TN_OficinaID, TC_Vigencia, TN_EtapaID, TN_SubClasificacionID, TN_DocTo, TB_Activo,TB_Descargable)
        VALUES (@pC_Codigo, @pC_Asunto, @pC_Descripcion, @pC_PalabraClave, @pN_CategoriaID, @pN_TipoDocumento, @pN_OficinaID, @pC_Vigencia, @pN_EtapaID, @pN_SubClasificacionID,@pN_DocToID,@pB_Activo,@pB_Descargable);

        DECLARE @TN_DocumentoID INT = SCOPE_IDENTITY(); -- Obtener el ID del nuevo documento

        -- Insertar relaciones en GD.TGESTORDOCUMENTAL_Documento_Documento desde el JSON
        DECLARE @JSON NVARCHAR(MAX) = @pC_Doctos;
        DECLARE @i INT = 0;
        DECLARE @total_records INT = (SELECT COUNT(*) FROM OPENJSON(@JSON));
        
        WHILE @i < @total_records
        BEGIN
            DECLARE @docto INT = JSON_VALUE(@JSON, CONCAT('$[', @i, '].docto'));
            DECLARE @docRelacionado NVARCHAR(255) = JSON_VALUE(@JSON, CONCAT('$[', @i, '].docRelacionado'));
			select @docto
			select @docRelacionado
            -- Validar que el documento exista
            IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @docto)
            BEGIN
                ROLLBACK TRANSACTION;
                RETURN 1;
            END

            INSERT INTO GD.TGESTORDOCUMENTAL_Documento_Documento (TN_DocumentoID, TN_DocTo, TC_DocRelaciona)
            VALUES (@TN_DocumentoID, @docto, @docRelacionado);

            SET @i = @i + 1;
        END

        COMMIT TRANSACTION;
        RETURN 0; -- �xito
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1; -- Error
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE GD.PA_ActualizarDocumento
    @pN_Id INT,
    @pC_Codigo NVARCHAR(255),
    @pC_Asunto NVARCHAR(255),
    @pC_Descripcion NVARCHAR(1000),
    @pC_PalabraClave NVARCHAR(255),
    @pN_CategoriaID INT,
    @pN_TipoDocumento INT,
    @pN_OficinaID INT,
    @pC_Vigencia NVARCHAR(255),
    @pN_EtapaID INT,
    @pN_DocToID INT,
    @pN_SubClasificacionID INT,
	@pB_Activo BIT,
	@pB_Descargable BIT,
    @pC_Doctos NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Validar que el documento exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento WHERE TN_Id = @pN_Id)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;  -- Documento no existe
        END

        -- Validar que la categoría exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Categoria WHERE TN_Id = @pN_CategoriaID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;  -- Categoría no existe
        END

        -- Validar que el tipo de documento exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_TipoDocumento WHERE TN_Id = @pN_TipoDocumento)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;  -- Tipo de documento no existe
        END

        -- Validar que la oficina exista
        --IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Oficina WHERE TN_Id = @pN_OficinaID)
        --BEGIN
        --    ROLLBACK TRANSACTION;
        --    RETURN 1;  -- Oficina no existe
        --END

        -- Validar que la etapa exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Etapa WHERE TN_Id = @pN_EtapaID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;  -- Etapa no existe
        END

        -- Validar que el DocTo exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_DocTo WHERE TN_Id = @pN_DocToID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;  -- DocTo no existe
        END

        -- Validar que la subclasificación exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Subclasificacion WHERE TN_Id = @pN_SubClasificacionID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1;  -- Subclasificación no existe
        END

        -- Actualizar el documento
        UPDATE GD.TGESTORDOCUMENTAL_Documento
        SET TC_Codigo = @pC_Codigo,
            TC_Asunto = @pC_Asunto,
            TC_Descripcion = @pC_Descripcion,
            TC_PalabraClave = @pC_PalabraClave,
            TN_CategoriaID = @pN_CategoriaID,
            TN_TipoDocumento = @pN_TipoDocumento,
            TN_OficinaID = @pN_OficinaID,
            TC_Vigencia = @pC_Vigencia,
            TN_EtapaID = @pN_EtapaID,
            TN_DocTo = @pN_DocToID,
			TB_Activo = @pB_Activo,
			TB_Descargable = @pB_Descargable,
            TN_SubClasificacionID = @pN_SubClasificacionID
        WHERE TN_Id = @pN_Id;

        -- Eliminar relaciones anteriores
        DELETE FROM GD.TGESTORDOCUMENTAL_Documento_Documento
        WHERE TN_DocumentoID = @pN_Id;

        -- Insertar nuevas relaciones desde el JSON
        DECLARE @i INT = 0;
        DECLARE @total_records INT;
        SET @total_records = (SELECT COUNT(*) FROM OPENJSON(@pC_Doctos));

        DECLARE @DoctoID INT;
        DECLARE @DocRelacionado NVARCHAR(255);

        WHILE @i < @total_records
        BEGIN
            SET @DoctoID = JSON_VALUE(@pC_Doctos, CONCAT('$[', @i, '].docto'));
            SET @DocRelacionado = JSON_VALUE(@pC_Doctos, CONCAT('$[', @i, '].docRelacionado'));

            INSERT INTO GD.TGESTORDOCUMENTAL_Documento_Documento (TN_DocumentoID, TN_DocTo, TC_DocRelaciona)
            VALUES (@pN_Id, @DoctoID, @DocRelacionado);

            SET @i = @i + 1;
        END

        COMMIT TRANSACTION;
        RETURN 0;  -- Actualización exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1;  -- Error en la transacción
    END CATCH
END;
GO



-- Procedimiento para eliminar un documento (eliminado l�gico)
CREATE PROCEDURE GD.PA_EliminarDocumento
    @pN_Id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el documento exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento WHERE TN_Id = @pN_Id)
        BEGIN
            RAISERROR('El documento con el Id especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN 1;
        END

        -- Eliminar el documento (eliminado l�gico)
        UPDATE GD.TGESTORDOCUMENTAL_Documento
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

		DELETE FROM GD.TGESTORDOCUMENTAL_Documento_Documento
        WHERE TN_DocumentoID = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1;
    END CATCH
END;
GO

-- Procedimiento para listar todos los documentos no eliminados
CREATE or alter PROCEDURE GD.PA_ListarDocumentos
AS
BEGIN
	WITH Versiones AS (
		SELECT 
			V.TN_Id AS VersionID,
			V.TN_DocumentoID,
			V.TC_UrlVersion,
			V.TN_NumeroVersion,
			V.TF_FechaCreacion,
			ROW_NUMBER() OVER (PARTITION BY V.TN_DocumentoID ORDER BY V.TN_NumeroVersion DESC, V.TF_FechaCreacion DESC) AS rn
		FROM GD.TGESTORDOCUMENTAL_Version V
	)
    SELECT 
		D.TN_Id AS Id, --
        D.TC_Codigo AS Codigo, --
        D.TC_Asunto AS Nombre, --
        D.TN_CategoriaID AS CategoriaID, --
        D.TN_TipoDocumento AS TipoDocumento, --
        D.TN_OficinaID AS OficinaID, --
        D.TC_Vigencia AS Vigencia, --
        D.TN_EtapaID AS EtapaID, --
        D.TN_DocTo AS DocToID, --
        D.TN_SubClasificacionID AS SubClasificacionID,
		N.TN_Id AS NormaID,--
		ISNULL(V.VersionID,0) AS VersionID,--
		C.TN_Id AS ClasificacionID--
    FROM GD.TGESTORDOCUMENTAL_Documento D
	JOIN GD.TGESTORDOCUMENTAL_Etapa E on e.TN_Id = d.TN_EtapaID
	JOIN GD.TGESTORDOCUMENTAL_Norma N ON N.TN_Id = E.TN_NormaID
	LEFT JOIN Versiones V ON V.TN_DocumentoID = D.TN_Id AND V.rn = 1
	JOIN GD.TGESTORDOCUMENTAL_Subclasificacion SC ON SC.TN_Id = D.TN_SubClasificacionID
	JOIN GD.TGESTORDOCUMENTAL_Clasificacion C ON C.TN_Id = SC.TN_ClasificacionID
	WHERE D.TB_Eliminado = 0
END;
GO

CREATE OR ALTER PROCEDURE GD.PA_ListarDocumentosConsulta
AS
BEGIN
    WITH Versiones AS (
        SELECT 
            V.TN_Id AS VersionID,
            V.TN_DocumentoID,
            V.TC_UrlVersion,
            V.TN_NumeroVersion,
            V.TF_FechaCreacion,
            ROW_NUMBER() OVER (PARTITION BY V.TN_DocumentoID ORDER BY V.TN_NumeroVersion DESC, V.TF_FechaCreacion DESC) AS rn
        FROM GD.TGESTORDOCUMENTAL_Version V
    )
    SELECT 
        D.TN_Id AS Id,
        D.TC_Codigo AS Codigo,
        D.TC_Asunto AS Nombre,
        D.TC_Descripcion AS Descripcion,
        D.TN_CategoriaID AS CategoriaID,
        D.TN_TipoDocumento AS TipoDocumento,
        D.TC_PalabraClave AS PalabraClave,
        D.TN_OficinaID AS OficinaID,
        D.TC_Vigencia AS Vigencia,
        D.TN_EtapaID AS EtapaID,
        D.TN_DocTo AS DocToID,
        D.TN_SubClasificacionID AS SubClasificacionID,
        N.TN_Id AS NormaID,
        ISNULL(V.TN_NumeroVersion, 0) AS VersionID,
        C.TN_Id AS ClasificacionID,
        D.TB_Descargable AS descargable,
        V.TC_UrlVersion AS urlVersion
    FROM GD.TGESTORDOCUMENTAL_Documento D
    JOIN GD.TGESTORDOCUMENTAL_Etapa E ON E.TN_Id = D.TN_EtapaID
    JOIN GD.TGESTORDOCUMENTAL_Norma N ON N.TN_Id = E.TN_NormaID
    LEFT JOIN Versiones V ON V.TN_DocumentoID = D.TN_Id AND V.rn = 1
    JOIN GD.TGESTORDOCUMENTAL_Subclasificacion SC ON SC.TN_Id = D.TN_SubClasificacionID
    JOIN GD.TGESTORDOCUMENTAL_Clasificacion C ON C.TN_Id = SC.TN_ClasificacionID
    WHERE D.TB_Eliminado = 0 AND D.TB_Activo = 1
    ORDER BY D.TN_Id; -- Puedes ajustar el orden según lo necesites
END;
GO


/*
CREATE or alter PROCEDURE GD.PA_ListarDocumentosConsultaHorizontal
AS
BEGIN
    SELECT 
		D.TN_Id AS Id, --
        D.TC_Codigo AS Codigo, --
        D.TN_CategoriaID AS CategoriaID, --
        D.TN_TipoDocumento AS TipoDocumento, --
        D.TN_OficinaID AS OficinaID, --
        D.TC_Vigencia AS Vigencia, --
        D.TN_DocTo AS DocToID, --
		N.TN_Id AS NormaID,--
		ISNULL(V.TN_Id,0) AS VersionID,--
		V.TC_UrlVersion AS urlVersion, 
		C.TN_Id AS ClasificacionID--
    FROM GD.TGESTORDOCUMENTAL_Documento D
	JOIN GD.TGESTORDOCUMENTAL_Etapa E on e.TN_Id = d.TN_EtapaID
	JOIN GD.TGESTORDOCUMENTAL_Norma N ON N.TN_Id = E.TN_NormaID
	LEFT JOIN GD.TGESTORDOCUMENTAL_Version V ON V.TN_DocumentoID = D.TN_Id
	JOIN GD.TGESTORDOCUMENTAL_Subclasificacion SC ON SC.TN_Id = D.TN_SubClasificacionID
	JOIN GD.TGESTORDOCUMENTAL_Clasificacion C ON C.TN_Id = SC.TN_ClasificacionID
	WHERE D.TB_Eliminado = 0
	ORDER BY V.TN_NumeroVersion DESC, V.TF_FechaCreacion DESC;
END;
GO

CREATE or alter PROCEDURE GD.PA_ListarDocumentosConsultaVerticalProceso
AS
BEGIN
    SELECT 
		D.TN_Id AS Id, --
        D.TN_OficinaID AS OficinaID, --
		ISNULL(V.TN_Id,0) AS VersionID,--
		V.TC_UrlVersion AS urlVersion
    FROM GD.TGESTORDOCUMENTAL_Documento D
	LEFT JOIN GD.TGESTORDOCUMENTAL_Version V ON V.TN_DocumentoID = D.TN_Id
	WHERE D.TB_Eliminado = 0
	ORDER BY V.TN_NumeroVersion DESC, V.TF_FechaCreacion DESC;
END;
GO

CREATE or alter PROCEDURE GD.PA_ListarDocumentosConsultaVerticalFiltro
AS
BEGIN
    SELECT 
		D.TN_Id AS Id, --
        D.TN_OficinaID AS OficinaID, --
		ISNULL(V.TN_Id,0) AS VersionID,--
		V.TC_UrlVersion AS urlVersion
    FROM GD.TGESTORDOCUMENTAL_Documento D
	LEFT JOIN GD.TGESTORDOCUMENTAL_Version V ON V.TN_DocumentoID = D.TN_Id
	WHERE D.TB_Eliminado = 0
	ORDER BY V.TN_NumeroVersion DESC, V.TF_FechaCreacion DESC;
END;
GO*/

-- Procedimiento para obtener un documento por su Id
CREATE OR ALTER PROCEDURE GD.PA_ObtenerDocumentoPorId
    @pN_Id INT
AS
BEGIN
    -- Validar que el documento exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('El documento con el Id especificado no existe.', 16, 1);
        RETURN 1; -- Documento no existe, retorna 1
    END

    -- Devolver el documento con todas las columnas y las relaciones en formato JSON
    SELECT 
        D.TN_Id AS Id, 
        D.TC_Codigo AS Codigo, 
        D.TC_Asunto AS Asunto, 
        D.TC_Descripcion AS Descripcion, 
        D.TC_PalabraClave AS PalabraClave, 
        D.TN_CategoriaID AS CategoriaID, 
        D.TN_TipoDocumento AS TipoDocumento, 
        D.TN_OficinaID AS OficinaID, 
        D.TC_Vigencia AS Vigencia, 
        D.TN_EtapaID AS EtapaID, 
        D.TN_DocTo AS DocToID, 
        D.TB_Activo AS Activo, 
        D.TB_Descargable AS Descargable, 
        D.TB_Eliminado AS Eliminado, 
        D.TN_SubClasificacionID AS SubClasificacionID,
        N.TN_Id AS NormaID,--
        C.TN_Id AS ClasificacionID,--
		ISNULL(V.TN_Id,0) AS VersionID,--
        (SELECT 
            JSON_QUERY((SELECT TN_DocTo AS docto, TC_DocRelaciona AS docRelacionado
                        FROM GD.TGESTORDOCUMENTAL_Documento_Documento
                        WHERE TN_DocumentoID = @pN_Id
                        FOR JSON PATH)) 
        ) AS doctos
    FROM GD.TGESTORDOCUMENTAL_Documento D
	LEFT JOIN GD.TGESTORDOCUMENTAL_Version V ON V.TN_DocumentoID = D.TN_Id
    JOIN GD.TGESTORDOCUMENTAL_Etapa E on e.TN_Id = D.TN_EtapaID
	JOIN GD.TGESTORDOCUMENTAL_Norma N ON N.TN_Id = E.TN_NormaID
    JOIN GD.TGESTORDOCUMENTAL_Subclasificacion SC ON SC.TN_Id = D.TN_SubClasificacionID
	JOIN GD.TGESTORDOCUMENTAL_Clasificacion C ON C.TN_Id = SC.TN_ClasificacionID
    WHERE D.TN_Id = @pN_Id;

    RETURN 0; -- Operación exitosa
END;
GO


----VERSION----

--USE GestorDocumentalOIJ

CREATE OR ALTER PROCEDURE GD.PA_InsertarVersion
    @pN_DocumentoID INT,
    @pN_NumeroVersion INT,
    @pC_UrlVersion NVARCHAR(500),
    @pC_NumeroSCD NVARCHAR(200),
    @pC_Justificacion NVARCHAR(500),
    @pN_UsuarioID INT,
    @pB_DocDinamico BIT,
    @pB_Obsoleto BIT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Validar que el documento y el usuario existan
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento WHERE TN_Id = @pN_DocumentoID)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1; -- Documento no existe
        END

        -- Insertar nueva versión
        INSERT INTO GD.TGESTORDOCUMENTAL_Version 
        (TN_DocumentoID, TN_NumeroVersion, TC_UrlVersion, TN_UsuarioID, TB_DocDinamico, TB_Obsoleto, TC_NumeroSCD, TC_Justificacion)
        VALUES 
        (@pN_DocumentoID, @pN_NumeroVersion, @pC_UrlVersion, @pN_UsuarioID, @pB_DocDinamico, @pB_Obsoleto, @pC_NumeroSCD, @pC_Justificacion);

        COMMIT TRANSACTION;
        RETURN 0; -- Inserción exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1; -- Error
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE GD.PA_ActualizarVersion
    @pN_Id INT,
    @pN_NumeroVersion INT,
    @pC_UrlVersion NVARCHAR(500),
    @pC_NumeroSCD NVARCHAR(200),
    @pC_Justificacion NVARCHAR(500),
    @pN_UsuarioID INT,
    @pB_DocDinamico BIT,
    @pB_Obsoleto BIT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Validar que la versión exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Version WHERE TN_Id = @pN_Id)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1; -- Versión no existe
        END

        -- Actualizar la versión
        UPDATE GD.TGESTORDOCUMENTAL_Version
        SET TN_NumeroVersion = @pN_NumeroVersion,
            TC_UrlVersion = @pC_UrlVersion,
            TN_UsuarioID = @pN_UsuarioID,
            TB_DocDinamico = @pB_DocDinamico,
            TB_Obsoleto = @pB_Obsoleto,
            TC_NumeroSCD = @pC_NumeroSCD,
            TC_Justificacion = @pC_Justificacion
        WHERE TN_Id = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0; -- Actualización exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1; -- Error
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE GD.PA_EliminarVersion
    @pN_Id INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Validar que la versión exista
        IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Version WHERE TN_Id = @pN_Id)
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN 1; -- Versión no existe
        END

        -- Marcar como eliminada
        UPDATE GD.TGESTORDOCUMENTAL_Version
        SET TB_Eliminado = 1
        WHERE TN_Id = @pN_Id;

        COMMIT TRANSACTION;
        RETURN 0; -- Eliminación exitosa
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RETURN 1; -- Error
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE GD.PA_ObtenerVersionPorId
    @pN_Id INT
AS
BEGIN
    -- Validar que la versión exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Version WHERE TN_Id = @pN_Id)
    BEGIN
        RAISERROR('La versión con el Id especificado no existe.', 16, 1);
        RETURN;
    END

    -- Devolver la versión
    SELECT TN_Id AS Id, 
            TN_DocumentoID AS DocumentoID, 
            TN_NumeroVersion AS NumeroVersion, 
            TF_FechaCreacion AS FechaCreacion, 
            TC_UrlVersion AS urlVersion, 
            TB_Eliminado AS eliminado, 
            TN_UsuarioID AS usuarioID,
            TB_DocDinamico AS DocDinamico,
            TB_Obsoleto AS Obsoleto,
            TC_NumeroSCD AS NumeroSCD,
            TC_Justificacion AS justificacion
    FROM GD.TGESTORDOCUMENTAL_Version
    WHERE TN_Id = @pN_Id;
END;
GO

CREATE OR ALTER PROCEDURE GD.PA_ListarVersiones
AS
BEGIN
    -- Devolver todas las versiones que no están marcadas como eliminadas
    SELECT TN_Id AS Id, 
            TN_DocumentoID AS DocumentoID, 
            TN_NumeroVersion AS NumeroVersion, 
            TF_FechaCreacion AS FechaCreacion, 
            TC_UrlVersion AS urlVersion, 
            TB_Eliminado AS eliminado, 
            TN_UsuarioID AS usuarioID,
            TB_DocDinamico AS DocDinamico,
            TB_Obsoleto AS Obsoleto,
            TC_NumeroSCD AS NumeroSCD,
            TC_Justificacion AS justificacion
    FROM GD.TGESTORDOCUMENTAL_Version
    WHERE TB_Eliminado = 0;
END;
GO

CREATE OR ALTER PROCEDURE GD.PA_ListarVersionPorDocumentoID
    @pN_DocumentoID INT
AS
BEGIN
    -- Validar que el documento exista
    IF NOT EXISTS (SELECT 1 FROM GD.TGESTORDOCUMENTAL_Documento WHERE TN_Id = @pN_DocumentoID)
    BEGIN
        RAISERROR('El documento con el Id especificado no existe.', 16, 1);
        RETURN;
    END

    -- Devolver la versión más reciente del documento que no esté eliminada
    SELECT TN_Id AS Id, 
                 TN_DocumentoID AS DocumentoID, 
                 TN_NumeroVersion AS NumeroVersion, 
                 TF_FechaCreacion AS FechaCreacion, 
                 TC_UrlVersion AS urlVersion, 
                 TB_Eliminado AS eliminado, 
                 TN_UsuarioID AS usuarioID,
                 TB_DocDinamico AS DocDinamico,
                 TB_Obsoleto AS Obsoleto,
                 TC_NumeroSCD AS NumeroSCD,
                 TC_Justificacion AS justificacion
    FROM GD.TGESTORDOCUMENTAL_Version
    WHERE TN_DocumentoID = @pN_DocumentoID
      AND TB_Eliminado = 0
    ORDER BY TN_NumeroVersion DESC, TF_FechaCreacion DESC; -- Orden para obtener la más reciente
END;
GO
