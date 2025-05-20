## Troubleshooting Common Issues

### Foreign Key Constraints
If you encounter foreign key constraint errors during fact table loading, ensure:
1. Dimension tables are fully loaded before the fact table
2. Special member IDs (like event codes) are properly included in DimMember
3. All product codes exist in DimProduct

### Missing Members
Some member IDs might come from unexpected sources. The updated ETL process handles:
- Regular members from the Member table
- One-day guest pass users
- Sales transaction customers
- Special event type codes used as member references

### Data Integrity Verification
Use these queries to verify data integrity:
 sql
-- Verify all members referenced in transactions exist in DimMember
SELECT DISTINCT FT.MemberID 
FROM FactTransactions FT
LEFT JOIN DimMember DM ON FT.MemberID = DM.MemberID
WHERE DM.MemberID IS NULL;

-- Verify all products referenced in transactions exist in DimProduct
SELECT DISTINCT FT.ProductID 
FROM FactTransactions FT
LEFT JOIN DimProduct DP ON FT.ProductID = DP.ProductID
WHERE DP.ProductID IS NULL;
 # FIT-WORLD GYM ETL & Data Warehouse Project

## Project Overview

This project implements a complete ETL (Extract, Transform, Load) process and data warehouse solution for FIT-WORLD GYM INC. to analyze their revenue across different business segments. The solution follows a star schema design pattern and includes OLTP to OLAP data transformation, ETL procedures through SQL Server, and analytical queries to support business intelligence and reporting.

## Project Structure

The project consists of the following components:

1. **Source Database (OLTP)**: GymSourceDataOLTP
   - Contains operational tables for the gym business
   - Includes data about members, memberships, merchandise, guest passes, and special events

2. **Data Warehouse (OLAP)**: FITWorldGym
   - Star schema implementation with dimension and fact tables
   - Optimized for revenue analysis and reporting

3. **ETL Procedures**:
   - Stored procedures for data extraction, transformation, and loading
   - Handles incremental data loads and data integrity

4. **Analysis Queries**:
   - SQL queries for revenue analysis by category and totals
   - Support for Power BI dashboard integration

## Star Schema Design

The data warehouse follows a star schema design with:

### Dimension Tables
- **DimMember**: Contains member information including IDs, names, zip codes, and membership dates
- **DimProduct**: Contains product information categorized by product type (Membership, Merchandise, Events, OneDayPass)

### Fact Table
- **FactTransactions**: Contains transaction data with foreign keys to dimension tables and measures for quantity and amount

## ETL Process

The ETL process is implemented using SQL Server stored procedures with comprehensive error handling and transaction management:

1. **sp_FillDimMember**: 
   - Populates the DimMember dimension table from multiple source tables
   - Handles special cases of member IDs used in various transactions
   - Ensures complete referential integrity across all data sources
   - Includes special handling for event codes that appear as members

2. **sp_FillDimProduct**: 
   - Populates the DimProduct dimension table from multiple source tables
   - Categorizes products by type (Membership, Merchandise, Events, OneDayPass)
   - Uses efficient LEFT JOIN with NULL checks for deduplication

3. **sp_FillFactTransactions**: 
   - Populates the FactTransactions fact table from various transaction sources
   - Maintains transactional integrity with proper error handling
   - Uses LEFT JOIN patterns for efficient duplicate detection

These procedures include robust error handling with TRY-CATCH blocks, proper transaction management, and comprehensive data integrity checks to ensure reliable ETL operations.

## Analysis Capabilities

The data warehouse enables revenue analysis across different business segments:

1. Revenue by Category:
   - Membership revenue
   - Merchandise sales
   - Event revenue
   - One-day guest pass revenue

2. Total Revenue Analysis:
   - Calculation of overall business performance
   - Trend analysis over time (when time dimension is extended)

## Power BI Integration

The project includes Power BI dashboard files for visual analytics:
- TotalRevenue.pbix: Using Excel source as data connection
- TotalRevenueFromSSQL.pbix: Using direct connection to SQL Server

## Technical Implementation

- **Database**: SQL Server (T-SQL)
- **ETL**: SQL Server stored procedures with error handling and transaction management
- **Visualization**: Power BI
- **Data Modeling**: Star Schema with proper dimension and fact table relationships
- **Error Handling**: TRY-CATCH blocks with transaction rollback capabilities
- **Deduplication**: Efficient LEFT JOIN patterns with NULL checks

## Usage Instructions

1. Restore the GymSourceDataOLTP database from the provided .bak file
2. Execute the schema creation scripts for the FITWorldGym data warehouse
3. Run the ETL procedures in the following order:
    sql
   EXEC sp_FillDimMember;
   EXEC sp_FillDimProduct;
   EXEC sp_FillFactTransactions;
    
4. Execute the analytical queries to verify data
5. Open the Power BI dashboard to visualize the results

### Data Reset Process

If you need to reset the data warehouse and reload it from scratch:

 sql
USE [FITWorldGym]
GO

-- Temporarily disable foreign key constraints
ALTER TABLE [dbo].[FactTransactions] NOCHECK CONSTRAINT ALL;

-- Clear tables in proper order (fact table first, then dimensions)
DELETE FROM [dbo].[FactTransactions];
DELETE FROM [dbo].[DimMember];
DELETE FROM [dbo].[DimProduct];

-- Reset identity columns if needed
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE OBJECT_NAME(object_id) = 'FactTransactions')
BEGIN
    DBCC CHECKIDENT ('[dbo].[FactTransactions]', RESEED, 0);
END

-- Re-enable foreign key constraints
ALTER TABLE [dbo].[FactTransactions] CHECK CONSTRAINT ALL;

-- Reload data warehouse
EXEC sp_FillDimMember;
EXEC sp_FillDimProduct;
EXEC sp_FillFactTransactions;
 

## Query Examples

### Revenue by Category
 sql
SELECT 
    SUM(f.amount) AS Revenue,
    p.ProductType AS Category  
FROM FactTransactions f 
JOIN DimProduct p ON f.ProductID = p.ProductID
GROUP BY p.ProductType;
 

### Total Revenue
 sql
WITH CTE_Revenue AS (
    SELECT 
        SUM(f.amount) AS Revenue, 
        p.ProductType AS Category 
    FROM FactTransactions f 
    JOIN DimProduct p ON f.ProductID = p.ProductID
    GROUP BY p.ProductType
)

SELECT SUM(Revenue) AS TotalRevenue
FROM CTE_Revenue;
 

## Deliverables

- SQL Server database backup file (.bak)
- SQL scripts for data warehouse schema and ETL procedures (.sql)
- Power BI dashboard files (.pbix)
- Documentation (this README)

## Project Extensions

Potential enhancements for future versions:

- **Enhanced Time Dimension**: Add a dedicated time dimension table for temporal analysis
- **Geographical Analysis**: Implement geographical dimensions based on member zip codes
- **Incremental Loading**: Add change tracking for more efficient incremental loads
- **Enhanced Member Dimension**: Add SCD (Slowly Changing Dimension) Type 2 for member attribute changes
- **Advanced Analytics**: Create calculated measures for retention rates and customer lifetime value
- **ETL Monitoring**: Add logging and monitoring capabilities to the ETL process
- **Data Quality Dashboard**: Implement data quality checks and visualizations
- **Automated Scheduling**: Create SQL Server Agent jobs for automated ETL runs

---

*This project was developed as part of the City of Miami Beach Data Analytics and Visualization Exercise.*