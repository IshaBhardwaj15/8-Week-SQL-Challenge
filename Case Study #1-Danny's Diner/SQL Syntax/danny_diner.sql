--Created database called "danny_diner" and now all the queries will be in danny_diner database
use danny_diner
go

--Created a schema called "danny_diner" and now the tables will be created in danny_diner schema
create schema danny_diner
go

--Creating table sales
create table danny_diner.sales
(
	customer_id varchar(1),
	order_date date,
	product_id int
)

--Inserting data in table sales 
insert into danny_diner.sales
(customer_id,order_date,product_id)
values
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3')

--Creating table menu
CREATE TABLE danny_diner.menu 
(
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
)

--Inserting data in table menu
INSERT INTO danny_diner.menu
(product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12')
  
--Creating table members
CREATE TABLE danny_diner.members 
(
  customer_id VARCHAR(1),
  join_date DATE
)

--Inserting data in table members
INSERT INTO danny_diner.members
(customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09')

--Checking how each table looks like
select * from danny_diner.members
select * from danny_diner.menu
select * from danny_diner.sales

--Query 1 What is the total amount each customer spent at the restaurant?

select sales.customer_id,sum(menu.price) as total_amount
from danny_diner.sales as sales
join danny_diner.menu as menu
	on menu.product_id=sales.product_id
group by sales.customer_id

--Query2 How many days has each customer visited the restaurant?

select customer_id,count(distinct(order_date)) as visits
from danny_diner.sales
group by danny_diner.sales.customer_id

--Query 3 What was the first item from the menu purchased by each customer?

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

--Query 4 What is the most purchased item on the menu and how many times was it purchased by all customers?

select top 1(count(sales.product_id)) as most_purchased,menu.product_name
from danny_diner.sales as sales
join danny_diner.menu as menu
	on menu.product_id=sales.product_id
group by sales.product_id,menu.product_name
order by most_purchased desc

--Query 5 Which item was the most popular for each customer?

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

--Query 6 Which item was purchased first by the customer after they became a member?

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

--Query 7 Which item was purchased just before the customer became a member?

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

--Query 8 What is the total items and amount spent for each member before they became a member?

select sales.customer_id,count(distinct(sales.product_id)) as item,sum(menu.price) as total_sales
from danny_diner.sales as sales
join danny_diner.members as members
	on members.customer_id=sales.customer_id
join danny_diner.menu as menu
	on menu.product_id=sales.product_id
where sales.order_date<members.join_date
group by sales.customer_id

--Query 9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

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

--Query 10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
--not just sushi - how many points do customer A and B have at the end of January? 

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

--Bonus Question Join All The Things

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

--Bonus Question Rank all the things

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

select *, case
   when member='N' then NULL
   else
      RANK() over(partition by customer_id,member
      order by order_date) end as ranking
from cte