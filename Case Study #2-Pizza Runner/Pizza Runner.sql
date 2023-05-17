--Created database 'pizza_runner' and using it so that all the tables are created in this particular database

use pizza_runner
go

------------------
--Data Injestion--
------------------

--Created Schema 'pizza_runner'

create schema pizza_runner
go

--Creating table 'runners'

create table pizza_runner.runners 
(
  runner_id int,
  registration_date date
)

--Insering data into table 'runners'

insert into pizza_runner.runners
  (runner_id, registration_date)
values
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15')

--Creating table 'customer_orders'
drop table pizza_runner.customer_orders
create table pizza_runner.customer_orders
(
  order_id int,
  customer_id int,
  pizza_id int,
  exclusions varchar(4),
  extras varchar(4),
  order_time datetime
)

--Inserting data in table 'customer_orders'

insert into pizza_runner.customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
values
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1,5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2,6', '1,4', '2020-01-11 18:34:49')


--Creating table 'runner_orders'

create table pizza_runner.runner_orders 
(
  order_id int,
  runner_id int,
  pickup_time varchar(19),
  distance varchar(7),
  duration varchar(10),
  cancellation varchar(23)
)

--Inserting data in table 'runner_orders'

insert into pizza_runner.runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
values
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null')

--Creating table 'pizza-names'

create table pizza_runner.pizza_names 
(
  pizza_id int,
  pizza_name char(20)
)

--Inserting data in table 'pizza_names'

insert into  pizza_runner.pizza_names
  (pizza_id, pizza_name)
values
  (1, 'Meatlovers'),
  (2, 'Vegetarian')

--Creating table 'pizza-recipes'

create table pizza_runner.pizza_recipes
(
  pizza_id int,
  toppings char(50)
)

--Inserting data in table 'pizza_recipes'

insert into pizza_runner.pizza_recipes
  (pizza_id, toppings)
values
  (1, '1,2,3,4,5,6,8,10'),
  (2, '4,6,7,9,11,12')

--Creating table pizza_toppings

create table pizza_runner.pizza_toppings
(
  topping_id int,
  topping_name varchar(50)
)

--Inserting data in table pizza_toppigs

insert into pizza_runner.pizza_toppings
  (topping_id, topping_name)
values
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce')

--Displaying each table by running the following queries

select * from [pizza_runner].[runners]
select * from [pizza_runner].[customer_orders]
select * from [pizza_runner].[runner_orders]
select * from [pizza_runner].[pizza_names]
select * from [pizza_runner].[pizza_recipes]
select * from [pizza_runner].[pizza_toppings]

----------------
--Data Cleanup--
----------------

--customer_orders--
--creating temporary table '#customer_orders'
--replacing null or NaN values in exclusions and extras columns with '' (blank)

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
 
--runner_orders--
--Creating temporary table '#runner_orders'
--replacing null or NULL values in pickup_time,distance,duration and cancellation columns to '' (blank)
--removing 'km' and ' km' from distance column so that it is a numeric column
--removing ' minutes','minutes',' mins',' mins' and ' minute' from duration so that it is a numeric column

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

--Changing data types of columns

alter table #customer_orders
alter column order_time datetime

alter table #runner_orders
alter column distance float

alter table #runner_orders
alter column duration int

--Seeing how our temporary tables looks like, we will perform all our queries based on these tables

select * from #runner_orders
select * from #customer_orders

--------------------
--A. Pizza Metrics--
--------------------

--Query 1 How many pizzas were ordered?

select count(order_id) as Pizzas_ordered
from #customer_orders

--Query 2 How many unique customer orders were made?

select count(distinct(order_id)) as Unique_Customer_Orders
from #customer_orders

--Query 3 How many successful orders were delivered by each runner?

select runner_id,count(order_id) as Orders_Delivered
from #runner_orders
where cancellation=''
group by runner_id

--Query 4 How many of each type of pizza was delivered?

select p.pizza_name,c.pizza_id,count(c.pizza_id) as count_pizza
from #customer_orders as c
join pizza_runner.pizza_names as p on
	p.pizza_id=c.pizza_id
join #runner_orders as r on
	r.order_id=c.order_id
where r.cancellation=''
group by p.pizza_name,c.pizza_id

--Query 5 How many Vegetarian and Meatlovers were ordered by each customer?

select c.customer_id,p.pizza_name,count(c.pizza_id) as No_of_Pizzas
from #customer_orders as c
join pizza_runner.pizza_names as p on
	p.pizza_id=c.pizza_id
group by c.customer_id,p.pizza_name
order by c.customer_id

--Query 6 What was the maximum number of pizzas delivered in a single order?

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

--Query 7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

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

--Query 8 How many pizzas were delivered that had both exclusions and extras?

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

--Query 9 What was the total volume of pizzas ordered for each hour of the day?

select DATEPART(hour,order_time) as hour_of_day,count(order_id) as Pizza_Volume
from #customer_orders
group by DATEPART(hour,order_time)

--Query 10 What was the volume of orders for each day of the week?

select format(dateadd(day,2,order_time),'dddd') as day_of_week,--incremented by 2 to make monday as first day of week
count(order_id) as Order_Volume
from #customer_orders
group by format(dateadd(day,2,order_time),'dddd')

------------------------------------
--B. Runner and Customer Experince--
------------------------------------

--Query 1 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

select
	case
		when registration_date between '2021-01-01' and '2021-01-07' then '1'
		when registration_date between '2021-01-08' and '2021-01-14' then '2'
		else '3'
	end as Registration_Week,
count(runner_id) as runners
from pizza_runner.runners
group by
case
		when registration_date between '2021-01-01' and '2021-01-07' then '1'
		when registration_date between '2021-01-08' and '2021-01-14' then '2'
		else '3'
	end

--Query 2 What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

with time_taken_cte as
(
	select r.runner_id,c.order_id,c.order_time,r.pickup_time, 
		DATEDIFF(MINUTE,c.order_time,r.pickup_time) as arrival_time_in_mins
	from #customer_orders as c
	join #runner_orders as r on
		c.order_id=r.order_id
	where r.cancellation=''
	group by r.runner_id,c.order_id,c.order_time,r.pickup_time
)

select runner_id,avg(arrival_time_in_mins) as avg_arrival_time_in_mins
from time_taken_cte
where arrival_time_in_mins>1
group by runner_id

--Query 3 Is there any relationship between the number of pizzas and how long the order takes to prepare?

with prep_time_cte as
(
	select c.order_id,count(c.order_id) as Pizza_ordered,c.order_time,r.pickup_time, 
		DATEDIFF(MINUTE,c.order_time,r.pickup_time) as prep_time_in_mins
	from #customer_orders as c
	join #runner_orders as r on
		c.order_id=r.order_id
	where r.cancellation=''
	group by c.order_id,c.order_time,r.pickup_time
)
select Pizza_ordered,avg(prep_time_in_mins) as avg_prep_time_in_mins
from prep_time_cte
where prep_time_in_mins>1
group by Pizza_ordered

--Query 4 What was the average distance travelled for each customer?

Select c.customer_id,round(avg(r.distance),2) as Avg_distance
from #customer_orders as c
join #runner_orders as r on
	r.order_id=c.order_id
where r.cancellation=''
group by c.customer_id

--Query 5 What was the difference between the longest and shortest delivery times for all orders?

select max(duration)-min(duration) as Difference_in_delivery
from #runner_orders
where duration!=0

--Query 6 What was the average speed for each runner for each delivery and do you notice any trend for these values?

select runner_id,round((distance/duration*60),2) as avg_speed
from #runner_orders
where cancellation=''
group by runner_id,duration,distance

--Query 7 What is the successful delivery percentage for each runner?

select runner_id,count(order_id) as Successful_delivery
from #runner_orders
where cancellation=''
group by runner_id

------------------------------
--C. Ingredient Optimization--
------------------------------

--Creating some temporary tables that we will use in further queries
--splitting each string in extras and exclusions so that each of the elements is seen in individual rows

select c.order_id,c.customer_id,c.pizza_id,pn.pizza_name,exc.value as exclusions,ext.value as extras,c.order_time
	into #customer_orders_split
	from #customer_orders as c
	cross apply string_split(c.exclusions,',') as exc
	cross apply string_split(c.extras,',') as ext
	join pizza_runner.pizza_names as pn on
		pn.pizza_id=c.pizza_id

--seeing how our temporary table looks like
select * from #customer_orders_split

--Query 1 What are the standard ingredients for each pizza?

with row_split_toppings_cte as
(
	select pr.pizza_id,toppingg.value as toppingg
	from pizza_runner.pizza_recipes as pr
	cross apply string_split(pr.toppings,',') as toppingg
)
select rstc.pizza_id,pn.pizza_name,string_agg(t.topping_name,', ') as Standard_Ingredients
from row_split_toppings_cte as rstc
join pizza_runner.pizza_names as pn on
	pn.pizza_id=rstc.pizza_id
join pizza_runner.pizza_toppings as t on
	t.topping_id=rstc.toppingg
group by pn.pizza_name,rstc.pizza_id

--Query 2 What was the most commonly added extra?

with common_extras_cte as
(
	select extras,count(extras) as common_extras
	from #customer_orders_split
	where extras!=''
	group by extras
)
select top 1 cet.common_extras as times_included,t.topping_name as Most_Common_Extras
from common_extras_cte as cet
join pizza_runner.pizza_toppings as t on
	t.topping_id=cet.extras
group by cet.extras,t.topping_name,cet.common_extras
order by times_included desc

--Query 3 What was the most common exclusion?

with common_exclusions_cte as
(
	select exclusions,count(exclusions) as common_exclusions
	from #customer_orders_split
	where exclusions!=''
	group by exclusions
)
select top 1 cex.common_exclusions as times_excluded,t.topping_name as Most_Common_Exclusions
from common_exclusions_cte as cex
join pizza_runner.pizza_toppings as t on
	t.topping_id=cex.exclusions
group by cex.exclusions,t.topping_name,cex.common_exclusions
order by times_excluded desc

--Query 4 Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

with extras as(
	select order_id,customer_id,pizza_id,pizza_name,extras,
		STRING_AGG(t.topping_name,',') as Included_ingredient
	from 
		(
		select distinct order_id,customer_id,pizza_id,pizza_name,extras
		from 
		#customer_orders_split as cs
		where cs.extras<>'null' and cs.extras>0
		)x
		join pizza_runner.pizza_toppings as t on
			t.topping_id=extras
		group by order_id,pizza_id,extras,pizza_name,customer_id
),
exclusions as(
	select order_id,customer_id,pizza_id,pizza_name,exclusions,
		STRING_AGG(t.topping_name,',') as Excluded_ingredient
	from 
		(
		select distinct order_id,customer_id,pizza_id,pizza_name,exclusions
		from
		#customer_orders_split as cs
		where cs.exclusions<>'null' and cs.exclusions>0
		)x
	join pizza_runner.pizza_toppings as t on
		t.topping_id=exclusions
	group by order_id,pizza_id,exclusions,pizza_name,customer_id
)
select cs.order_id,
	case
		when exc.Excluded_ingredient is NULL and ext.Included_ingredient is NULL then cs.pizza_name
		when ext.Included_ingredient is NULL and exc.Excluded_ingredient is NOT NULL then 
			CONCAT(cs.pizza_name,'- Exclude ',string_agg(exc.Excluded_ingredient,','))
		when exc.Excluded_ingredient is NULL and ext.Included_ingredient is NOT NULL then
			CONCAT(cs.pizza_name,'- Include ',string_agg(ext.Included_ingredient,','))
		else
			CONCAT(cs.pizza_name,'- Include ',string_agg(ext.Included_ingredient,','),'- Exclude ',
				string_agg(exc.Excluded_ingredient,','))
	end as Order_Details
from #customer_orders_split as cs
left join extras as ext on
	ext.order_id=cs.order_id and ext.pizza_id=cs.pizza_id and ext.extras=cs.extras
left join exclusions as exc on
	exc.order_id=cs.order_id and exc.pizza_id=cs.pizza_id and exc.exclusions=cs.exclusions
join pizza_runner.pizza_names as np on
	np.pizza_id=cs.pizza_id
group by cs.order_id,exc.Excluded_ingredient,ext.Included_ingredient,cs.pizza_name
order by cs.order_id

--------------------------
--D. Pricing and Ratings--
--------------------------

--Query 1 If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
--how much money has Pizza Runner made so far if there are no delivery fees?

with Revenue as
(
select cs.order_id,customer_id,pizza_id,pizza_name,
case
	when pizza_id =1 then 12
	else 10
end as Cost_in_$ 
from #customer_orders_split as cs
join #runner_orders as ro on
ro.order_id=cs.order_id
where cancellation=''
)
select concat('$',sum(Cost_in_$)) as Total_Revenue
from Revenue

--Query 2 What if there was an additional $1 charge for any pizza extras?
--Add cheese is $1 extra

with cs_cte as
(
	select cs.order_id,cs.customer_id,cs.pizza_id,cs.pizza_name,cs.extras,
		case
			when cs.pizza_id=1 then 12
			else 10
		end as pizza_revenue,
		case
			when len(cs.extras)=1 then 1
			else 0
		end as topping_revenue
	from #customer_orders_split as cs
	join #runner_orders as ro on
		ro.order_id=cs.order_id
	where ro.cancellation=''		
)
select concat('S',sum(pizza_revenue)+sum(topping_revenue)) as total_revenue
from cs_cte

--Query 3 The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
--how would you design an additional table for this new dataset - generate a schema for this new table and insert your own
--data for ratings for each successful customer order between 1 to 5.

create table pizza_runner.runners_rating
(
	order_id int,
	rating int,
	Review varchar(120)
)

insert into pizza_runner.runners_rating
	(order_id,rating,Review)
values
	(1,5,'Good'),
	(2,5,null),
	(3,3,'Took too long to arrive'),
	(4,1,'Order delayed.Pizzas arrived cold,Poor Service'),
	(5,4,'Good Service'),
	(7,5,'Fast Delivery'),
	(8,3,'Slightly delayed'),
	(10,5,'Good service, fast delivery')

select *
from pizza_runner.runners_rating

--Query 4 Using your newly generated table - can you join all of the information together to form a table which has the 
--following information for successful deliveries?
--customer_id
--order_id
--runner_id
--rating
--order_time
--pickup_time
--Time between order and pickup
--Delivery duration
--Average speed
--Total number of pizzas

select cs.customer_id,cs.order_id,ro.runner_id,rr.rating,cs.order_time,ro.pickup_time,
	datediff(minute,cs.order_time,ro.pickup_time) as Time_between_order_and_pickup,
	ro.duration,round(ro.distance*60/ro.duration,2) as Average_speed,
	count(cs.pizza_id) as Total_number_of_pizzas
from #customer_orders_split as cs
join #runner_orders as ro on
	ro.order_id=cs.order_id
join pizza_runner.runners_rating as rr on
	rr.order_id=cs.order_id
group by cs.customer_id,cs.order_id,ro.runner_id,rr.rating,cs.order_time,ro.pickup_time,ro.duration,ro.distance

--Query 5 If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is 
--paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

with ctee as
(
	select cs.order_id,ro.distance,
		case
			when cs.pizza_id=1 then 12
			else 10
		end as pizza_revenue,
		round(0.30*ro.distance,2) as delivery_cost
	from #customer_orders_split as cs
	join #runner_orders as ro on
		ro.order_id=cs.order_id
	where ro.cancellation=''
)
select concat('$',round(sum(pizza_revenue-delivery_cost),2)) as pizza_runner_revenue
from ctee

----------------------
--E. Bonus Questions--
----------------------

--If Danny wants to expand his range of pizzas - how would this impact the existing data design? 
--Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the 
--Pizza Runner menu?

insert into pizza_runner.pizza_names
	(pizza_id,pizza_name)
values
	(3,'Supreme')

select * from [pizza_runner].[pizza_names]

insert into pizza_runner.pizza_recipes
	(pizza_id,toppings)
values
	(3,'1,2,3,4,5,6,7,8,9,10,11,12')

select * from [pizza_runner].[pizza_recipes]

select pn.pizza_id,pn.pizza_name,r.toppings
from pizza_runner.pizza_names as pn
join pizza_runner.pizza_recipes as r on
	r.pizza_id=pn.pizza_id