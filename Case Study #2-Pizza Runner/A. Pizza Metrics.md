# :pizza: Case Study #1: Pizza Runner

#### Data Cleanup

##Customer Order

- creating temporary table '#customer_orders'
- replacing null or NaN values in exclusions and extras columns with '' (blank)

````sql
select order_id,customer_id,pizza_id,
case
	when exclusions is null or exclusions like 'null' then ''
	else exclusions
	end as exclusions,
case
	when extras is null or extras like 'null' then ''
	else extras
	end as extras,
order_time
into #customer_orders
from pizza_runner.customer_orders
````

##Runner orders

- Creating temporary table '#runner_orders'
- replacing null or NULL values in pickup_time,distance,duration and cancellation columns to '' (blank)
- removing 'km' and ' km' from distance column so that it is a numeric column
- removing ' minutes','minutes',' mins',' mins' and ' minute' from duration so that it is a numeric column

````sql
select order_id,runner_id,
case
	when pickup_time like 'null' then ''
	else pickup_time
	end as pickup_time,
case
	when distance like 'null' then ''
	when distance like '%km' then trim('km' from distance)
	else distance
	end as distance,
case
	when duration like 'null' then ''
	when duration like '%minutes' then trim('minutes' from duration)
	when duration like '%minute' then trim('minute' from duration)
	when duration like '%mins' then trim('mins' from duration)
	else duration
	end as duration,
case
	when cancellation is NULL or cancellation like 'null' then ''
	else cancellation
	end as cancellation
into #runner_orders
from pizza_runner.runner_orders
````

##Changing data types of columns

````sql
alter table #customer_orders
alter column order_time datetime

alter table #runner_orders
alter column distance float

alter table #runner_orders
alter column duration int
````

##Seeing how our temporary tables looks like, we will perform all our queries based on these tables
````sql
select * from #runner_orders
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/Screenshot%20(1).png)

````sql
select * from #customer_orders
````
![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/Screenshot%20(2).png)
