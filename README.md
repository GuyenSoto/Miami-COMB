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

The ETL process is implemented using SQL Server stored procedures:

1. **sp_FillDimMember**: Populates the DimMember dimension table
2. **sp_FillDimProduct**: Populates the DimProduct dimension table from multiple source tables
3. **sp_FillFactTransactions**: Populates the FactTransactions fact table from various transaction sources

These procedures handle data deduplication, transformation, and incremental loading to ensure data integrity and performance.

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
- **ETL**: SQL Server stored procedures
- **Visualization**: Power BI
- **Data Modeling**: Star Schema

## Usage Instructions

1. Restore the GymSourceDataOLTP database from the provided .bak file
2. Execute the schema creation scripts for the FITWorldGym data warehouse
3. Run the ETL procedures in the following order:
   ```sql
   EXEC sp_FillDimMember;
   EXEC sp_FillDimProduct;
   EXEC sp_FillFactTransactions;
   ```
4. Execute the analytical queries to verify data
5. Open the Power BI dashboard to visualize the results

## Query Examples

### Revenue by Category
```sql
SELECT 
    SUM(f.amount) AS Revenue,
    p.ProductType AS Category  
FROM FactTransactions f 
JOIN DimProduct p ON f.ProductID = p.ProductID
GROUP BY p.ProductType;
```

### Total Revenue
```sql
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
```

## Deliverables

- SQL Server database backup file (.bak)
- SQL scripts for data warehouse schema and ETL procedures (.sql)
- Power BI dashboard files (.pbix)
- Documentation (this README)

## Project Extensions

Future enhancements could include:
- Adding time dimension for temporal analysis
- Implementing geographical analysis based on member zip codes
- Creating additional measures for membership retention and growth
- Developing more advanced analytics with product and member segmentation

---

*This project was developed as part of the City of Miami Beach Data Analytics and Visualization Exercise.*