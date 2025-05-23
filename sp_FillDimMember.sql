USE [FITWorldGym]

GO

ALTER PROCEDURE sp_FillDimMember
AS
BEGIN
    DECLARE @RowCount INT = 0;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Miembros normales de la tabla Member
        INSERT INTO [FITWorldGym].[dbo].[DimMember] (MemberID, MemberName, MemberZip, MembershipDate, CategID)
        SELECT 
            M.[MembID],
            M.[MemName],
            M.[MemZip],
            M.[MsDatePayed],
            M.[MshpID]
        FROM [GymSourceDataOLTP].[dbo].[Member] M
        LEFT JOIN [FITWorldGym].[dbo].[DimMember] DM ON DM.[MemberID] = M.[MembID]
        WHERE DM.[MemberID] IS NULL;

        SET @RowCount = @@ROWCOUNT;
        
        -- 2. Miembros de OneDayGuestPass que no estén ya en DimMember
        INSERT INTO [FITWorldGym].[dbo].[DimMember] (MemberID, MemberName, MemberZip, MembershipDate, CategID)
        SELECT 
            ODP.[MembID],
            'Guest Pass User', -- Nombre genérico
            '',
            ODP.[PassDate],
            ODP.[PassCatID]
        FROM [GymSourceDataOLTP].[dbo].[OneDayGuestPass] ODP
        LEFT JOIN [FITWorldGym].[dbo].[DimMember] DM ON DM.[MemberID] = ODP.[MembID]
        WHERE DM.[MemberID] IS NULL;

        SET @RowCount = @RowCount + @@ROWCOUNT;
        
        -- 3. Miembros de SalesTransaction que no estén ya en DimMember
        INSERT INTO [FITWorldGym].[dbo].[DimMember] (MemberID, MemberName, MemberZip, MembershipDate, CategID)
        SELECT 
            ST.[MembID],
            'Sales Customer', -- Nombre genérico
            '',
            ST.[StrDate],
            'SALES'
        FROM [GymSourceDataOLTP].[dbo].[SalesTransaction] ST
        LEFT JOIN [FITWorldGym].[dbo].[DimMember] DM ON DM.[MemberID] = ST.[MembID]
        WHERE DM.[MemberID] IS NULL;

        SET @RowCount = @RowCount + @@ROWCOUNT;
        
        -- 4. EventTypeCode como miembros para SpecialEvents
        INSERT INTO [FITWorldGym].[dbo].[DimMember] (MemberID, MemberName, MemberZip, MembershipDate, CategID)
        SELECT 
            SE.[EventTypeCode],
            'Event: ' + SE.[EventType], -- Prefijo para claridad
            '',
            SE.[EventDate],
            'EVENT'
        FROM [GymSourceDataOLTP].[dbo].[SpecialEvents] SE
        LEFT JOIN [FITWorldGym].[dbo].[DimMember] DM ON DM.[MemberID] = SE.[EventTypeCode]
        WHERE DM.[MemberID] IS NULL;

        SET @RowCount = @RowCount + @@ROWCOUNT;
        
        -- 5. Garantizar que L-A y L-H siempre estén en DimMember (por precaución)
        IF NOT EXISTS (SELECT 1 FROM [FITWorldGym].[dbo].[DimMember] WHERE MemberID = 'L-A')
        BEGIN
            INSERT INTO [FITWorldGym].[dbo].[DimMember] (MemberID, MemberName, MemberZip, MembershipDate, CategID)
            VALUES ('L-A', 'Lease A', '', GETDATE(), 'EVENT');
            SET @RowCount = @RowCount + 1;
        END
        
        IF NOT EXISTS (SELECT 1 FROM [FITWorldGym].[dbo].[DimMember] WHERE MemberID = 'L-H')
        BEGIN
            INSERT INTO [FITWorldGym].[dbo].[DimMember] (MemberID, MemberName, MemberZip, MembershipDate, CategID)
            VALUES ('L-H', 'Lease H', '', GETDATE(), 'EVENT');
            SET @RowCount = @RowCount + 1;
        END

        COMMIT TRANSACTION;

        -- Print result
        IF @RowCount > 0
            PRINT CAST(@RowCount AS NVARCHAR) + ' records were added to the DimMember table.'
        ELSE
            PRINT 'The DimMember table is up to date. No new records were copied.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        PRINT 'Error occurred during DimMember loading: ' + ERROR_MESSAGE();
    END CATCH
END;