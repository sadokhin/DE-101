<a id="up"></a>
# Домашняя работа (Модуль 2)
Домашняя работа для второго модуля курса _Data Engeeneging_ от [DataLearn](https://datalearn.ru/).
## 2.3 Подключение к Базам Данных и SQL
Необходимо было загрузить данные в базу данных и выполнить запросы для ответа на вопросы:
__Загрузка данных__
- [orders.sql](https://github.com/sadokhin/DE-101/blob/72445cb4f0e1bdfacb592d0c1908a2b6783c46d8/Module%202/orders.sql) 
- [people.sql](https://github.com/sadokhin/DE-101/blob/72445cb4f0e1bdfacb592d0c1908a2b6783c46d8/Module%202/people.sql)
- [returns.sql](https://github.com/sadokhin/DE-101/blob/72445cb4f0e1bdfacb592d0c1908a2b6783c46d8/Module%202/returns.sql)

__Запросы для ответа на вопросы__
- Код запросов - [answers_query.sql](https://github.com/sadokhin/DE-101/blob/72445cb4f0e1bdfacb592d0c1908a2b6783c46d8/Module%202/answers_query.sql)
- Код + Скрины + Инстркуции для выполнения запросов - [instruction_query.md](https://github.com/sadokhin/DE-101/blob/72445cb4f0e1bdfacb592d0c1908a2b6783c46d8/Module%202/instruction_query.md)
## 2.4 Модели Данных
Нужно было составить 3 модели (концептуальную, логическую и физическую) с помощью [sqlDBM](https://sqldbm.com/Home/) и создать и заполнить __demensions__ и __sales_fact__ таблицы данными.

__Концептуальная__

![concept_model](https://github.com/sadokhin/DE-101/blob/e56ed157e769a574aa45e2d782e0e777184ab8af/Module%202/concept_model.png)

__Логическая__

![logic_model](https://github.com/sadokhin/DE-101/blob/e56ed157e769a574aa45e2d782e0e777184ab8af/Module%202/logic_model.png)

__Физическая__

![physics_model](https://github.com/sadokhin/DE-101/blob/e56ed157e769a574aa45e2d782e0e777184ab8af/Module%202/phisics_model.png)

__Создание схемы DW (Business layer)__
- Код создания из схемы stg в dw - [from_stg_to_dwt.sql](https://github.com/sadokhin/DE-101/blob/e56ed157e769a574aa45e2d782e0e777184ab8af/Module%202/from_stg_to_dwt.sql)
- Описание создания схемы - [instruction_schemaDW.md](https://github.com/sadokhin/DE-101/blob/e56ed157e769a574aa45e2d782e0e777184ab8af/Module%202/instruction_schemaDW.md)
