<a id="up"></a>
# Описание схемы базы данных
Наши "сырые" данные хранятся в файлах:
>[stg.orders](https://github.com/sadokhin/DE-101/blob/b30afb4475674ca8d93f16e99a80f91ca1ceafca/Module%202/stg.orders.sql)<br>
>[stg.returns](https://github.com/sadokhin/DE-101/blob/b30afb4475674ca8d93f16e99a80f91ca1ceafca/Module%202/stg.returns.sql)<br>
>[stg.manager](https://github.com/sadokhin/DE-101/blob/b30afb4475674ca8d93f16e99a80f91ca1ceafca/Module%202/stg.manager.sql)

Код разделен на смысловые кусочки, которые состоят из:

1. Создание таблицы
2. Наполнение данными
3. Проверка

__Физическая модель схемы базы данных__

![physics_model](https://github.com/sadokhin/DE-101/blob/b30afb4475674ca8d93f16e99a80f91ca1ceafca/Module%202/phisics_model.png)

Соответственно нам необходимы следующие таблицы:
1. [Географические данные покупателей (`geo_customer_dim`)](#1)
2. [Сведения о покупателях (`customer_dim`](#2)
3. [Данные о доставке (`ship_dim`)](#3)
4. [Информация о менеджерах (`manager_dim`)](#4)
5. [Календарь (`calendar_dim`)](#5)
6. [Данные о продукте (`product_dim`)](#6)
7. [Сведения о возврате заказов (`return_product_dim`)](#7)
8. [Таблица с продажами (`sales_fact`)](#8)
<a id="1"></a>

__1. Географические данные покупателей (`geo_customer_dim`)__
```
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
```
`drop table if exists dw.geo_customer_dim`; и `truncate table dw.geo_customer_dim;` нужны для удаления и "очищения" таблиц соответсвенно, иначе, если перезапускать код, будут слышны ругательства "такая таблица уже существует", а пересоздавать иногда приходится часто (то удалить, это поправить, тип данных изменить и тп).
Затем мы `CREATE` (создаём) как бы контейнеры, атрибуты в простонародье и `INSERT` (вставляем) данные, то есть домены для каждого атрибута. Вставляем мы данные из таблицы `stg.orders` причем уникальные, поэтому пишем `DISTINCT`, иначе, когда мы будем (всегда хотел так сказать) "Джойнить" к основной таблице, будут создаваться ненужные нам кортежи, так как у разных `geo_id`, одинаковые геоданные.
<a id="2"></a>

__2. Сведения о покупателях (`customer_dim`)__
```
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
```
Здесь, все то же самое, как и в примере выше. Опять берем только уникальные кортежи. Чуть не забыл, `100 + row_number() over()`, что это за зверь такой. Тут мы генерим одним из способов уникальную последовательность чисел. Возможно, подойдет и `AUTO_INCREMENT` или `generate_series()`, но как первый раз увидел, так и делаю :(
<a id="3"></a>

__3. Данные о доставке (`ship_dim`)__
```
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
```
<a id="4"></a>

__4. Информация о менеджерах (`manager_dim`)__
```
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
```
<a id="5"></a>

__5. Календарь (`calendar_dim`)__
```
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
       as leap_year
  from generate_series(date '2000-01-01',
                       date '2030-01-01',
                       interval '1 day')
       as t(date);
  
select * from dw.calendar_dim; 
```
Все функции брал из документации

- [операторы и функции даты/времени](https://postgrespro.ru/docs/postgresql/9.6/functions-datetime)
- [функции форматирования данных](https://postgrespro.ru/docs/postgresql/9.4/functions-formatting).

Вторым аргументов функции `to_char()` может выступать специальный код, который распознается и дата, указанная первым аргументов, соответствующим образом форматируется.

- `to_char(date, 'dy')` - возвращает сокращенное название дня недели (3 буквы) в нижнем регистре
- `to_char(date,'DDD')` - возвращает номер дня в году (от 1 до 366)

Для определения високосного года использовалась следующая логика: отсекаем у даты месяц и день, прибавляем два месяца и вычитаем один день. Затем из полученной даты берем день и проверяем, равен ли он 29. Если да, то високосный, в противном случае невисокосный. Функция `date_trunc()` отсекает дату по заданной точности, в данной случае до года.
<a id="6"></a>

__6. Данные о продукте (`product_dim`)__
```
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
```
<a id="7"></a>

__7. Сведения о возврате заказов (`return_product_dim`)__
```
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
```
<a id="8"></a>

__8. Таблица с продажами (`sales_fact`)__
```
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
```
Вот и основная таблица. Тут и знакомые нам `to_char()`, и `CREATE`, и `INSERT`. Только теперь мы ещё присоединяем все созданные ранее таблицы, через соответствующие поля. На данной этапе возникло много сложностей. Чтобы было легче искать ошибку, можно выполнять запрос с первым `JOIN`, затем со вторым и так далее, не забывая при этой закомментировать неиспользуемые поля при создании таблицы. Так как мы знаем, что в `stg.order`s у нас `9994` кортежа, это число не должно в данной случае увеличиваться или уменьшаться при добавлении данных из другой таблицы. В конце используется `LEFT JOIN`, так как не у всех товаров был возврат, соотвественно, если использовать `INNER JOIN`, то заказы без возврата удалятся.

[Наверх](#up)
