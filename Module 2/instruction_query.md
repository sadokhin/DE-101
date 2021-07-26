<a id="up"></a>
# Описание запросов
Ниже вы можете ознакомиться со всеми запросами в виде:

1. Код;
2. выполненный запрос;
3. инструкции.

### Список запросов
__1. Overview (обзор ключевых метрик)__
- [Total Sales (сумма продаж)](#1)
- [Total Profit (сумма прибыли)](#1)
- [Profit Ratio (процент прибыли от продаж)](#1)
- [Profit per Order (прибыль каждого заказа)](#2)
- [Sales per Customer (продажи на каждого покупателя)](#3)
- [Avg. Discount (средняя скидка)](#1)
- [Monthly Sales by Segment (продажи для каждого сегмента покупателей по годам и месяцам)](#4)
- [Monthly Sales by Product Category (продажи для категорий и подкатегорий по годам и месяцам)](#5)

__2. Product Dashboard (Продуктовые метрики)__
- [Sales by Product Category over time (Продажи по категориям)](#6)

__3. Customer Analysis (Метрики покупателей)__
- [Sales and Profit by Customer (продажи и прибыль по покупателям)](#7)
- [Sales per region (продажи по регионам)](#8)

### 1. Overview (обзор ключевых метрик)
<a id="1"></a>

__1.1. Total Sales (сумма продаж)__
__Total Profit (сумма прибыли)__
__Profit Ratio (процент прибыли от продаж)__
__Avg. Discount (средняя скидка)__

```
select
   round(sum(o.sales), 0) as sales_sum, -- Total Sales
   round(sum(o.profit), 0) as profit_sum, -- Total Profit
   round(sum(o.profit) / sum(o.sales), 2)*100 as "profit_ratio (%)", -- Profit Ratio
   round(avg(o.discount), 2)*100 as "avg_discount (%)" -- Avg. Discount
from orders o                    
left join returns r
	on o.order_id = r.order_id  -- отбираем только те кортежи, по которым не было возврата
where r.order_id is null
```
![maimmetrics](https://github.com/sadokhin/DE-101/blob/07152c13d13bda0a8eebc3524c1fbfc997448137/img/1.png)

>Функция `sum()` для суммирования значений в столбце. Функция `round()` для округления полученной суммы до `0` знаков после запятой. Чтобы посчитать `Profir Ratio` нужно сумму прибыли разделить на сумму продаж и умножить на `100`, чтобы получились проценты. Чтобы отобрать кортежи, по которым не было возврата, мы присоединяем табличку с возвратами с помощью `LEFT JOIN` по `order_id` и соответственно, там где не было возврата в таблице с возвратами в поле `order_id` будут пустые значения. Их и берем.
<a id="2"></a>

__1.2. Profit per Order (прибыль каждого заказа)__

```
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
```
![profitorder](https://github.com/sadokhin/DE-101/blob/07152c13d13bda0a8eebc3524c1fbfc997448137/img/2.png)

>Опять же отбираем кортежи без возврата и находим сумму прибыли, группируя по `order_id` и сортируем по убыванию прибыли. Затем для удобства ограничим вывод 10 строками.
<a id="3"></a>

__1.3. Sales per Customer (продажи на каждого покупателя)__

```
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
```
![salescostumer](https://github.com/sadokhin/DE-101/blob/07152c13d13bda0a8eebc3524c1fbfc997448137/img/3.png)

>Опять же отбираем кортежи без возврата и находим сумму прибыли, группируя по `customer_id` и `customer_name` и сортируем по убыванию прибыли. Затем для удобства ограничим вывод 10 строками.
<a id="4"></a>

__1.4. Monthly Sales by Segment (продажи для каждого сегмента покупателей по годам и месяцам)__

```
select
	extract (year from o.order_date) as year,
	extract (month from o.order_date) as month,
	o.segment,
	round(sum(o.sales), 0) as sales_segment
from orders o 
group by year, month, o.segment
order by year, month, sales_segment DESC
```
![salessegmentbydata](https://github.com/sadokhin/DE-101/blob/07152c13d13bda0a8eebc3524c1fbfc997448137/img/4.png)

>Находим сумму продаж. Выводим год и месяц из поля order_date и сегмент для каждого кортежа, группируя по году, месяцу и сегменту и сортируем сначала по годам, потом по месяцам и, наконец, по убыванию продаж.
<a id="5"></a>

__1.5. Monthly Sales by Product Category (продажи для категорий и подкатегорий по годам и месяцам)__

```
select
	extract (year from o.order_date) as year,
	extract (month from o.order_date) as month,
	o.category,
	o.subcategory,
	round(sum(o.sales), 0) as sales_category
from orders o 
group by year, month, o.category, o.subcategory
order by year, month, category, sales_category DESC
```
![salescategorybydata](https://github.com/sadokhin/DE-101/blob/07152c13d13bda0a8eebc3524c1fbfc997448137/img/5.png)

>Находим сумму продаж. Выводим год и месяц из поля order_date, категорию и подкатегорию, группируя по году, месяцу, категориям и подкатегориям и сортируем сначала по годам, потом по месяцам, категории и, наконец, по убыванию продаж.
<a id="6"></a>

### 2. Product Dashboard (Продуктовые метрики)
__2.1. Sales by Product Category over time (Продажи по категориям)__

```
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
```
![salescategory](https://github.com/sadokhin/DE-101/blob/07152c13d13bda0a8eebc3524c1fbfc997448137/img/6.png)

>Опять же отбираем кортежи без возврата и находим сумму продаж, группируя по категориям и подкатегориям. Сортируем по убыванию продаж.

### 3. Customer Analysis (Метрики покупателей)
<a id="7"></a>

__3.1 Sales and Profit by Customer (продажи и прибыль по покупателям)__

```
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
```
![salesprofitcostumer](https://github.com/sadokhin/DE-101/blob/07152c13d13bda0a8eebc3524c1fbfc997448137/img/7.png)

>Опять же отбираем кортежи без возврата и находим суммы продаж и прибыли, группируя по `customer_id` и `customer_name`. Сортируем по убыванию прибыли. По сути, такой запрос был, только без прибыли. Затем для удобства ограничим вывод 10 строками.
<a id="8"></a>

__3.2. Sales per region (продажи по регионам)__

```
select
	o.region,
	round(sum(o.sales), 0) as sales_region
from orders o 
group by o.region
order by sales_region desc
```
![salesregion](https://github.com/sadokhin/DE-101/blob/07152c13d13bda0a8eebc3524c1fbfc997448137/img/8.png)

>Находим суммы продаж, группируя по регионам. Сортируем по убыванию продаж.

[Наверх](#up)
