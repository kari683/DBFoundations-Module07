--*************************************************************************--
-- Title: Assignment07
-- Author: KBrothers
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,KBrothers,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_KBrothers')
	 Begin 
	  Alter Database [Assignment07DB_KBrothers] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_KBrothers;
	 End
	Create Database Assignment07DB_KBrothers;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_KBrothers;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5 pts): What function can you use to show a list of Product names, 
-- and the price of each product, with the price formatted as US dollars?
-- Order the result by the product!

Select * From vProducts;
go

Create Function fProductPrice()
Returns Table
AS
Return(
Select Top 100000
      ProductName, 
	  Format(UnitPrice, 'C', 'en-US') AS 'UnitPrice' 
From vProducts
Order by ProductName);
go

Select * From fProductPrice();
go

-- Question 2 (10 pts): What function can you use to show a list of Category and Product names, 
-- and the price of each product, with the price formatted as US dollars?
-- Order the result by the Category and Product!

Select * From vCategories;
go
Select * From vProducts;
go

Create Function fCategoryProductPrice()
Returns Table
AS
Return(
Select Top 100000 
    CategoryName, 
	ProductName, 
	Format(UnitPrice, 'C', 'en-US') AS 'UnitPrice' 
From dbo.Categories Join dbo.Products
 On Categories.CategoryID = Products.CategoryID
 Order by CategoryName, ProductName);
go

Select * From fCategoryProductPrice();
go

-- Question 3 (10 pts): What function can you use to show a list of Product names, 
-- each Inventory Date, and the Inventory Count, with the date formatted like "January, 2017?" 
-- Order the results by the Product, Date, and Count!

Select * From vProducts;
go
Select * From vInventories;
go

Create Function fProductsInventoryDate()
Returns Table
AS
Return(
Select Top 100000000
       Products.ProductName, 
       [InventoryDate] = DateName(mm, InventoryDate) + ', ' + DateName(yy, InventoryDate), 
	   [InventoryCount] = Inventories.Count
From Products Join Inventories
 On Products.ProductID = Inventories.ProductID
 Order by ProductName, DatePart("Month", InventoryDate), dbo.Inventories.Count);

Select * From fProductsInventoryDate();
go


-- Question 4 (10 pts): How can you CREATE A VIEW called vProductInventories 
-- That shows a list of Product names, each Inventory Date, and the Inventory Count, 
-- with the date FORMATTED like January, 2017? Order the results by the Product, Date,
-- and Count!

Create View vProductInventories
AS
Select TOP 100000000000
       Products.ProductName, 
       [InventoryDate] = DateName(mm, InventoryDate) + ', ' + DateName(yy, InventoryDate), 
	   [InventoryCount] = Inventories.Count
From Products Join Inventories
 On Products.ProductID = Inventories.ProductID
Order by ProductName, DatePart("Month", InventoryDate), Count;
go

-- Check that it works: Select * From vProductInventories;
Select * From vProductInventories;
go

-- Question 5 (15 pts): How can you CREATE A VIEW called vCategoryInventories 
-- that shows a list of Category names, Inventory Dates, 
-- and a TOTAL Inventory Count BY CATEGORY, with the date FORMATTED like January, 2017?

Select * From vCategories;
go
Select * From vInventories;
go
Select * From vProducts;
go

Create View vCategoryInventories
AS
Select TOP 100000000000
       Categories.CategoryName, 
       [InventoryDate] = DateName(mm, InventoryDate) + ', ' + DateName(yy, InventoryDate), 
	   [InventoryCountByCategory] = Sum(Inventories.Count)
From Categories 
 Join Products
 On Categories.CategoryID = Products.CategoryID
 Join Inventories
 On Products.ProductID = Inventories.ProductID
Group by CategoryName, InventoryDate
Order by CategoryName;
go

-- Check that it works: Select * From vCategoryInventories;
Select * From vCategoryInventories;
go

-- Question 6 (10 pts): How can you CREATE ANOTHER VIEW called 
-- vProductInventoriesWithPreviouMonthCounts to show 
-- a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month
-- Count? Use a functions to set any null counts or 1996 counts to zero. Order the
-- results by the Product, Date, and Count. This new view must use your
-- vProductInventories view!

Select * From vInventories;
go
Select * From vProducts;
go
Select * From vProductInventories;
go

--Create Select statement and add columns

Select
       ProductName, 
       InventoryDate, 
	   InventoryCount
From vProductInventories;

-- Add new column PreviousMonthCount and add Lag function

Select
       ProductName, 
       InventoryDate, 
	   InventoryCount,
	   [PreviousMonthCount] = Lag(Sum(InventoryCount)) Over(Order By ProductName, Month(InventoryDate))
From vProductInventories
Group by ProductName, InventoryDate, InventoryCount
Order by ProductName, DatePart("Month", InventoryDate), InventoryCount;

-- Add IIF so January count is equal to 0 and make into a view

Create View vProductInventoriesWithPreviousMonthCounts
AS
Select TOP 100000000000
       ProductName, 
       InventoryDate, 
	   InventoryCount,
	   [PreviousMonthCount] = IIF(Month(InventoryDate) = 1,0 ,IsNull(Lag(Sum(InventoryCount)) Over(Order By ProductName, Month(InventoryDate)), 0))
From vProductInventories
Group by ProductName, InventoryDate, InventoryCount
Order by ProductName, DatePart("Month", InventoryDate), InventoryCount;
go

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15 pts): How can you CREATE one more VIEW 
-- called vProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month 
-- Count and a KPI that displays an increased count as 1, 
-- the same count as 0, and a decreased count as -1? Order the results by the Product, Date, and Count!

--Use previous view and add column QtyChangKPI

Create View vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
Select Top 1000000000
  ProductName,
  InventoryDate,
  InventoryCount,
  PreviousMonthCount,
  [QtyChangKPI] = Case
     When PreviousMonthCount > InventoryCount Then 1
	 When PreviousMonthCount = InventoryCount Then 0
	 When PreviousMonthCount < InventoryCount Then -1
	 End
From vProductInventoriesWithPreviousMonthCounts;
go

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25 pts): How can you CREATE a User Defined Function (UDF) 
-- called fProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month
-- Count and a KPI that displays an increased count as 1, the same count as 0, and a
-- decreased count as -1 AND the result can show only KPIs with a value of either 1, 0,
-- or -1? This new function must use you
-- ProductInventoriesWithPreviousMonthCountsWithKPIs view!

-- Include an Order By clause in the function using this code: 
-- Year(Cast(v1.InventoryDate as Date))
-- and note what effect it has on the results.

Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

--Use previous view to create function

Create Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs()
 Returns Table
 AS
 Return(
 Select ProductName, InventoryDate, InventoryCount, PreviousMonthCount, QtyChangKPI
 From dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs);
 go

 Select * from dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs();

 --Alter function and add variable for QtyChangKPI value

 Alter Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@QtyChangKPI int) 
 Returns Table
 AS
 Return(
 Select ProductName, InventoryDate, InventoryCount, PreviousMonthCount, QtyChangKPI
 From dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
 Where QtyChangKPI = @QtyChangKPI);
go

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/

Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
go

-- Alter function and add Order By clause so dates are in order

Alter Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@QtyChangKPI int) 
 Returns Table
 AS
 Return(
 Select Top 1000000
      ProductName, InventoryDate, InventoryCount, PreviousMonthCount, QtyChangKPI
 From dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
 Where QtyChangKPI = @QtyChangKPI
 Order by Year(Cast(InventoryDate as Date)));
 go

Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
go



/***************************************************************************************/