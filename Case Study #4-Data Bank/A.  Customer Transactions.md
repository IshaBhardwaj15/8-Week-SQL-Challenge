# 🏦 Case Study #4- Data Bank

#### 1. How many unique nodes are there on the Data Bank system?

```sql
select COUNT(distinct(node_id)) as unique_nodes
from data_bank.customer_nodes
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(83).png)

***

#### 2. What is the number of nodes per region?

```sql
select region_id,COUNT(node_id) as nodes_count
from data_bank.customer_nodes
group by region_id
order by region_id
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(84).png)

***

#### 3. How many customers are allocated to each region?

```sql
select region_id,COUNT(distinct customer_id) as customer_count
from data_bank.customer_nodes
group by region_id
order by region_id
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(85).png)

***

#### 4. How many days on average are customers reallocated to a different node?

```sql
select avg(DATEDIFF(day,start_date,end_date))as average_days
from data_bank.customer_nodes
where end_date!='9999-12-31';
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(86)1.png)

***

#### 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

- median

```sql
with median as
(
	select n.customer_id,n.region_id,r.region_name,n.node_id,n.start_date,n.end_date,
		DATEDIFF(day,n.start_date,n.end_date) as reallocation_days
	from data_bank.customer_nodes as n
	join data_bank.regions as r on
		r.region_id=n.region_id
	where n.end_date!='9999-12-31'
)
select distinct region_id,region_name,PERCENTILE_CONT(0.5)
								within group(order by reallocation_days)
								over(partition by region_id) as median
from median;
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(87).png)

***

- 80th percentile

```sql
with eightyth_cte as
(
	select n.customer_id,n.region_id,r.region_name,n.node_id,n.start_date,n.end_date,
		DATEDIFF(day,n.start_date,n.end_date) as reallocation_days
	from data_bank.customer_nodes as n
	join data_bank.regions as r on
		r.region_id=n.region_id
	where n.end_date!='9999-12-31'
)
select distinct region_id,region_name,PERCENTILE_CONT(0.80)
								within group(order by reallocation_days)
								over(partition by region_id) as eightyth_percentile
from eightyth_cte;
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(88).png)

***

- 95th percentile

```sql
with nintyfifth_cte as
(
	select n.customer_id,n.region_id,r.region_name,n.node_id,n.start_date,n.end_date,
		DATEDIFF(day,n.start_date,n.end_date) as reallocation_days
	from data_bank.customer_nodes as n
	join data_bank.regions as r on
		r.region_id=n.region_id
	where n.end_date!='9999-12-31'
)
select distinct region_id,region_name,PERCENTILE_CONT(0.95)
								within group(order by reallocation_days)
								over(partition by region_id) as nintyfifth_percentile
from nintyfifth_cte;
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(89).png)
