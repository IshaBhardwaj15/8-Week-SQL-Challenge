# 🏦 Case Study #4- Data Bank

#### 1. What is the unique count and total amount for each transaction type?

```sql
select txn_type,count(txn_type) as unique_count,SUM(txn_amount) as total_amount
from data_bank.customer_transactions
group by txn_type;
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(90).png)

***

#### 2. What is the average total historical deposit counts and amounts for all customers?

```sql
with cte as
(
	select customer_id,count(customer_id) as cust_count,avg(txn_amount) as amount
	from data_bank.customer_transactions
	where txn_type='deposit'
	group by customer_id
)
select AVG(cust_count) as average_count, round(AVG(amount),2) as average_amount
from cte;
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(91).png)

***

#### 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

```sql
with txn_cte as
(
	select customer_id,DATEPART(month,txn_date) as txn_month,
		SUM(case when txn_type='deposit' then 0 else 1 end) as deposit_count,
		SUM(case when txn_type='purchase' then 0 else 1 end) as purchase_count,
		SUM(case when txn_type='withdrawl' then 0 else 1 end) as withdrawl_count
	from data_bank.customer_transactions
	group by customer_id,DATEPART(month,txn_date)
)
select txn_month,COUNT(distinct customer_id) as cust_count
from txn_cte
where deposit_count>1 and (purchase_count>=1 or withdrawl_count>=1)
group by txn_month;
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(92).png)

***

#### 4. What is the closing balance for each customer at the end of the month?

```sql
WITH monthly_balances_cte AS
(
	select customer_id, DATEPART(month,txn_date) as txn_month,
		SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END) as net_txn
	from data_bank.customer_transactions
	group by customer_id,DATEPART(month,txn_date)
)
select customer_id, txn_month, net_txn,
	SUM(net_txn) over(partition by customer_id order by txn_month 
						rows between unbounded preceding and current row) as closing_balance
from monthly_balances_cte;
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234-Data%20Bank/ss/Screenshot%20(93).png)
