/*
--Para consultar todos los registros de la source DB
SELECT * FROM Member
SELECT * FROM Membership
SELECT * FROM Merchandise
SELECT * FROM OneDayGuestPass
SELECT * FROM OneDayPassCategory
SELECT * FROM SalesTransaction
SELECT * FROM SoldVia
SELECT * FROM SpecialEvents
*/

--*************************************************************************************************************
--*************************************************************************************************************
--DW file: FITWorldGym.bak

--Part 1
--2.
--Queries for GymSourceDataOLTP

USE GymSourceDataOLTP
GO

--Revenue: OneDayPass

SELECT
    SUM(c.Price) as TotalRevenue
FROM
    [dbo].[OneDayGuestPass] as g
JOIN
    [dbo].[OneDayPassCategory] as c
ON
    g.PassCatID = c.PassCatID;

--*************
--Revenue: Membership
SELECT 
    SUM(TotalRevenueForType) AS MemberShipRevenue
FROM 
(
    SELECT 
        COUNT(mem.MembID) * m.MshpPrice AS TotalRevenueForType
    FROM [dbo].[Member] mem
    JOIN [dbo].[Membership] m ON mem.MshpID = m.MshpID
    GROUP BY m.MshpPrice
) AS Subquery;

--**************
--Revenue: Merchandise
SELECT SUM(MrchPrice * Quantity) as MerchandiseRevenue  FROM dbo.Merchandise m JOIN dbo.SoldVia sv ON m.MrchID = sv.MrchID

--**************
--Revenue: Events
SELECT SUM(AmountCharged) as EventRevenue FROM dbo.SpecialEvents



--******************************************************************************************
--Revenue por las Categorias

SELECT
    SUM(c.Price) as Revenue,
    'OneDayPass' as Category
FROM
    [dbo].[OneDayGuestPass] as g
JOIN
    [dbo].[OneDayPassCategory] as c
ON
    g.PassCatID = c.PassCatID
UNION ALL

-- Revenue: Membership
SELECT 
    SUM(TotalRevenueForType) AS Revenue,
    'Membership' as Category
FROM 
(
    SELECT 
        COUNT(mem.MembID) * m.MshpPrice AS TotalRevenueForType
    FROM [dbo].[Member] mem
    JOIN [dbo].[Membership] m ON mem.MshpID = m.MshpID
    GROUP BY m.MshpPrice
) AS Subquery
UNION ALL

-- Revenue: Merchandise
SELECT 
    SUM(MrchPrice * Quantity) as Revenue, 
    'Merchandise' as Category
FROM 
    dbo.Merchandise m 
JOIN 
    dbo.SoldVia sv ON m.MrchID = sv.MrchID
UNION ALL

-- Revenue: Events
SELECT 
    SUM(AmountCharged) as Revenue, 
    'Events' as Category
FROM 
    dbo.SpecialEvents;

/*
Revenue	Category
43.00	OneDayPass
1600.00	Membership
65.00	Merchandise
5700.00	Events
*/
--*************************************************************

--TotalRevenue
SELECT SUM(Revenue) as TotalRevenue 
FROM 
(
    -- Revenue: OneDayPass
    SELECT
        SUM(c.Price) as Revenue
    FROM
        [dbo].[OneDayGuestPass] as g
    JOIN
        [dbo].[OneDayPassCategory] as c
    ON
        g.PassCatID = c.PassCatID
    UNION ALL

    -- Revenue: Membership
    SELECT 
        SUM(TotalRevenueForType) AS Revenue
    FROM 
    (
        SELECT 
            COUNT(mem.MembID) * m.MshpPrice AS TotalRevenueForType
        FROM [dbo].[Member] mem
        JOIN [dbo].[Membership] m ON mem.MshpID = m.MshpID
        GROUP BY m.MshpPrice
    ) AS Subquery
    UNION ALL

    -- Revenue: Merchandise
    SELECT 
        SUM(MrchPrice * Quantity) as Revenue
    FROM 
        dbo.Merchandise m 
    JOIN 
        dbo.SoldVia sv ON m.MrchID = sv.MrchID
    UNION ALL

    -- Revenue: Events
    SELECT 
        SUM(AmountCharged) as Revenue
    FROM 
        dbo.SpecialEvents
) AS AllRevenues;

/*
TotalRevenue
7408.00
*/

--*******************************************************************************************************************************
--*******************************************************************************************************************************
--Part 2:
--3. Image Part 2_3.jpg


--*******************************************************************************************************************************
--*******************************************************************************************************************************
--*******************************************************************************************************************************
--*******************************************************************************************************************************
--Part 3:
--4. Implement star schema ...
--Creando la Estructura de la BD Destino


USE [FITWorldGym]
GO
/****** Object:  Table [dbo].[DimMember]    Script Date: 10/22/2023 9:29:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimMember](
	[MemberID] [varchar](50) NOT NULL,
	[MemberName] [varchar](50) NULL,
	[MemberZip] [varchar](50) NULL,
	[MembershipDate] [date] NULL,
	[CategID] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[MemberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimProduct]    Script Date: 10/22/2023 9:29:21 AM ******/
USE [FITWorldGym]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimProduct](
	[ProductID] [varchar](50) NOT NULL,
	[ProductName] [varchar](50) NULL,
	[ProductPrice] [money] NULL,
	[ProductType] [varchar](50) NULL,
	[NameLocation] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FactTransactions]    Script Date: 10/22/2023 9:29:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactTransactions](
	[TransactionID] [int] IDENTITY(1,1) NOT NULL,
	[TransactionDate] [date] NOT NULL,
	[MemberID] [varchar](50) NOT NULL,
	[ProductID] [varchar](50) NOT NULL,
	[Quantity] [int] NOT NULL,
	[Amount] [decimal](10, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO



--****************************************************************************************
--****************************************************************************************


select * from DimMember
SELECT * FROM DimProduct;
select * from FactTransactions

--****************************************************************************************
--****************************************************************************************

USE [FITWorldGym]
GO

CREATE PROCEDURE sp_FillDimMember
AS
BEGIN
    DECLARE @RowCount INT;

    -- Establecer el contexto de la transacción para la inserción en OLAP
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;

    -- Insertar en DimMember desde Member donde el MembID no exista en DimMember
    INSERT INTO [FITWorldGym].[dbo].[DimMember] (MemberID, MemberName, MemberZip, MembershipDate, CategID)
    SELECT 
        M.[MembID],
        M.[MemName],
        M.[MemZip],
        M.[MsDatePayed],
        M.[MshpID]
    FROM [GymSourceDataOLTP].[dbo].[Member] M
    WHERE NOT EXISTS (
        SELECT 1
        FROM [FITWorldGym].[dbo].[DimMember] DM
        WHERE DM.[MemberID] = M.[MembID]
    );

    SET @RowCount = @@ROWCOUNT;

    COMMIT TRANSACTION;

    -- Print result
    IF @RowCount > 0
        PRINT CAST(@RowCount AS NVARCHAR) + ' records were added to the DimMember table.'
    ELSE
        PRINT 'The DimMember table is up to date. No new records were copied.';

END;


--*********************************************************
USE [FITWorldGym]
GO

CREATE PROCEDURE sp_FillDimProduct
AS
BEGIN
    DECLARE @RowCount INT;

    -- Merchandise Table
    INSERT INTO [FITWorldGym].[dbo].[DimProduct] (ProductID, ProductName, ProductPrice, ProductType, NameLocation)
    SELECT MrchID, MrchName, MrchPrice, 'Merchandise', ''
    FROM [GymSourceDataOLTP].[dbo].[Merchandise]
    WHERE MrchID NOT IN (SELECT ProductID FROM [FITWorldGym].[dbo].[DimProduct]);

    SET @RowCount = @@ROWCOUNT;

    -- SpecialEvents Table
    INSERT INTO [FITWorldGym].[dbo].[DimProduct] (ProductID, ProductName, ProductPrice, ProductType, NameLocation)
    SELECT CCID, EventType, AmountCharged, 'Event', CCNameLocation
    FROM [GymSourceDataOLTP].[dbo].[SpecialEvents]
    WHERE CCID NOT IN (SELECT ProductID FROM [FITWorldGym].[dbo].[DimProduct]);

    SET @RowCount = @RowCount + @@ROWCOUNT;

    -- MemberShip Table
    INSERT INTO [FITWorldGym].[dbo].[DimProduct] (ProductID, ProductName, ProductPrice, ProductType, NameLocation)
    SELECT MshpID, MshpName, MshpPrice, 'Membership', ''
    FROM [GymSourceDataOLTP].[dbo].[Membership]
    WHERE MshpID NOT IN (SELECT ProductID FROM [FITWorldGym].[dbo].[DimProduct]);

    SET @RowCount = @RowCount + @@ROWCOUNT;

    -- OneDayPassCategory Table
    INSERT INTO [FITWorldGym].[dbo].[DimProduct] (ProductID, ProductName, ProductPrice, ProductType, NameLocation)
    SELECT PassCatID, CatName, Price, 'OneDayPass', ''
    FROM [GymSourceDataOLTP].[dbo].[OneDayPassCategory]
    WHERE PassCatID NOT IN (SELECT ProductID FROM [FITWorldGym].[dbo].[DimProduct]);

    SET @RowCount = @RowCount + @@ROWCOUNT;

    -- Print result
    IF @RowCount > 0
        PRINT CAST(@RowCount AS NVARCHAR) + ' records were added to the DimProduct table.'
    ELSE
        PRINT 'The DimProduct table is up to date. No new records were copied.';

END;

--**************************************************************
USE [FITWorldGym]
GO

CREATE PROCEDURE sp_FillFactTransactions
AS
BEGIN
    DECLARE @RowCount INT = 0;
    DECLARE @MaxDate DATE;
    SELECT @MaxDate = MAX(TransactionDate) FROM [FITWorldGym].[dbo].[FactTransactions];
    IF @MaxDate IS NULL
        SET @MaxDate = '1900-01-01';

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
    WHERE M.[MsDatePayed] > @MaxDate;

    SET @RowCount = @RowCount + @@ROWCOUNT;

    -- ... (Same for the other tables)

    -- Print result
    IF @RowCount > 0
        PRINT CAST(@RowCount AS NVARCHAR) + ' records were added to the FactTransactions table.'
    ELSE
        PRINT 'The FactTransactions table is up to date. No new records were copied.';

END;


USE [FITWorldGym]
GO
EXEC sp_FillDimMember;
EXEC sp_FillDimProduct;
EXEC sp_FillFactTransactions;

--OKOK

--********************************************************************************************************************************
--********************************************************************************************************************************
--Parte3:
--5. Queries for FITWorldGym

USE [FITWorldGym]
GO

/*
select * from DimMember
SELECT * FROM DimProduct;
select * from FactTransactions
*/
--Revenue by Category(Product)
select sum(f.amount) as Revenue,p.ProductType as Category  from FactTransactions f join DimProduct p on f.ProductID=p.ProductID
group by p.ProductType

/*
Revenue	Category
5700.00	Event
1600.00	Membership
65.00	Merchandise
43.00	OneDayPass
*/

--Total Revenue
select sum(Revenue) as TotalRevenue 
from(
select sum(f.amount) as Revenue,p.ProductType as Category  from FactTransactions f join DimProduct p on f.ProductID=p.ProductID
group by p.ProductType
) t;

/*
TotalRevenue
7408.00
*/

WITH CTE_Revenue AS (
    select sum(f.amount) as Revenue, p.ProductType as Category 
    from FactTransactions f 
    join DimProduct p on f.ProductID = p.ProductID
    group by p.ProductType
)

SELECT sum(Revenue) as TotalRevenue
FROM CTE_Revenue;

/*
TotalRevenue
7408.00
*/



--*************************************************************************************************************
--*************************************************************************************************************
--*************************************************************************************************************
--*************************************************************************************************************
--*************************************************************************************************************
--Part 4:
--6. Is not necessary considering that We can use Power Bi 
--Part 5: 
--7.  See project:
--TotalRevenue.pbix using Excel source just to show results in case that We can't connect directly to SServer
--TotalRevenueFromSSQL.pbix using Direct connection de SQL Server

--Se entregaron los ficheros a Antonio 930pm



--**********************************************************************************************************************************
--**********************************************************************************************************************************
--**********************************************************************************************************************************
--10Pm 
--Se detecto un issue con la clave en FacTransactions y para agregar los valores hay que aumentar los chequeos en 3 campos, TransactionDate
--MemberID y ProductID
--Teniendo en cuenta las definiciones de tabla que proporcionaste, crearé el procedimiento almacenado sp_FillFactTransactions que insertará 
--datos en la tabla FactTransactions desde las diversas tablas de la base de datos OLTP.
--El procedimiento verificará la fecha máxima (TransactionDate) para combinaciones específicas de ProductID y MemberID y solo insertará 
--registros que tengan una TransactionDate superior a esa fecha máxima para esa combinación específica.

--Aquí está el procedimiento modificado:
USE [FITWorldGym]
GO

CREATE PROCEDURE sp_FillFactTransactions
AS
BEGIN
    DECLARE @RowCount INT = 0;

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
    WHERE M.[MsDatePayed] > 
    (
        SELECT ISNULL(MAX(FT.TransactionDate), '1900-01-01')
        FROM [FITWorldGym].[dbo].[FactTransactions] FT
        WHERE FT.MemberID = M.[MembID] AND FT.ProductID = M.[MshpID]
    );

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
    WHERE ODP.[PassDate] > 
    (
        SELECT ISNULL(MAX(FT.TransactionDate), '1900-01-01')
        FROM [FITWorldGym].[dbo].[FactTransactions] FT
        WHERE FT.MemberID = ODP.[MembID] AND FT.ProductID = ODP.[PassCatID]
    );

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
    WHERE ST.[StrDate] > 
    (
        SELECT ISNULL(MAX(FT.TransactionDate), '1900-01-01')
        FROM [FITWorldGym].[dbo].[FactTransactions] FT
        WHERE FT.MemberID = ST.[MembID] AND FT.ProductID = SV.[MrchID]
    );

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
    WHERE SE.[EventDate] > 
    (
        SELECT ISNULL(MAX(FT.TransactionDate), '1900-01-01')
        FROM [FITWorldGym].[dbo].[FactTransactions] FT
        WHERE FT.MemberID = SE.[EventTypeCode] AND FT.ProductID = SE.[CCID]
    );

    SET @RowCount = @RowCount + @@ROWCOUNT;

    -- Print result
    IF @RowCount > 0
        PRINT CAST(@RowCount AS NVARCHAR) + ' records were added to the FactTransactions table.'
    ELSE
        PRINT 'The FactTransactions table is up to date. No new records were copied.';
END;

EXEC sp_FillFactTransactions;
--He agregado la lógica para las tablas OneDayGuestPass, Merchandise, y SpecialEvents al procedimiento. 
--Cada inserción verifica la fecha máxima de TransactionDate para la combinación específica de MemberID 
--y ProductID y solo inserta registros nuevos que superen esa fecha máxima.

--****************************************************************************************************************************
--****************************************************************************************************************************
--****************************************************************************************************************************
--****************************************************************************************************************************