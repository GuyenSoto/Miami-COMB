USE [FITWorldGym]
GO
/****** Object:  StoredProcedure [dbo].[sp_FillDimProduct]    Script Date: 5/19/2025 2:40:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_FillDimProduct]
AS
BEGIN
    DECLARE @RowCount INT = 0;
    
    BEGIN TRY
        -- Iniciar transacción para garantizar consistencia
        BEGIN TRANSACTION;
        
        -- Merchandise Table
        INSERT INTO [FITWorldGym].[dbo].[DimProduct] (ProductID, ProductName, ProductPrice, ProductType, NameLocation)
        SELECT M.MrchID, M.MrchName, M.MrchPrice, 'Merchandise', ''
        FROM [GymSourceDataOLTP].[dbo].[Merchandise] M
        LEFT JOIN [FITWorldGym].[dbo].[DimProduct] DP ON DP.ProductID = M.MrchID
        WHERE DP.ProductID IS NULL;

        SET @RowCount = @RowCount + @@ROWCOUNT;

        -- SpecialEvents Table
        INSERT INTO [FITWorldGym].[dbo].[DimProduct] (ProductID, ProductName, ProductPrice, ProductType, NameLocation)
        SELECT SE.CCID, SE.EventType, SE.AmountCharged, 'Event', SE.CCNameLocation
        FROM [GymSourceDataOLTP].[dbo].[SpecialEvents] SE
        LEFT JOIN [FITWorldGym].[dbo].[DimProduct] DP ON DP.ProductID = SE.CCID
        WHERE DP.ProductID IS NULL;

        SET @RowCount = @RowCount + @@ROWCOUNT;

        -- MemberShip Table
        INSERT INTO [FITWorldGym].[dbo].[DimProduct] (ProductID, ProductName, ProductPrice, ProductType, NameLocation)
        SELECT MS.MshpID, MS.MshpName, MS.MshpPrice, 'Membership', ''
        FROM [GymSourceDataOLTP].[dbo].[Membership] MS
        LEFT JOIN [FITWorldGym].[dbo].[DimProduct] DP ON DP.ProductID = MS.MshpID
        WHERE DP.ProductID IS NULL;

        SET @RowCount = @RowCount + @@ROWCOUNT;

        -- OneDayPassCategory Table
        INSERT INTO [FITWorldGym].[dbo].[DimProduct] (ProductID, ProductName, ProductPrice, ProductType, NameLocation)
        SELECT OPC.PassCatID, OPC.CatName, OPC.Price, 'OneDayPass', ''
        FROM [GymSourceDataOLTP].[dbo].[OneDayPassCategory] OPC
        LEFT JOIN [FITWorldGym].[dbo].[DimProduct] DP ON DP.ProductID = OPC.PassCatID
        WHERE DP.ProductID IS NULL;

        SET @RowCount = @RowCount + @@ROWCOUNT;
        
        -- Commit transaction
        COMMIT TRANSACTION;

        -- Print result
        IF @RowCount > 0
            PRINT CAST(@RowCount AS NVARCHAR) + ' records were added to the DimProduct table.'
        ELSE
            PRINT 'The DimProduct table is up to date. No new records were copied.';
    END TRY
    BEGIN CATCH
        -- En caso de error, revertir la transacción
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        PRINT 'Error en sp_FillDimProduct: ' + ERROR_MESSAGE();
    END CATCH
END;