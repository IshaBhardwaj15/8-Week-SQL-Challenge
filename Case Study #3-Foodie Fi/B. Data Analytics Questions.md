# 🥑 B. Data Analysis Questions

#### 1. How many customers has Foodie-Fi ever had?

```sql
select COUNT(distinct(customer_id)) as No_of_Customers
from foodie_fi.subscriptions
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233-Foodie%20Fi/ss/Screenshot%20(52).png)

***

#### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

```sql
select DATEPART(month,s.sstart_date) as month_number,
	   FORMAT(s.sstart_date,'MMMM') as month_name,
       COUNT(*) as trials
from foodie_fi.subscriptions as s
join foodie_fi.plans as p on
	p.plan_id=s.plan_id
where s.plan_id=0
group by DATEPART(month,s.sstart_date),
	     FORMAT(s.sstart_date,'MMMM')
order by month_number
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233-Foodie%20Fi/ss/Screenshot%20(53).png)

***

#### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

```sql
select s.plan_id,p.plan_name,count(*) as events_after_2020
from foodie_fi.subscriptions as s
join foodie_fi.plans as p on
	p.plan_id=s.plan_id
where YEAR(s.sstart_date)>2020
group by s.plan_id,p.plan_name
order by s.plan_id
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233-Foodie%20Fi/ss/Screenshot%20(54).png)

***

#### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

```sql
select p.plan_name,COUNT(*) as Churned_Customers,
	concat(ROUND(   
		 100*COUNT(*)/
				(
				select COUNT(distinct customer_id)
				from foodie_fi.subscriptions
			    )
	       ,1),'%') as Churned_percentage
from foodie_fi.subscriptions as s
join foodie_fi.plans as p on
	p.plan_id=s.plan_id
where s.plan_id=4
group by p.plan_name
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233-Foodie%20Fi/ss/Screenshot%20(55).png)

***

#### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

```sql
with ranking as
(
	select s.customer_id,s.plan_id,p.plan_name,
		ROW_NUMBER() over(partition by s.customer_id order by s.plan_id) as plan_rank
	from foodie_fi.subscriptions as s
	join foodie_fi.plans as p on
		p.plan_id=s.plan_id
)
select COUNT(*) as churned_customers,
	concat(round(100*COUNT(*)/
		(
		select COUNT(distinct customer_id)
		from foodie_fi.subscriptions
		),0),'%') as churn_percentage_after_trial
from ranking
where plan_id=4 and plan_rank=2
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233-Foodie%20Fi/ss/Screenshot%20(56).png)

***

#### 6. What is the number and percentage of customer plans after their initial free trial?

```sql
with planss as
(
	select customer_id,plan_id,
		LEAD(plan_id,1) over(partition by customer_id order by plan_id) as lead_plans
	from foodie_fi.subscriptions
)
select lead_plans,COUNT(*) as customer_count,
	round(100*COUNT(*)/
		(select COUNT(distinct customer_id)
		from foodie_fi.subscriptions)
	,1) as cust_percentage
from planss
where lead_plans is not null and plan_id=0
group by lead_plans
order by lead_plans
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233-Foodie%20Fi/ss/Screenshot%20(57).png)

***

#### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

```sql
with planss as
(
	select s.customer_id,s.plan_id,s.sstart_date,p.plan_name,
		ROW_NUMBER() over(partition by customer_id order by sstart_date desc) as lead_date
	from foodie_fi.subscriptions as s
	join foodie_fi.plans as p on
		p.plan_id=s.plan_id
	where sstart_date<='2020-12-31'
)
select plan_id,plan_name,COUNT(customer_id) as cust_count,
	concat(ROUND(100*COUNT(customer_id)/
		(select COUNT(distinct customer_id)
		from foodie_fi.subscriptions),2),'%') as cust_percent
from planss
where lead_date=1
group by plan_id,plan_name
order by plan_id
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233-Foodie%20Fi/ss/Screenshot%20(58).png)

***

#### 8. How many customers have upgraded to an annual plan in 2020?

```sql
select COUNT(distinct s.customer_id) as customers_updated_to_pro_annual
from foodie_fi.subscriptions as s
join foodie_fi.plans as p on
	p.plan_id=s.plan_id
where s.plan_id=3 and s.sstart_date like '2020%'
group by s.plan_id,p.plan_name
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233-Foodie%20Fi/ss/Screenshot%20(59).png)

***

#### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

```sql
with trial as
(
	select customer_id,sstart_date
	from foodie_fi.subscriptions
	where plan_id=0
),
annual as
(
	select customer_id,sstart_date
	from foodie_fi.subscriptions
	where plan_id=3
)
select AVG(DATEDIFF(day,trial.sstart_date,annual.sstart_date)) as avg_conversion_days
from trial
join annual on
	trial.customer_id=annual.customer_id;
 ```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233-Foodie%20Fi/ss/Screenshot%20(60).png)

***

#### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

```sql
with trial as
(
	select customer_id,sstart_date
	from foodie_fi.subscriptions
	where plan_id=0
),
annual as
(
	select customer_id,sstart_date
	from foodie_fi.subscriptions
	where plan_id=3
),
bucket as
(
	select
		case
			when DATEDIFF(day,trial.sstart_date,annual.sstart_date)>=0 and DATEDIFF(day,trial.sstart_date,annual.sstart_date)<=30
				then '0-30 Days'
			when DATEDIFF(day,trial.sstart_date,annual.sstart_date)>30 and DATEDIFF(day,trial.sstart_date,annual.sstart_date)<=60
				then '30-60 Days'
			when DATEDIFF(day,trial.sstart_date,annual.sstart_date)>60 and DATEDIFF(day,trial.sstart_date,annual.sstart_date)<=90
				then '60-90 Days'
			when DATEDIFF(day,trial.sstart_date,annual.sstart_date)>90 and DATEDIFF(day,trial.sstart_date,annual.sstart_date)<=120
				then '90-120 Days'
			when DATEDIFF(day,trial.sstart_date,annual.sstart_date)>120 and DATEDIFF(day,trial.sstart_date,annual.sstart_date)<=150
				then '120-150 Days'
			when DATEDIFF(day,trial.sstart_date,annual.sstart_date)>150 and DATEDIFF(day,trial.sstart_date,annual.sstart_date)<=180
				then '150-180 Days'
			when DATEDIFF(day,trial.sstart_date,annual.sstart_date)>180 and DATEDIFF(day,trial.sstart_date,annual.sstart_date)<=210
				then '180-210 Days'
			when DATEDIFF(day,trial.sstart_date,annual.sstart_date)>210 and DATEDIFF(day,trial.sstart_date,annual.sstart_date)<=240
				then '210-240 Days'
			when DATEDIFF(day,trial.sstart_date,annual.sstart_date)>240 and DATEDIFF(day,trial.sstart_date,annual.sstart_date)<=270
				then '240-270 Days'
			when DATEDIFF(day,trial.sstart_date,annual.sstart_date)>270 and DATEDIFF(day,trial.sstart_date,annual.sstart_date)<=300
				then '270-300 Days'
			when DATEDIFF(day,trial.sstart_date,annual.sstart_date)>300 and DATEDIFF(day,trial.sstart_date,annual.sstart_date)<=330
				then '300-330 Days'
			when DATEDIFF(day,trial.sstart_date,annual.sstart_date)>330 and DATEDIFF(day,trial.sstart_date,annual.sstart_date)<=360
				then '330-360 Days'
			else 'NA'
		end as Bins
	from trial 
	join annual on
		trial.customer_id=annual.customer_id
)
select Bins,COUNT(*) as #Customers
from bucket
group by Bins
order by Bins
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233-Foodie%20Fi/ss/Screenshot%20(61).png)

***

#### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```sql
with ranked_cte AS (
  select s.customer_id, p.plan_id,p.plan_name, 
	  LEAD(p.plan_id) OVER (PARTITION BY s.customer_id ORDER BY s.sstart_date) AS next_plan_id
  FROM foodie_fi.subscriptions AS s
  JOIN foodie_fi.plans as p 
    ON s.plan_id = p.plan_id
 WHERE DATEPART(YEAR, sstart_date) = 2020
)
Select COUNT(customer_id) AS churned_customers
FROM ranked_cte
WHERE plan_id = 2
  AND next_plan_id = 1
  ```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233-Foodie%20Fi/ss/Screenshot%20(62).png)
