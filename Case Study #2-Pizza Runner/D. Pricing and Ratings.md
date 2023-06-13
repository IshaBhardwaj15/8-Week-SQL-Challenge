# :pizza: Pricing and Ratings

#### 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 

- how much money has Pizza Runner made so far if there are no delivery fees?

````sql
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
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(25).png)

#### 2. What if there was an additional $1 charge for any pizza extras?

- Add cheese is $1 extra

````sql
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
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(26).png)

#### 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 

- how would you design an additional table for this new dataset - generate a schema for this new table and insert your own

- data for ratings for each successful customer order between 1 to 5.

````sql
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
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(27).png)

#### 4. Using your newly generated table - can you join all of the information together to form a table which has the 
- following information for successful deliveries?
- customer_id
- order_id
- runner_id
- rating
- order_time
- pickup_time
- Time between order and pickup
- Delivery duration
- Average speed
- Total number of pizzas

````sql
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
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(28).png)

#### 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is 

- paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

````sql
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
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(29).png)
