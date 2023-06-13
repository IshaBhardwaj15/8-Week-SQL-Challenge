# :pizza: Bonus Question

- If Danny wants to expand his range of pizzas - how would this impact the existing data design? 
- Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

````sql
insert into pizza_runner.pizza_names
	(pizza_id,pizza_name)
values
	(3,'Supreme')
````

````sql
select * from [pizza_runner].[pizza_names]
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(30).png)

````sql
insert into pizza_runner.pizza_recipes
	(pizza_id,toppings)
values
	(3,'1,2,3,4,5,6,7,8,9,10,11,12')
````

````sql
select * from [pizza_runner].[pizza_recipes]
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(31).png)

````sql
select pn.pizza_id,pn.pizza_name,r.toppings
from pizza_runner.pizza_names as pn
join pizza_runner.pizza_recipes as r on
	r.pizza_id=pn.pizza_id
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(32).png)
