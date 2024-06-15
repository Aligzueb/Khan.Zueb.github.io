--- Sales Domain Analysis
-----Toy Store analysis
----- There are four files
----Sales, Products, Stores, Inventory

----Create a database with Toy_store_sales_DB
create database toy_store_sales_DB;
use Toy_store_sales_DB;

---next step is--
--- will create the container table(truncated table)
create table sales
(Sales_ID varchar(max), Date varchar(max), store_ID varchar(max), Product_ID varchar(max), Units varchar(max));


select column_name, data_type
from INFORMATION_SCHEMA.columns
---close your sales .csv if it is open
--- will use Bulk insert to import the data into our container

bulk insert sales
from /* path of the file*/ 'E:\LearnBay\SQL\SQL Project\sales.csv'
with
    (fieldterminator=',',
	rowterminator ='\n',
	firstrow=2,
	maxerrors=20);

	truncate table products
	select * from products

---create table for product table
create table products
 (Product_ID varchar(max), Product_name varchar(max), Product_Category varchar(max), Product_cost varchar(max), Product_Price varchar(max));

bulk insert products
from /* path of the file*/ 'E:\LearnBay\SQL\SQL Project\products.csv'
with
    (fieldterminator=',',
	rowterminator ='\n',
	firstrow=2,
	maxerrors=20);

---- create stores table
create table stores
 (Store_ID varchar(max), Store_Name varchar(max), Store_City varchar(max), Store_Location varchar(max), Store_Open_Date varchar(max));

bulk insert stores
from /* path of the file*/ 'E:\LearnBay\SQL\SQL Project\stores.csv'
with
    (fieldterminator=',',
	rowterminator ='\n',
	firstrow=2,
	maxerrors=20);

--create table Inventory

create table inventory
 (Store_ID varchar(max), Product_ID varchar(max), Stock_On_Hand varchar(max));

bulk insert inventory
from /* path of the file*/ 'E:\LearnBay\SQL\SQL Project\inventory.csv'
with
    (fieldterminator=',',
	rowterminator ='\n',
	firstrow=2,
	maxerrors=20);



-----let's see the data
select * from Products;
select * from Sales;
select * from Inventory;
select * from stores;

select column_name,data_type
from INFORMATION_SCHEMA.columns
where table_name='Sales'

select * from sales

--- Now we have all the tables here
-- next step we'll check the data inconsistency before validate it..

--let's check the sales_id distinct values

select count(distinct sales_id) from sales;

--- we'll try to convert the datatype

alter table sales
alter column sales_id int

--- we have found that we have some non numeric values in our sales_id column
-- to check the non numeric values in a numeric column

 select * from sales
where isnumeric(sales_id)=0   /* this will check the non numeric values (means any alphanumeric or characters or symbols on it)*/

--- How to remove the anamolies from here..
-- think of it, if we have more than 20000 values like this
--- S0001, s%0001, S-10001
--- we can try some character function or logics , where we can assign this task to SQL

select sales_id, replace(sales_id,substring(sales_id,patindex('%[^0-9]%',Sales_id),1),''),
substring(sales_id,patindex('%[^0-9]%',Sales_id),1),patindex('%[^0-9]%',Sales_id) from sales
where isnumeric(sales_id)=0


--- Always updating the value try with the query

update sales set sales_id=replace(Sales_ID,substring(sales_id,patindex('%[^0-9]%',Sales_id),1),'')
where isnumeric(sales_id)=0

alter table sales
alter column sales_id int

--- change the datatype of 'Date' field to date from varchar

alter table sales
alter column [date] int

-- let's check the anamolies in the date column

select date from sales
where isdate(date)=0    -- this is to check the non date formats

select date from sales

-- we'll try to use Try and get method
--- we are using try_convert function 
--- try_convert is similar to convert function but where we have any conversion error it replace with 'Null' values

select sales_id,date, convert(varchar(20),try_convert(date, [date]),23) from sales
where convert(varchar(20),try_convert(date, [date]),23) is null

---- try using this and update the anamoly with the correct date

-- 4/2022/01,, new_value- 01/04/2022

 update sales set date= '01/04/2020'
 where convert(varchar(20),try_convert(date, [date]),23) is null

 alter table sales
 alter column Date date

 alter table sales
 alter column store_ID int

 alter table sales
 alter column product_ID int

 alter table sales
 alter column Units int

 select * from sales
 where ISNUMERIC (units)=0

 update sales set units= case when units='1A' then 1
                             when units='10%' then 10 
							 else units end  

 alter table sales
 alter column Units int

 ---Now change the datatype in products table


 select column_name,data_type
from INFORMATION_SCHEMA.columns
where table_name='Products'

select * from Products

select Product_ID from products
where isnumeric(Product_ID)=0

alter table Products
alter column Product_ID int

update products set product_cost= replace(product_cost, '$', '') 

alter table products 
alter column product_cost decimal (5,2)

update products set Product_price= replace(Product_price, '$', '') 

alter table products 
alter column product_price decimal (5,2)


---Change the datatype in stores table

select column_name,data_type
from INFORMATION_SCHEMA.columns
where table_name='stores'

select * from stores

alter table stores
alter column Store_ID int

 alter table stores
 alter column Store_Open_Date date

 select Store_Open_Date from stores
 where isdate(Store_Open_Date)=0

 select store_open_date, convert(varchar(20),try_convert(date,store_open_date,105),23) from stores

 update stores set store_open_date=convert(varchar(20),try_convert(date,store_open_date,105),23)

 alter table stores
 alter column Store_Open_Date date

 ----change the datatype in Inventory table


 select column_name,data_type
from INFORMATION_SCHEMA.columns
where table_name='inventory'

select * from inventory

alter table inventory
alter column store_id int

alter table inventory
alter column product_id int

alter table inventory
alter column stock_on_hand int  

--- we have checked and transform the field consistency (datatype) in all four sheets------

--- we'll create a function to remove non numeric values from numeric column

drop function remnonnumeric
create function remnonnumeric (@instr as varchar(100))
returns varchar(100)
as
begin
		/* Declare some variables for the operational reason*/
		Declare @Ostr as varchar(100)=''
		Declare @length int=len(@instr)
		declare @index int=1

-- here we'll use the 'loop' (While)
		while @index <=@length
		begin
			if substring(@instr,@index,1) like '[0-9]'
			set @ostr=@ostr+ substring(@instr,@index,1)

			set @index=@index+1
		End

		return @Ostr
End

create table testing
(sale_id varchar(100), Product_id varchar(30))

truncate table testing
insert into testing
values('100*1', '100-00'),('1001', '1$00'),('100#1', '1!0000')

select * from testing

update testing set sale_id=dbo.remnonnumeric(sale_id)
update testing set Product_ID=dbo.remnonnumeric(Product_ID)

--- Check the duplicate records in sales Tables--

select * from sales
select distinct sales_id, date,store_id,product_id, units from sales



WITH duplicates AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY sales_id, date, store_id, product_id, units 
ORDER BY sales_id) AS row_num FROM sales)

SELECT * 
FROM duplicates
WHERE row_num > 1;

--There are no dulicates record in the sales table
 --find the dulicates record in Product table

 WITH duplicates AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY Product_ID, Product_Name, Product_category, Product_Cost, Product_Price 
ORDER BY Product_ID) AS row_num FROM Products)

select * from duplicates
where row_num>1

-- we have found three duplicate records (3 rows)

 -- removing the duplicates
 with duplicates as (select *, row_number() over(partition by product_id, 
product_name,Product_category, Product_cost, Product_price order by product_id) as row_num
from products)

Delete from duplicates
where row_num>1

--find the dulicates record in Stores table

with duplicates as (select *, row_number() over(partition by store_id, 
store_name,store_city, store_location, store_open_date order by store_id) as row_num
from stores)

select * from duplicates
where row_num>1

--There are no dulicates record in the sales table

 --find the dulicates record in Inventory table

 with duplicates as (select *, row_number() over(partition by Store_id, product_id, 
stock_on_hand order by store_id) as row_num
from inventory)

select * from duplicates
where row_num>1

--There are no dulicates record in the sales table

select column_name, data_type from information_schema.columns

--Now Add constraints in each field

-- sale_id in sales table are unique and data is available(no null value)

alter table sales
alter column sales_id int not null

alter table sales
add constraint pksid primary key(sales_id) 

select count(distinct product_id) from products

alter table products
alter column Product_id int not null

alter table products
add constraint pkpid primary key(product_id)

select count(distinct store_id) from stores

alter table stores
alter column store_id int not null

alter table stores
add constraint pkstrid primary key(store_id)

--- create a relation between the tables

alter table sales
add constraint fkstr foreign key(store_id) references stores(store_id)

alter table Inventory
add constraint fkprd2 foreign key(product_id) references products(product_id)

alter table sales
add constraint fkprd foreign key(product_id) references products(product_id)

-------Some error facing during creation relationship---***-----

---- Now Analysis sales trend over the time

select * from sales

-- we'll find out the date range for the sales

select min(date) as 'sales_start_date', max(date) as 'last_date_recorded', 
datediff(day,min(date),max(date)) as 'sales_period_in_days' from sales

--- to analyse the sales in various datepart

select year(date) as 'the_year', datepart(quarter,date) as 'quarterly_sales', datename(month,date) as 'the_month',sum(units) as 'total_un_sold'
from sales
group by year(date),datepart(quarter,date), datename(month,date)
order by year(date)

with comp_sales_table as(select  datename(month,date) as 'the_month',datepart(quarter,date) as 'quarterly_sales',
 sum(case when year(date)=2022 then units else 0 end) as 'total_un_sold2022',
 sum(case when year(date)=2023 then units else 0 end) as 'total_un_sold2023'
from sales
group by datename(month,date), datepart(quarter,date))

SELECT * 
FROM comp_sales_table
ORDER BY quarterly_sales, the_month;


select *,total_un_sold2023-total_un_sold2022 as 'diff_in_sales', case when total_un_sold2023-total_un_sold2022>0 then 'inclined_in_sales'
else 'declined_in_sales' end as sales_trend
from comp_sales_table
order by quarterly_sales
SELECT * 
FROM comp_sales_table
ORDER BY quarterly_sales, the_month;

select datename(weekday,date) as 'sales_week', sum(units) as 'total_unts' 
from sales
where format(date,'yyyy') in (2022,2023) and datename(weekday,date) in ('Sunday','Saturday')
group by datename(weekday,date)

union all
select datename(weekday,date) as 'sales_week', sum(units) as 'total_unts' 
from sales
where format(date,'yyyy') in (2022,2023) and datename(weekday,date) not  in ('Sunday','Saturday')
group by datename(weekday,date)
order by total_unts

--- stores sales performance analysis

select * from stores


select  store_location,count(distinct st.store_id),
 sum(s.units) as 'total_un_sold', sum(units*product_price) as 'Total_revenue'
from stores st
join sales s
on st.store_id=s.store_id
join products p
on s.product_id=p.product_id
group by store_location
order by total_revenue desc

--- top 5 stores in terms of revenue


select  TOP 5 store_location,count(distinct st.store_id),
 sum(s.units) as 'total_un_sold', sum(units*product_price) as 'Total_revenue'
from stores st
join sales s
on st.store_id=s.store_id
join products p
on s.product_id=p.product_id
group by store_location
order by total_revenue desc

-- analyse the Product category in respoct highly sold products

SELECT * FROM PRODUCTS

with product_analyse as (select Product_category,product_name, sum(case when year(date)=2022 then units else 0 end) as 'Total_un_sold2022', 
sum(case when year(date)=2023 then units else 0 end) as 'Total_un_sold2023',
sum(case when year(date)=2022 then units*product_price else 0 end) as 'Tot_rev_2022',
sum(case when year(date)=2023 then units*product_price else 0 end) as 'Tot_rev_2023'
from products p
join sales s
on p.product_id=s.product_id
group by product_category ,product_name)

select * , Total_un_sold2023-Total_un_sold2022 as 'diff_in_unitsold', Tot_rev_2023-Tot_rev_2022 as 'diff_in_revenue'
from product_analyse
order by diff_in_unitsold desc

-- Find out the highly sold product_name for each category 

with product_tab as(select product_category, product_name, sum(units) as 'total_un_sold'
from products p
join sales s
on p.product_id=s.product_id
group by product_category, product_name)

/*,ranked_products as (select *,row_number() over(partition by product_category order by total_un_sold)
 as 'rankd' from product_tab)*/
select *,row_number() over(partition by product_category order by total_un_sold) as 'rankd' from product_tab
order by rankd 

/*
Playfoam	4158	1
Uno Card Game	2710	1
Plush Pony	5488	1
Mini Basketball Hoop	2647	1
Toy Robot	11749	1
*/
with product_tab as(select product_category, product_name, sum(units) as 'total_un_sold'
from products p
join sales s
on p.product_id=s.product_id
group by product_category, product_name),

ranked_products as (select *,row_number() over(partition by product_category order by total_un_sold)
 as 'rankd' from product_tab)
select pt.product_category,pt.product_name,pt.total_un_sold,r.rankd
from product_tab pt
join ranked_products r
on pt.product_name=r.Product_name
where r.rankd=1


-- company wants to create a sales_profile with the product_category, product_name, total_uni_sold, cost_price,
-- selling_price, profit, profit margin for each stores
--- profit=rev-cost
with Sales_sum as (select product_category, product_name, p.product_id, sum(units) as 'total_un_sold',
				sum(units* product_price) as 'revenue', avg(units) as 'avg_un_sold',
			 sum(units * product_cost) as 'costp',
		(sum(units* product_price)-sum(units * product_cost)) as 'Profit'
		from products p
		join sales s
		on p.product_id=s.product_id
		group by product_category, product_name, p.product_id)

select *, profit/revenue *100.0 from sales_sum
order by Product_Category

---Company wants to analyse the performance of last six months sales with the last date recorded

--- Dateadd(), datediff() ?

-- laste date in our sales data
select max(date) from sales  /* 2023-09-30'*/

select dateadd(month,-6, (select max(date) from sales)) from sales

--- the date six months back from the max date recorded in the sales
-- we need to analyse the sales between 2023-03-30 and 2023-09-30

select s.store_id, s.date, st.store_name, sum(units) as 'total_un_sold'
, sum(units * product_price) as 'revenue'
from sales s
join stores st
on s.store_id=st.store_id
join products p
on s.product_id=p.product_id
where s.date between dateadd(month,-6, (select max(date) from sales)) and (select max(date) from sales)
group by s.store_id, s.date, st.store_name

--- Inventory table to check the inventory turnover 

--- first we need to analyse the COGS (for each year)

With sales_analys as(select product_name, sum(case when year(date) =2022 then units*product_cost else 0 end) as COGS_2022,
						sum(case when year(date) =2023 then units*product_cost else 0 end) as COGS_2023
						from sales s
						join products p
						on s.product_id =p.product_id
						group by product_name)

---- Average_inventory
, average_inv as (select p.product_name, avg(case when year(s.date) =2022 then stock_on_hand else 0 end) as 'avg_inv_2022',
										avg(case when year(s.date) =2023 then stock_on_hand else 0 end) as 'avg_inv_2023'
										from inventory i
										join products p 
										on i.product_id=p.product_id
										join sales s
										on i.product_id=s.product_id
										group by product_name
										)
select AS.Product_name, sa.COGS_2022, ai.avg_inv_2022,sa.COGS_2023, ai.avg_inv_2023,
		case when avg_inv_2022=0 then Null
		else (COGS_2022/avg_inv_2022) end as Inv_ratio_2022,
		case when avg_inv_2023=0 then Null
		else (COGS_2023/avg_inv_2023) end as Inv_ratio_2023
		from sales_analys sa
		join average_inv ai
		on sa.product_name=ai.product_name


--- Company wants to analyse the individual products performance with last sold, current sold
-- they need a function to work dynamically for various product range

-- sales trends
with sales_trend as (select month(date) as 'S_month',sum(units) as 'total_uns_sold'
		from sales s
		join products p
		on s.product_id=p.product_id
		where year(date) in (2022,2023)
		and datepart(quarter,date) <=2
		and product_category='Electronics'
		group by 
		month(date)),

post_period_sales as ( select month(date) as 'S_month',
		sum(units) as 'post_uns_sold'
		from sales s
		join products p
		on s.product_id=p.product_id
		where year(date) in (2022,2023)
		and datepart(quarter,date) >2
		and product_category='Electronics'
		group by 
		month(date))
select 'Electronics' as Product_category, st.S_month, st.total_uns_sold as 'un_sold_I2qtrs',ps.post_uns_sold as 'un_sold_II2qtrs',
				coalesce(st.total_uns_sold,0)-coalesce(ps.post_uns_sold,0) as chn_in_unt_sold
	from sales_trend St
	full join post_period_sales ps
	on st.S_month=ps.S_month
	order by
	coalesce(st.s_month,ps.S_month)

----Company needs a report for top 5 products with Total_Sales, Total_profit,Avg_sales, Total_cost in one output

-- Product_performance

--- Try this

with Total_sales as(select product_name, sum(units) as 'total_un_sold'
from products p
join sales s
on p.product_id=s.product_id
group by product_name),

avg_sal as (select product_name, avg(units * Product_price) as 'avg_sales'
from products p
join sales s
on p.product_id=s.product_id
group by product_name)

, total_cost as (select product_name, sum(units*product_cost) as 'total_C'
					
from products p
join sales s
on p.product_id=s.product_id
group by product_name)

, Profit as (select  product_name,sum(units * product_price)-sum(units*product_cost) as 'profit'
from products p
join sales s
on p.product_id=s.product_id
group by product_name)

select ts.product_name,ts.total_un_sold,avs.avg_sales,tc.total_C, profit
from total_sales ts
join avg_sal avs
on ts.product_name=avs.Product_Name
join total_cost tc
on ts.Product_Name=tc.Product_Name
join profit pf
on ts.Product_Name=pf.Product_Name
order by pf.profit desc
