# 🥑 Case Study #3- Foodie Fi

#### Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description 
--about each customer’s onboarding journey. Try to keep it as short as possible - you may also want to run some sort of 
--join to make your explanations a bit easier!

```sql
select s.customer_id,s.plan_id,p.plan_name,s.sstart_date
from foodie_fi.subscriptions as s
join foodie_fi.plans as p on
	p.plan_id=s.plan_id
where s.customer_id in (14,998,597,925,759,839,893,65)
```

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233-Foodie%20Fi/ss/Screenshot%20(48).png)

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233-Foodie%20Fi/ss/Screenshot%20(49).png)

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233-Foodie%20Fi/ss/Screenshot%20(50).png)

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233-Foodie%20Fi/ss/Screenshot%20(51).png)
