Use EShop

select * from Customer

--Get the top 2 most expensive orders
select top 2 * from Orders, Product
where Orders.ProductId = Product.Id
Order by Product.Cost desc

--Get all order Details grouped by status
select count(*), [status]
from Orders
group BY status

--group all products (total products count) by category

select * from Product

select count(*), [CategoryId] from Product
group by CategoryId

create view vw_GetProductCountByCategory as 
(select count(*) as [TotalProducts], ProductCategory.[Name] from Product, ProductCategory
where Product.CategoryId = ProductCategory.Id
group by ProductCategory.[Name]
Having ProductCategory.[Name] Like '%a%'
AND count(*) > 1)

SELECT  [TotalProducts]
      ,[Name]
  FROM [EShop].[dbo].[vw_GetProductCountByCategory]
  WHERE [Name] = 'Apparels','Jatre Clothes'

  CREATE Procedure sp_GetProductCountByCategory
  AS
  BEGIN
  select count(*) as [TotalProducts], ProductCategory.[Name] from Product, ProductCategory
  where Product.CategoryId = ProductCategory.Id
  group by ProductCategory.[Name]
  Having ProductCategory.[Name] Like '%a%'
  AND count(*) > 1
  Order by count(*), ProductCategory.[Name] desc
  END

  --EXECUTE STORED PROCEDURE
  Exec [dbo].[sp_GetProductCountByCategory]

  --Function : get the most expensive product
  Create function fn_GetMaxProductCost()
  Returns bigint
  AS
  BEGIN
  DECLARE @result bigint
  select @result =  Max(Cost) from Product
  return @result
  END

  Create function fn_GetMinProductCost()
  Returns bigint
  AS
  BEGIN
  DECLARE @result bigint
  select @result =  Min (Cost) from Product
  return @result
  END

  --Executing functions
  select [dbo].[fn_GetMaxProductCost]() as [Most Expensive],
         [dbo].[fn_GetMinProductCost]() as [Least Expensive]

--== Executing functions with normal table columns
select [dbo].[fn_GetMaxProductCost]() as [Most Expensive],
       [Name]
from Product
where [Cost] =  [dbo].[fn_GetMaxProductCost]()

select [dbo].[fn_GetMinProductCost]() as [Least Expensive],
       [Name]
from Product
where [Cost] =  [dbo].[fn_GetMinProductCost]()


--functions that returns a table
create function fn_SampleTable()
RETURNS TABLE
AS 
RETURN
(
    SELECT Product.[Name] as [ProductName], ProductCategory.[Name] as [CategoryName]
	from
	Product, ProductCategory
	where
	Product.CategoryId = ProductCategory.Id
)

-- executing  table for above query
select * from [dbo].[fn_SampleTable]() 

-- select from 2 tables - No where condition
select * from Orders, Customer -- cross join
where Orders.CustomerId IN Customer.Id


--working with joins with predefined keywords
-- INNER JOIN : Only common records
select * from Customer Inner Join Orders 
                     ON Orders.CustomerId= Customer.Id
where Customer.Name LIKE '%A%'

--== Left Outer join: ALL records of left and only matching records of right
select * from Customer LEFT OUTER JOIN Orders
                        ON Customer.Id = Orders.CustomerId

---====Right Outer join: All records of right and only matching records of left
select * from Customer RIGHT OUTER JOIN Orders
                        ON Customer.Id = Orders.CustomerId


--== Full Outer Join: all records of left + matching records of right &&
---------------------  all records of right + matching records of left 
--------------------- wherever match is not found Null is substituted
select * from Product Full OUTER JOIN Customer
                        ON Product.Id = Customer.Id

---=== CROSS JOIN : random permutation combination (product of records of both tables)
select * from Product CROSS JOIN Customer

---==inserting manually to product table

USE [EShop]
GO

INSERT INTO [dbo].[Product]
           ([Name]
           ,[Cost]
           ,[CategoryId])
     VALUES
         ('Dummy', 500, 11)


INSERT INTO [dbo].[Product]
           ([Name]
           ,[Cost]
           ,[CategoryId])
     VALUES
         ('Summy', 400, 11)


INSERT INTO [dbo].[Product]
           ([Name]
           ,[Cost]
           ,[CategoryId])
     VALUES
         ('Funny', 500, 11)
GO
select * from audit


-- add customer then automatically add a dummy order
USE [EShop]
GO

Alter Procedure sp_InsertNewCustomer(@Name NVARCHAR(50), @Email NVARCHAR(50))
AS
BEGIN TRANSACTION T1
INSERT INTO [dbo].[Customer]
           ([Name]
           ,[Email])
     VALUES
           (@Name, @Email)
		    
IF @@ERROR <> 0
ROLLBACK TRANSACTION T1

DECLARE @Cid INT
SET @Cid = @@Identity

INSERT INTO [dbo].[Orders]
           ([Status]
           ,[OrderDate]
           ,[ProductId]
           ,[CustomerId])
     VALUES
           ('In-Progress', GetDate(),1007, @Cid)
		   IF @@ERROR <> 0
           ROLLBACK TRANSACTION T1

 COMMIT TRANSACTION T1
END

--EXECUTE ABOVE PROCEDURE
exec [dbo].[sp_InsertNewCustomer] 'Sharu', 'sharu@gmail.com'

select top 1 * from Customer order by id desc
select top 1 * from Orders order by OrderId desc

select * from Product where [Name] = 'Funny'
delete Product where [Name] = 'Funny'

select * from Product where [Name] = 'Summy'
update Product
Set Product.[Name] = 'Jhoomer'
where Product.[Name] = 'Summy'

select * from Product where [Name] = 'Summy'
UPDATE [dbo].[Product]
   SET [Name] = 'Jhoomer'
      ,[Cost] = 15000
      ,[CategoryId] = 11
 WHERE Product.[Name] = 'Summy'
GO

-- in case of dependent tables. right- click on tables -> View Dependencies
--Delete the data first from the dependant table
-- then continue to delete data from your desired table
delete Orders where ProductId IN (select Id from Product
                                    where Product.CategoryId = 11)

delete Product where CategoryId = 11

delete ProductCategory
where [Name] = 'Lights'

select * from Product
