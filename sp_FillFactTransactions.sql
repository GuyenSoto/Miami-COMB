USE [FITWorldGym]
GO
/****** Object:  StoredProcedure [dbo].[sp_FillFactTransactions]    Script Date: 5/19/2025 2:41:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_FillFactTransactions]
AS
BEGIN
    DECLARE @RowCount INT = 0;
    
    BEGIN TRY
        -- Start transaction for data consistency
        BEGIN TRANSACTION;
        
        -- Member to FactTransactions
        INSERT INTO [FITWorldGym].[dbo].[FactTransactions] (TransactionDate, MemberID, ProductID, Quantity, Amount)
        SELECT 
            M.[MsDatePayed],
            M.[MembID],
            M.[MshpID],
            1,
            MS.[MshpPrice]
        FROM [GymSourceDataOLTP].[dbo].[Member] M
        JOIN [GymSourceDataOLTP].[dbo].[Membership] MS ON M.[MshpID] = MS.[MshpID]
        LEFT JOIN [FITWorldGym].[dbo].[FactTransactions] FT ON 
            FT.MemberID = M.[MembID] AND 
            FT.ProductID = M.[MshpID] AND 
            FT.TransactionDate = M.[MsDatePayed]
        WHERE FT.TransactionID IS NULL;

        SET @RowCount = @RowCount + @@ROWCOUNT;

        -- OneDayGuestPass to FactTransactions
        INSERT INTO [FITWorldGym].[dbo].[FactTransactions] (TransactionDate, MemberID, ProductID, Quantity, Amount)
        SELECT 
            ODP.[PassDate],
            ODP.[MembID],
            ODP.[PassCatID],
            1,
            OPC.[Price]
        FROM [GymSourceDataOLTP].[dbo].[OneDayGuestPass] ODP
        JOIN [GymSourceDataOLTP].[dbo].[OneDayPassCategory] OPC ON ODP.[PassCatID] = OPC.[PassCatID]
        LEFT JOIN [FITWorldGym].[dbo].[FactTransactions] FT ON 
            FT.MemberID = ODP.[MembID] AND 
            FT.ProductID = ODP.[PassCatID] AND 
            FT.TransactionDate = ODP.[PassDate]
        WHERE FT.TransactionID IS NULL;

        SET @RowCount = @RowCount + @@ROWCOUNT;

        -- Merchandise to FactTransactions
        INSERT INTO [FITWorldGym].[dbo].[FactTransactions] (TransactionDate, MemberID, ProductID, Quantity, Amount)
        SELECT 
            ST.[StrDate],
            ST.[MembID],
            SV.[MrchID],
            SV.[Quantity],
            MRC.[MrchPrice] * SV.[Quantity]
        FROM [GymSourceDataOLTP].[dbo].[SoldVia] SV
        JOIN [GymSourceDataOLTP].[dbo].[SalesTransaction] ST ON SV.[StrID] = ST.[STrID]
        JOIN [GymSourceDataOLTP].[dbo].[Merchandise] MRC ON SV.[MrchID] = MRC.[MrchID]
        LEFT JOIN [FITWorldGym].[dbo].[FactTransactions] FT ON 
            FT.MemberID = ST.[MembID] AND 
            FT.ProductID = SV.[MrchID] AND 
            FT.TransactionDate = ST.[StrDate] AND
            FT.Quantity = SV.[Quantity]
        WHERE FT.TransactionID IS NULL;

        SET @RowCount = @RowCount + @@ROWCOUNT;

        -- SpecialEvents to FactTransactions
        INSERT INTO [FITWorldGym].[dbo].[FactTransactions] (TransactionDate, MemberID, ProductID, Quantity, Amount)
        SELECT 
            SE.[EventDate],
            SE.[EventTypeCode],
            SE.[CCID],
            1,
            SE.[AmountCharged]
        FROM [GymSourceDataOLTP].[dbo].[SpecialEvents] SE
        LEFT JOIN [FITWorldGym].[dbo].[FactTransactions] FT ON 
            FT.MemberID = SE.[EventTypeCode] AND 
            FT.ProductID = SE.[CCID] AND 
            FT.TransactionDate = SE.[EventDate]
        WHERE FT.TransactionID IS NULL;

        SET @RowCount = @RowCount + @@ROWCOUNT;
        
        COMMIT TRANSACTION;

        -- Print result
        IF @RowCount > 0
            PRINT CAST(@RowCount AS NVARCHAR) + ' records were added to the FactTransactions table.'
        ELSE
            PRINT 'The FactTransactions table is up to date. No new records were copied.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        PRINT 'Error occurred during FactTransactions loading: ' + ERROR_MESSAGE();
    END CATCH
END;