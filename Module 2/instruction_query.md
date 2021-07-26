<a id="up"></a>
#Описание запросов
Ниже вы можете ознакомиться со всеми запросами в виде:

>1. Код;
2. выполненный запрос;
3. инструкции.

### Список запросов
__1. Overview (обзор ключевых метрик)__
- Total Sales (сумма продаж)
- Total Profit (сумма прибыли)
- Profit Ratio (процент прибыли от продаж)
- Profit per Order (прибыль каждого заказа)
- Sales per Customer (продажи на каждого покупателя)
- Avg. Discount (средняя скидка)
- Monthly Sales by Segment (продажи для каждого сегмента покупателей по годам и месяцам)
- Monthly Sales by Product Category (продажи для категорий и подкатегорий по годам и месяцам)

__2. Product Dashboard (Продуктовые метрики)__
- Sales by Product Category over time (Продажи по категориям)

__3. Customer Analysis (Метрики покупателей)__
- Sales and Profit by Customer (продажи и прибыль по покупателям)
- Sales per region (продажи по регионам)

### 1. Overview (обзор ключевых метрик)
__Total Sales (сумма продаж)
Total Profit (сумма прибыли)
Profit Ratio (процент прибыли от продаж)
Avg. Discount (средняя скидка)__

>select
>   round(sum(o.sales), 0) as sales_sum, -- Total Sales
>   round(sum(o.profit), 0) as profit_sum, -- Total Profit
>   round(sum(o.profit) / sum(o.sales), 2)*100 as "profit_ratio (%)", -- Profit Ratio
>   round(avg(o.discount), 2)*100 as "avg_discount (%)" -- Avg. Discount
>from orders o                    
>left join returns r
>	on o.order_id = r.order_id  -- отбираем только те кортежи, по которым не было возврата
>where r.order_id is null

![salesRegion](https://github.com/sadokhin/DE-101/blob/9afa5d0077224da091bc566d025d27b0e1d2c584/img/salesregion.png)

Функция sum() для суммирования значений в столбце. Функция round() для округления полученной суммы до 0 знаков после запятой. Чтобы посчитать Profir Ratio нужно сумму прибыли разделить на сумму продаж и умножить на 100, чтобы получились проценты. Чтобы отобрать кортежи, по которым не было возврата, мы присоединяем табличку с возвратами с помощью LEFT JOIN по order_id и соответственно, там где не было возврата в таблице с возвратами в поле order_id будут пустые значения. Их и берем.


[Наверх](#up)