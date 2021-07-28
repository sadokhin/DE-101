create schema dw;

--CREATE TABLE DW.CALENDAR, INSERT DATA AND CHECK

drop table if exists dw.calendar_dim;
CREATE TABLE dw.calendar_dim
(
 calendar_id serial NOT NULL,
 year        int NOT NULL,
 quarter      int NOT NULL,
 month       int NOT NULL,
 day_of_week varchar(15) NOT NULL,
 day_of_year int NOT NULL,
 week        int NOT NULL,
 "date"        date NOT NULL,
 leap_year   boolean NOT NULL,
 CONSTRAINT PK_date PRIMARY KEY ( calendar_id )
);

truncate table dw.calendar_dim;
insert into dw.calendar_dim select
to_char(date,'yyyymmdd')::int as calendar_id,  
       extract('year' from date)::int as year,
       extract('quarter' from date)::int as quarter,
       extract('month' from date)::int as month,      
       to_char(date, 'dy') as day_of_week,
       to_char(date,'DDD')::int as day_of_year,
       extract('week' from date)::int as week,
       date::date,
       extract('day' from
               (date_trunc('year', date) + interval '2 month - 1 day')
              ) = 29
       as leap
  from generate_series(date '2000-01-01',
                       date '2030-01-01',
                       interval '1 day')
       as t(date);
  
select * from dw.calendar_dim; 

--------------------------------------------------------------------
--CREATE TABLE DW.CUSTOMER_DIM, INSERT DATA AND CHECK

drop table if exists dw.customer_dim;
CREATE TABLE dw.customer_dim
(
 customer_dim_id serial NOT NULL,
 customer_id     varchar(20) NOT NULL,
 customer_name   varchar(30) NOT NULL,
 segment         varchar(15) NOT NULL,
 CONSTRAINT PK_customer PRIMARY KEY ( customer_dim_id )
);

truncate table dw.customer_dim;
insert into dw.customer_dim select
	100 + row_number() over() as customer_dim_id,
	o.customer_id,
	o.customer_name,
	o.segment
from (select distinct customer_id, customer_name, segment from stg.orders ) o
	
select * from dw.customer_dim

--------------------------------------------------------------------
--CREATE TABLE DW.GEO_CUSTOMER_DIM, INSERT DATA AND CHECK
	
drop table if exists dw.geo_customer_dim;
CREATE TABLE dw.geo_customer_dim
(
 geo_id      serial NOT NULL,
 country     varchar(25) NOT NULL,
 city        varchar(25) NOT NULL,
 "state"       varchar(20) NOT NULL,
 postal_code varchar(10) NOT NULL,
 region      varchar(10) NOT NULL,
 CONSTRAINT PK_geo_customer_dim PRIMARY KEY ( geo_id )
);

truncate table dw.geo_customer_dim;
insert into dw.geo_customer_dim select
	100 + row_number() over() as geo_id,
	country,
	city,
	state,
	postal_code,
	region
from (select distinct country, city, state, postal_code, region from stg.orders) o

select * from dw.geo_customer_dim

--------------------------------------------------------------------
--CREATE TABLE DW.MANAGER_DIM, INSERT DATA AND CHECK

drop table if exists dw.manager_dim;
CREATE TABLE dw.manager_dim
(
 manager_id   serial NOT NULL,
 manager_name varchar(30) NOT NULL,
 region varchar(10) NOT null,
 CONSTRAINT PK_manager_dim PRIMARY KEY ( manager_id )
);

truncate table dw.manager_dim;
insert into dw.manager_dim select
	100 + row_number() over() as manager_id,
	m.person,
	m.region
from stg.manager m

select * from dw.manager_dim

--------------------------------------------------------------------
--CREATE TABLE DW.PRODUCT_DIM, INSERT DATA AND CHECK

drop table if exists dw.product_dim;
CREATE TABLE dw.product_dim
(
 product_dim_id serial NOT NULL,
 product_id     varchar(25) NOT NULL,
 product_name   varchar(127) NOT NULL,
 category       varchar(20) NOT NULL,
 sub_category   varchar(25) NOT NULL,
 CONSTRAINT PK_product_dim PRIMARY KEY ( product_dim_id )
);

truncate table dw.product_dim;
insert into dw.product_dim select
	100 + row_number() over() as product_dim_id,
	o.product_id,
	o.product_name,
	o.category,
	o.subcategory
from (select distinct product_id, product_name, category, subcategory from stg.orders) o

select * from dw.product_dim
 
/*
update dw.product_dim
set returned = 'No'       -- run for fill not returned orders
where returned is null;
*/

--------------------------------------------------------------------
--CREATE TABLE DW.RETURN_PRODUCT_DIM, INSERT DATA AND CHECK
	
drop table if exists dw.return_product_dim;
CREATE TABLE dw.return_product_dim
(
 return_id serial NOT NULL,
 returned  varchar(5) NOT NULL,
 order_id varchar(14) NOT NULL,
 CONSTRAINT PK_return_product_dim PRIMARY KEY ( return_id )
);

truncate table dw.return_product_dim;
insert into dw.return_product_dim select
	100 + row_number() over() as return_id,
	r.returned,
	r.order_id
from (select distinct returned, order_id from stg.returns) r

select * from dw.return_product_dim

--------------------------------------------------------------------
--CREATE TABLE DW.SHIP_DIM, INSERT DATA AND CHECK		

drop table if exists dw.ship_dim;
CREATE TABLE dw.ship_dim
(
 ship_id   serial NOT NULL,
 ship_mode varchar(20) NOT NULL,
 CONSTRAINT PK_ship_dim PRIMARY KEY ( ship_id )
);

truncate table dw.ship_dim;
insert into dw.ship_dim select
	100 + row_number() over() as return_id,
	ship_mode
from (select distinct ship_mode from stg.orders) s

select * from dw.ship_dim

--------------------------------------------------------------------
--CREATE TABLE DW.SALES_FACT, INSERT DATA AND CHECK

drop table if exists dw.sales_fact;
CREATE TABLE dw.sales_fact
(
 sales_id        serial NOT NULL,
 manager_id      integer NOT NULL,
 geo_id         integer NOT NULL,
 ship_id         integer NOT NULL,
 customer_dim_id integer NOT NULL,
 product_dim_id  integer NOT NULL,
 order_id        varchar(25) NOT NULL,
 ship_date_id    integer NOT NULL,
 order_date_id   integer NOT NULL,
 sales           numeric(9,4) NOT NULL,
 quantity        int4 NOT NULL,
 discount        numeric(4,2) NOT NULL,
 profit          numeric(21,16) NOT NULL,
 manager_name    varchar(30) NOT NULL,
 return_id       integer,
 CONSTRAINT PK_sales_fact PRIMARY KEY ( sales_id )
);

truncate table dw.sales_fact;
insert into dw.sales_fact select
	100 + row_number() over() as sales_id,
	md.manager_id,
	gcd.geo_id,
	ship_id,
	cd.customer_dim_id,
	pd.product_dim_id,
	o.order_id,
	to_char(ship_date,'yyyymmdd')::int as  ship_date_id,
	to_char(order_date,'yyyymmdd')::int as  order_date_id,
	o.sales,
	o.quantity,
	o.discount,
	o.profit,
	md.manager_name as manager,
	rpd.return_id
from stg.orders o
	inner join dw.manager_dim md
		on o.region = md.region
	inner join dw.customer_dim cd
		on o.customer_id = cd.customer_id and o.customer_name = cd.customer_name and o.segment = cd.segment
	inner join dw.product_dim pd
		on o.product_id = pd.product_id and o.product_name = pd.product_name and o.category = pd.category and o.subcategory = pd.sub_category
	inner join dw.ship_dim sd
		on o.ship_mode = sd.ship_mode
	inner join dw.geo_customer_dim gcd
	on o.country = gcd.country and o.city = gcd.city and o.state = gcd.state and o.postal_code = gcd.postal_code
	left join dw.return_product_dim rpd
		on rpd.order_id = o.order_id

select count(*) from dw.sales_fact sf
	inner join dw.geo_customer_dim gcd on sf.geo_id=gcd.geo_id
	inner join dw.manager_dim md on sf.manager_id=md.manager_id
	inner join dw.ship_dim sd on sf.ship_id=sd.ship_id
	inner join dw.product_dim pd on sf.product_dim_id=pd.product_dim_id
	inner join dw.customer_dim cd on sf.customer_dim_id=cd.customer_dim_id
	left join dw.return_product_dim rpd on sf.return_id=rpd.return_id;

