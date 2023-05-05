# 🍜 Case Study #1: Danny's Diner

### 1. What is the total amount each customer spent at the restaurant?

````sql
select sales.customer_id,sum(menu.price) as total_amount
from danny_diner.sales as sales
join danny_diner.menu as menu
	on menu.product_id=sales.product_id
group by sales.customer_id
````

#### Steps:
- Use **sum** and **group by** to find out ```total_amount``` contributed by each customer.
- Use **join** to merge ```sales``` and ```menu``` tables as ```customer_id``` and ```price``` are from both tables.

#### Answer:
| customer_id | total_amount |
| ----------- | ------------ |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

***

### 2. How many days has each customer visited the restaurant?

````sql
select customer_id,count(distinct(order_date)) as visits
from danny_diner.sales
group by danny_diner.sales.customer_id
````

#### Steps:
- Use **distinct** and wrap with **count** to find out the ```visits``` for each customer.
- If we do not use **distinct** on ```order_date```, the number of days may be repeated. For example, if Customer A visited the restaurant twice on '2021–01–07', then number of days is counted as 2 days instead of 1 day.

#### Answer:
| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
with order_cte as
(
	select customer_id,order_date,product_name,
		DENSE_RANK() over(partition by sales.customer_id order by sales.order_date) as rank
	from [danny_diner].[sales] as sales
	join [danny_diner].[menu] as menu
		on menu.product_id=sales.product_id
)
select customer_id,product_name
from order_cte
where rank=1
group by customer_id,product_name
````

#### Steps:
- Create a temp table ```order_cte``` and use **Windows function** with **DENSE_RANK** to create a new column ```rank``` based on ```order_date```.
- Instead of **ROW_NUMBER** or **RANK**, use **DENSE_RANK** as ```order_date``` is not time-stamped hence, there is no sequence as to which item is ordered first if 2 or more items are ordered on the same day.
- Subsequently, **group by** all columns to show ```rank = 1``` only.

#### Answer:
| customer_id | product_name | 
| ----------- | ----------- |
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

- Customer A's first orders are curry and sushi.
- Customer B's first order is curry.
- Customer C's first order is ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
select top 1(count(sales.product_id)) as most_purchased,menu.product_name
from danny_diner.sales as sales
join danny_diner.menu as menu
	on menu.product_id=sales.product_id
group by sales.product_id,menu.product_name
order by most_purchased desc
````

#### Steps:
- **count** number of ```product_id``` and **order by** ```most_purchased``` by descending order. 
- Then, use **top 1** to filter highest number of purchased item.

#### Answer:
| most_purchased | product_name | 
| ----------- | ----------- |
| 8       | ramen |


- Most purchased item on the menu is ramen which is purchased 8 times by all the customers.

***

### 5. Which item was the most popular for each customer?

````sql
with fav_item_cte as
(
   select sales.customer_id,menu.product_name,count(sales.product_id) as order_count,
      DENSE_RANK() over(partition by sales.customer_id order by count(sales.product_id) desc) as rank
   FROM danny_diner.menu as menu
   JOIN danny_diner.sales as sales
      on menu.product_id=sales.product_id
   group by sales.customer_id,menu.product_name
)
select customer_id,product_name
from fav_item_cte 
where rank = 1
````

#### Steps:
- Create a ```fav_item_cte``` and use **DENSE_RANK** to ```rank``` the ```order_count``` for each product by descending order for each customer.
- Generate results where product ```rank = 1``` only as the most popular product for each customer.

#### Answer:
| customer_id | product_name | order_count |
| ----------- | ---------- |------------  |
| A           | ramen        |  3   |
| B           | sushi        |  2   |
| B           | curry        |  2   |
| B           | ramen        |  2   |
| C           | ramen        |  3   |

- Customer A and C's favourite item is ramen.
- Customer B enjoys all items on the menu.

***

### 6. Which item was purchased first by the customer after they became a member?

````sql
with members_cte as
(
	select sales.customer_id,sales.order_date,members.join_date,sales.product_id,
		DENSE_RANK() over(partition by sales.customer_id order by sales.order_date) as rank
	from danny_diner.sales as sales
	join danny_diner.members as members
		on members.customer_id=sales.customer_id
	where sales.order_date>=members.join_date
)
select customer_id,order_date,menu.product_name
from members_cte
join danny_diner.menu as menu
	on menu.product_id=members_cte.product_id
where rank=1
````

#### Steps:
- Create ```member_cte``` by using **windows function** and partitioning ```customer_id``` by ascending ```order_date```. Then, filter ```order_date``` to be on or after ```join_date```.
- Then, filter table by ```rank = 1``` to show 1st item purchased by each customer.

#### Answer:
| customer_id | order_date  | product_name |
| ----------- | ---------- |----------  |
| A           | 2021-01-07 | curry        |
| B           | 2021-01-11 | sushi        |

- Customer A's first order as member is curry.
- Customer B's first order as member is sushi.

***

### 7. Which item was purchased just before the customer became a member?

````sql
with members_cte as
(
	select sales.customer_id,sales.order_date,members.join_date,sales.product_id,
		DENSE_RANK() over(partition by sales.customer_id order by sales.order_date desc) as rank
	from danny_diner.sales as sales
	join danny_diner.members as members
		on members.customer_id=sales.customer_id
	where sales.order_date<members.join_date
)
select customer_id,order_date,menu.product_name
from members_cte
join danny_diner.menu as menu
	on menu.product_id=members_cte.product_id
where rank=1
````

#### Steps:
- Create a ```member_cte``` to create new column ```rank``` by using **Windows function** and partitioning ```customer_id``` by descending ```order_date``` to find out the last ```order_date``` before customer becomes a member.
- Filter ```order_date``` before ```join_date```.

#### Answer:
| customer_id | order_date  | product_name |
| ----------- | ---------- |----------  |
| A           | 2021-01-01 |  sushi        |
| A           | 2021-01-01 |  curry        |
| B           | 2021-01-04 |  sushi        |

- Customer A’s last order before becoming a member is sushi and curry.
- For Customer B, it's sushi.

***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
select sales.customer_id,count(distinct(sales.product_id)) as item,sum(menu.price) as total_sales
from danny_diner.sales as sales
join danny_diner.members as members
	on members.customer_id=sales.customer_id
join danny_diner.menu as menu
	on menu.product_id=sales.product_id
where sales.order_date<members.join_date
group by sales.customer_id
````

#### Steps:
- Filter ```order_date``` before ```join_date``` and perform a **count** **distinct** on ```product_id``` and **sum** the ```total_sales``` before becoming member.

#### Answer:
| customer_id | item | total_sales |
| ----------- | ---- |------------ |
| A           | 2 |  25       |
| B           | 2 |  40       |

Before becoming members,
- Customer A spent $ 25 on 2 items.
- Customer B spent $40 on 2 items.

***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

````sql
with menu_cte as
(
	select *,
		case
			when product_id=1 then price*20
			else price*10
		end as Points
	from danny_diner.menu
)
select sales.customer_id,sum(cte.Points) as total_points
from menu_cte as cte
join danny_diner.sales as sales
	on sales.product_id=cte.product_id
group by sales.customer_id
````

#### Steps:
- Each $1 spent=10 points.
- But, sushi gets 2x points, meaning each $1 spent=20 points
So, we use case when to create conditional statements
- If product_id=1, then every $1 price multiply by 20 points
- All other product_id that is not 1, multiply $1 by 10 points
Using ```toatl_points```, **sum** the ```Points```.

#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 860 |
| B           | 940 |
| C           | 360 |

- Total points for Customer A is 860.
- Total points for Customer B is 940.
- Total points for Customer C is 360.

***

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

````sql
with dates_cte as
(
	select *,
		DATEADD(day,6,join_date) as valid_date,
		EOMONTH('2021-01-31') as last_date
	from danny_diner.members as members
)
select dates.customer_id,
	sum(case
			when menu.product_name='sushi' then 2*10*menu.price
			when sales.order_date between dates.join_date and dates.valid_date then 2*10*menu.price
			else 10*menu.price
		end) as points
from dates_cte as dates
join danny_diner.sales as sales
	on dates.customer_id=sales.customer_id
join danny_diner.menu as menu
	on sales.product_id=menu.product_id
where sales.order_date<dates.last_date
group by dates.customer_id
````

#### Steps:
- In ```dates_cte```, find out customer’s ```valid_date``` (which is 6 days after ```join_date``` and inclusive of ```join_date```) and ```last_day``` of Jan 2021 (which is ‘2021–01–31’).

Our assumptions are:
- On Day -X to Day 1 (customer becomes member on Day 1 ```join_date```), each $1 spent is 10 points and for sushi, each $1 spent is 20 points.
- On Day 1 ```join_date``` to Day 7 ```valid_date```, each $1 spent for all items is 20 points.
- On Day 8 to ```last_day``` of Jan 2021, each $1 spent is 10 points and sushi is 2x points.

#### Answer:
| customer_id | points | 
| ----------- | ------ |
| A           | 1370 |
| B           | 820 |

- points for Customer A is 1370.
- points for Customer B is 820.

***

## BONUS QUESTIONS

### Join All The Things 
````sql
select sales.customer_id,sales.order_date,menu.product_name,menu.price,
	(case
		when members.join_date>sales.order_date then 'N'
		when members.join_date<=sales.order_date then 'Y'
		else 'N'
	end) as member
from danny_diner.sales as sales
left join danny_diner.menu as menu
	on sales.product_id=menu.product_id
left join danny_diner.members as members
	on sales.customer_id=members.customer_id
 ````
 
#### Answer: 
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | -------------| ----- | ------ |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

***

### Rank All The Things

````sql
with cte as 
(
	select sales.customer_id,sales.order_date,menu.product_name,menu.price,
		case
			when members.join_date>sales.order_date then 'N'
			when members.join_date<=sales.order_date then 'Y'
			else 'N' 
		end as member
	from danny_diner.sales as sales
  LEFT JOIN danny_diner.menu as menu
      on sales.product_id=menu.product_id
  LEFT JOIN danny_diner.members as members
      on sales.customer_id=members.customer_id
)
````

#### Answer: 
| customer_id | order_date | product_name | price | member | ranking | 
| ----------- | ---------- | -------------| ----- | ------ |-------- |
| A           | 2021-01-01 | sushi        | 10    | N      | NULL
| A           | 2021-01-01 | curry        | 15    | N      | NULL
| A           | 2021-01-07 | curry        | 15    | Y      | 1
| A           | 2021-01-10 | ramen        | 12    | Y      | 2
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| B           | 2021-01-01 | curry        | 15    | N      | NULL
| B           | 2021-01-02 | curry        | 15    | N      | NULL
| B           | 2021-01-04 | sushi        | 10    | N      | NULL
| B           | 2021-01-11 | sushi        | 10    | Y      | 1
| B           | 2021-01-16 | ramen        | 12    | Y      | 2
| B           | 2021-02-01 | ramen        | 12    | Y      | 3
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-07 | ramen        | 12    | N      | NULL


***
