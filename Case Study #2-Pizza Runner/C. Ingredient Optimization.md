# :pizza: Case Study #2: Pizza Runner

#### Creating some temporary tables that we will use in further queries

- splitting each string in extras and exclusions so that each of the elements is seen in individual rows

````sql
select c.order_id,c.customer_id,c.pizza_id,pn.pizza_name,exc.value as exclusions,ext.value as extras,c.order_time
	into #customer_orders_split
	from #customer_orders as c
	cross apply string_split(c.exclusions,',') as exc
	cross apply string_split(c.extras,',') as ext
	join pizza_runner.pizza_names as pn on
		pn.pizza_id=c.pizza_id
````

- seeing how our temporary table looks like

````sql
select * from #customer_orders_split
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(20).png)

#### 1. What are the standard ingredients for each pizza?

````sql
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
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(21).png)

#### 2. What was the most commonly added extra?

````sql
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
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(22).png)

#### 3. What was the most common exclusion?

````sql
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
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(23).png)

#### 4. Generate an order item for each record in the customers_orders table in the format of one of the following:

- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

````sql
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
````

![image](https://github.com/IshaBhardwaj15/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232-Pizza%20Runner/ss/Screenshot%20(24).png)
