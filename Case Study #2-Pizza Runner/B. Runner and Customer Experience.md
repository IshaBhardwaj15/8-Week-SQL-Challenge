# :pizza: B. Runner and Customer Experience

#### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

````sql
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
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(13).png)

#### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

````sql
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
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(14).png)

#### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
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
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(15).png)

#### 4. What was the average distance travelled for each customer?

````sql
Select c.customer_id,round(avg(r.distance),2) as Avg_distance
from #customer_orders as c
join #runner_orders as r on
	r.order_id=c.order_id
where r.cancellation=''
group by c.customer_id
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(16).png)

#### 5. What was the difference between the longest and shortest delivery times for all orders?

```sql
select max(duration)-min(duration) as Difference_in_delivery
from #runner_orders
where duration!=0
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(17).png)

#### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql
select runner_id,round((distance/duration*60),2) as avg_speed
from #runner_orders
where cancellation=''
group by runner_id,duration,distance
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(18).png)

#### 7. What is the successful delivery percentage for each runner?

````sql
select runner_id,count(order_id) as Successful_delivery
from #runner_orders
where cancellation=''
group by runner_id
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(19).png)
