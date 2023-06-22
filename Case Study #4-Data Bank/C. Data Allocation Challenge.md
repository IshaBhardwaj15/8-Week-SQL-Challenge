# 🏦 Case Study #4- Data Bank

#### running customer balance column that includes the impact each transaction

```sql
WITH monthly_balances AS
(
	SELECT *,month(txn_date) AS txn_month,
		SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END) AS net_txn
	FROM data_bank.customer_transactions
	GROUP BY customer_id,txn_date,txn_type,txn_amount,txn_date
),
running_balance AS
(
	SELECT customer_id,txn_date,txn_month,txn_type,txn_amount,
          sum(net_txn) over(PARTITION BY customer_id ORDER BY txn_month 
					ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) AS running_balance
   FROM monthly_balances
   GROUP BY customer_id,txn_month,txn_date,txn_type,txn_amount,net_txn
)
select * from running_balance;
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(94).png)

***

#### customer balance at the end of each month

```sql
WITH monthly_balances AS
(
	SELECT customer_id,month(txn_date) AS txn_month,
		SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END) AS net_txn
	FROM data_bank.customer_transactions
	GROUP BY customer_id,month(txn_date)
	--order by customer_id
),
running_balance AS
(
	SELECT customer_id,txn_month,
          sum(net_txn) over(PARTITION BY customer_id ORDER BY txn_month 
					ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) AS running_balance
   FROM monthly_balances
   GROUP BY customer_id,txn_month,net_txn
),
month_end_balances_cte AS
(
	select *,LAST_VALUE(running_balance) over(partition by customer_id order by txn_month) as month_end_balance
	from running_balance
	group by customer_id,txn_month,running_balance
)
select customer_id,txn_month,month_end_balance
from month_end_balances_cte;
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(95).png)

***

#### minimum, average and maximum values of the running balance for each customer

```sql
WITH monthly_balances AS
(
	SELECT *,month(txn_date) AS txn_month,
		SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END) AS net_txn
	FROM data_bank.customer_transactions
	GROUP BY customer_id,txn_date,txn_type,txn_amount,txn_date
),
running_balance AS
(
	SELECT customer_id,txn_date,txn_month,txn_type,txn_amount,
          sum(net_txn) over(PARTITION BY customer_id ORDER BY txn_month 
					ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) AS running_balance
   FROM monthly_balances
   GROUP BY customer_id,txn_month,txn_date,txn_type,txn_amount,net_txn
)
SELECT customer_id,min(running_balance)as minimum,max(running_balance) as maximum,
       round(avg(running_balance), 2) AS average
FROM running_balance
GROUP BY customer_id
ORDER BY customer_id;
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(96).png)

***

#### Option 1: data is allocated based off the amount of money at the end of the previous month

```sql
WITH monthly_balances AS
(
	SELECT customer_id,month(txn_date) AS txn_month,
		SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END) AS net_txn
	FROM data_bank.customer_transactions
	GROUP BY customer_id,month(txn_date)
	--order by customer_id
),
running_balance AS
(
	SELECT customer_id,txn_month,net_txn,
          sum(net_txn) over(PARTITION BY customer_id ORDER BY txn_month 
					ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) AS running_balance
   FROM monthly_balances
   GROUP BY customer_id,txn_month,net_txn
),
month_end_balances_cte AS
(
	select *,LAST_VALUE(running_balance) over(partition by customer_id order by txn_month) as month_end_balance
	from running_balance
	group by customer_id,txn_month,running_balance,net_txn
),
customer_month_end_balance AS
(
	select customer_id,txn_month,month_end_balance
	from month_end_balances_cte
)
select txn_month,SUM(CASE WHEN month_end_balance>0 THEN month_end_balance ELSE 0 END) as data_required_per_month
from customer_month_end_balance
group by txn_month
order by txn_month;
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(97).png)

***

#### Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days

```sql
WITH monthly_balances AS
(
	SELECT *,month(txn_date) AS txn_month,
		SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END) AS net_txn
	FROM data_bank.customer_transactions
	GROUP BY customer_id,txn_date,txn_type,txn_amount,txn_date
),
running_balance AS
(
	SELECT customer_id,txn_date,txn_month,txn_type,txn_amount,net_txn,
          sum(net_txn) over(PARTITION BY customer_id ORDER BY txn_month 
					ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) AS running_balance
   FROM monthly_balances
   GROUP BY customer_id,txn_month,txn_date,txn_type,txn_amount,net_txn
),
average_running_balance as
(
	SELECT customer_id,txn_month,round(avg(running_balance), 2) AS average
	FROM running_balance
	GROUP BY customer_id,txn_month,net_txn
)
select txn_month,sum(CASE WHEN average>0 THEN average ELSE 0 END) as data_required_per_month
from average_running_balance
group by txn_month
order by txn_month;
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(98).png)

***

#### Option 3: data is updated real-time

```sql
WITH monthly_balances AS
(
	SELECT *,month(txn_date) AS txn_month,
		SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END) AS net_txn
	FROM data_bank.customer_transactions
	GROUP BY customer_id,txn_date,txn_type,txn_amount,txn_date
),
running_balance AS
(
	SELECT customer_id,txn_date,txn_month,txn_type,txn_amount,net_txn,
          sum(net_txn) over(PARTITION BY customer_id ORDER BY txn_month 
					ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) AS running_balance
   FROM monthly_balances
   GROUP BY customer_id,txn_month,txn_date,txn_type,txn_amount,net_txn
)
select txn_month,SUM(running_balance) as data_required_per_month
from running_balance
group by txn_month
order by txn_month;
```
![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(99).png)
