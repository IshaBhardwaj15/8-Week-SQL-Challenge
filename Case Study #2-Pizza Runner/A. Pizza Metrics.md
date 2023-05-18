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

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(1).png)

````sql
select * from #customer_orders
````
![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(2).png)

#### 1. How many pizzas were ordered?

````sql
select count(order_id) as Pizzas_ordered
from #customer_orders
````
![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(3).png)

#### 2. How many unique customer orders were made?

````sql
select count(distinct(order_id)) as Unique_Customer_Orders
from #customer_orders
````
![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(4).png)

#### 3. How many successful orders were delivered by each runner?

````sql
select runner_id,count(order_id) as Orders_Delivered
from #runner_orders
where cancellation=''
group by runner_id
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(5).png)

#### 4. How many of each type of pizza was delivered?

````sql
select p.pizza_name,c.pizza_id,count(c.pizza_id) as count_pizza
from #customer_orders as c
join pizza_runner.pizza_names as p on
	p.pizza_id=c.pizza_id
join #runner_orders as r on
	r.order_id=c.order_id
where r.cancellation=''
group by p.pizza_name,c.pizza_id
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(6).png)

#### 5. How many Vegetarian and Meatlovers were ordered by each customer?

````sql
select c.customer_id,p.pizza_name,count(c.pizza_id) as No_of_Pizzas
from #customer_orders as c
join pizza_runner.pizza_names as p on
	p.pizza_id=c.pizza_id
group by c.customer_id,p.pizza_name
order by c.customer_id
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(7).png)

#### 6. What was the maximum number of pizzas delivered in a single order?

````sql
with customer_cte as
(
	select c.order_id,count(c.pizza_id) as Pizza_count
	from #customer_orders as c
	join #runner_orders as r on
		r.order_id=c.order_id
	where r.cancellation=''
	group by c.order_id
)
select max(Pizza_count) as Max_Pizza_count
from customer_cte
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(8).png)

#### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
select c.customer_id,
sum(
	case
		when c.exclusions!='' or c.extras!='' then 1
		else 0
	end
	) as atleast_1_change,
sum(
	case
		when c.exclusions='' and c.extras='' then 1
		else 0
	end
	) as no_changes
from #customer_orders as c
join #runner_orders as r on
	r.order_id=c.order_id
where r.cancellation=''
group by c.customer_id
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(9).png)

#### 8. How many pizzas were delivered that had both exclusions and extras?

````sql
select 
	sum(
		case
			when exclusions<>'' and extras<>'' then 1
			else 0
		end) as Pizzas_with_exclusions_and_extras
from #customer_orders as c
join #runner_orders as r on
	r.order_id=c.order_id
where r.cancellation=''
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(10).png)

#### 9. What was the total volume of pizzas ordered for each hour of the day?

````sql
select DATEPART(hour,order_time) as hour_of_day,count(order_id) as Pizza_Volume
from #customer_orders
group by DATEPART(hour,order_time)
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(11).png)

#### 10. What was the volume of orders for each day of the week?

````sql
select format(dateadd(day,2,order_time),'dddd') as day_of_week,--incremented by 2 to make monday as first day of week
count(order_id) as Order_Volume
from #customer_orders
group by format(dateadd(day,2,order_time),'dddd')
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(12).png)
