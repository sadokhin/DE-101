/*1. Overview (обзор ключевых метрик)
Total Sales
Total Profit
Profit Ratio
Avg. Discount
 */

select
	round(sum(o.sales), 0) as sales_sum, -- Total Sales
	round(sum(o.profit), 0) as profit_sum, -- Total Profit
	round(sum(o.profit) / sum(o.sales), 2)*100 as "profit_ratio (%)", -- Profit Ratio
	round(avg(o.discount), 2)*100 as "avg_discount (%)" -- Avg. Discount
	
from orders o                    
left join returns r
	on o.order_id = r.order_id  -- отбираем только те кортежи, по которым не было возврата
where r.order_id is null

/*
 Profit per Order
 */

select
	o.order_id,
	round(sum(o.profit), 0) as "profit_order ($)"	
from orders o 
left join returns r
	on o.order_id = r.order_id
where r.order_id is null
group by o.order_id
order by "profit_order ($)" desc
limit 10

/*
Sales per Customer 
 */

select
	o.customer_id,
	o.customer_name,
	round(sum(o.sales), 0) as sales_customer
from orders o 
left join returns r
	on o.order_id = r.order_id
where r.order_id is null
group by o.customer_id, o.customer_name
order by sales_customer desc
limit 10

/*
 Monthly Sales by Segment
 */

select
	extract (year from o.order_date) as year,
	extract (month from o.order_date) as month,
	o.segment,
	round(sum(o.sales), 0) as sales_segment
from orders o 
left join returns r
	on o.order_id = r.order_id
where r.order_id is null
group by year, month, o.segment
order by year, month, sales_segment DESC
limit 15

/*
Monthly Sales by Product Category
 */

select
	extract (year from o.order_date) as year,
	extract (month from o.order_date) as month,
	o.category,
	o.subcategory,
	round(sum(o.sales), 0) as sales_category
from orders o 
left join returns r
	on o.order_id = r.order_id
where r.order_id is null
group by year, month, o.category, o.subcategory
order by year, month, category, sales_category DESC
limit 15

/*2. Product Dashboard (Продуктовые метрики)
Sales by Product Category over time
 */

select
	o.category,
	o.subcategory,
	round(sum(o.sales), 0) as sales_category
from orders o 
left join returns r
	on o.order_id = r.order_id
where r.order_id is null
group by o.category, o.subcategory
order by sales_category desc

/*3. Customer Analysis
Sales and Profit by Customer
 */

select
	o.customer_id,
	o.customer_name,
	round(sum(o.sales), 0) as sales_customer,
	round(sum(o.profit), 0) as profit_customer
from orders o 
left join returns r
	on o.order_id = r.order_id
where r.order_id is null
group by o.customer_id, o.customer_name
order by profit_customer desc
limit 10

/*
Sales per region
 */

select
	o.region,
	round(sum(o.sales), 0) as sales_region
from orders o 
left join returns r
	on o.order_id = r.order_id
where r.order_id is null
group by o.region
order by sales_region desc