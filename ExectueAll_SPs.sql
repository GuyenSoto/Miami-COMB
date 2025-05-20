--******************************************
-- Clean all tables
--*******************************************
USE [FITWorldGym]
GO

-- 1. Identificar y desactivar todas las restricciones de clave foránea
DECLARE @sql NVARCHAR(MAX) = N'';

-- Generar comandos para desactivar todas las restricciones FK
SELECT @sql += N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) + 
               N' NOCHECK CONSTRAINT ' + QUOTENAME(name) + ';' + CHAR(13) + CHAR(10)
FROM sys.foreign_keys
WHERE OBJECT_SCHEMA_NAME(referenced_object_id) = 'dbo' 
  AND OBJECT_NAME(referenced_object_id) IN ('DimMember', 'DimProduct');

-- Ejecutar comandos para desactivar FKs
PRINT 'Desactivando restricciones de clave foránea...';
EXEC sp_executesql @sql;

-- 2. Limpiar tablas en el orden correcto
PRINT 'Limpiando tabla de hechos...';
DELETE FROM [dbo].[FactTransactions];
-- Si prefieres TRUNCATE y estás seguro de que las FKs se han desactivado correctamente:
-- TRUNCATE TABLE [dbo].[FactTransactions];

PRINT 'Limpiando tablas de dimensiones...';
DELETE FROM [dbo].[DimMember];
DELETE FROM [dbo].[DimProduct];
-- Si prefieres TRUNCATE:
-- TRUNCATE TABLE [dbo].[DimMember];
-- TRUNCATE TABLE [dbo].[DimProduct];

-- 3. Reiniciar los contadores IDENTITY si es necesario
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE OBJECT_NAME(object_id) = 'FactTransactions')
BEGIN
    PRINT 'Reiniciando contador IDENTITY de FactTransactions...';
    DBCC CHECKIDENT ('[dbo].[FactTransactions]', RESEED, 0);
END

-- 4. Volver a activar todas las restricciones de clave foránea
SET @sql = N'';

-- Generar comandos para reactivar las restricciones
SELECT @sql += N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) + 
               N' CHECK CONSTRAINT ' + QUOTENAME(name) + ';' + CHAR(13) + CHAR(10)
FROM sys.foreign_keys
WHERE OBJECT_SCHEMA_NAME(referenced_object_id) = 'dbo' 
  AND OBJECT_NAME(referenced_object_id) IN ('DimMember', 'DimProduct');

-- Ejecutar comandos para reactivar FKs
PRINT 'Reactivando restricciones de clave foránea...';
EXEC sp_executesql @sql;

PRINT 'Todas las tablas han sido limpiadas correctamente.';


--****************************************************************
-- See problems
--******************************************************************
-- Encuentra los MemberIDs que están en las fuentes pero no en DimMember
SELECT DISTINCT M.[MembID] 
FROM [GymSourceDataOLTP].[dbo].[Member] M
LEFT JOIN [FITWorldGym].[dbo].[DimMember] DM ON M.[MembID] = DM.[MemberID]
WHERE DM.[MemberID] IS NULL

UNION

SELECT DISTINCT ODP.[MembID]
FROM [GymSourceDataOLTP].[dbo].[OneDayGuestPass] ODP
LEFT JOIN [FITWorldGym].[dbo].[DimMember] DM ON ODP.[MembID] = DM.[MemberID]
WHERE DM.[MemberID] IS NULL

UNION

SELECT DISTINCT ST.[MembID]
FROM [GymSourceDataOLTP].[dbo].[SalesTransaction] ST
LEFT JOIN [FITWorldGym].[dbo].[DimMember] DM ON ST.[MembID] = DM.[MemberID]
WHERE DM.[MemberID] IS NULL

UNION

SELECT DISTINCT SE.[EventTypeCode]
FROM [GymSourceDataOLTP].[dbo].[SpecialEvents] SE
LEFT JOIN [FITWorldGym].[dbo].[DimMember] DM ON SE.[EventTypeCode] = DM.[MemberID]
WHERE DM.[MemberID] IS NULL;

--******************************************************************
-- Analicemos de dónde vienen estos IDs
--*****************************************************************

-- Buscar L-A y L-H en las tablas de origen
-- Member
SELECT 'Member' AS SourceTable, *
FROM [GymSourceDataOLTP].[dbo].[Member]
WHERE MembID IN ('L-A', 'L-H');

-- OneDayGuestPass
SELECT 'OneDayGuestPass' AS SourceTable, *
FROM [GymSourceDataOLTP].[dbo].[OneDayGuestPass]
WHERE MembID IN ('L-A', 'L-H');

-- SalesTransaction
SELECT 'SalesTransaction' AS SourceTable, *
FROM [GymSourceDataOLTP].[dbo].[SalesTransaction]
WHERE MembID IN ('L-A', 'L-H');

-- SpecialEvents (buscando en EventTypeCode)
SELECT 'SpecialEvents' AS SourceTable, *
FROM [GymSourceDataOLTP].[dbo].[SpecialEvents]
WHERE EventTypeCode IN ('L-A', 'L-H');





--******************************************************************
-- Insert en las tablas
--*******************************************************************
EXEC sp_FillDimMember;
EXEC sp_FillDimProduct;
EXEC sp_FillFactTransactions;