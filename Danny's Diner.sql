/*
	Dannys Diner - Case Study 1
	This case-study SQL project is made based on the data provided in 
	this link mentioned below:
	https://8weeksqlchallenge.com/case-study-1/
	
	Steps:
	1. Create Database
	2. Create Tables and Enter Table Data
	3. Case Study Questions - Answers
	
*/


-- create database if it doesn't exists
IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'DannysDiner')
	BEGIN
		CREATE DATABASE DannysDiner
	END;

-----------------------------------------------------------------

-- create tables (table data and dataypes were provided in the website)

/*
1. Sales Table:
It captures all CustomerID level purchases with the corresponding 
OrderDate and ProductID information for when and what menu items were ordered.
*/
--CREATE TABLE DannysDiner.dbo.Sales
--(
--    CustomerId VARCHAR(1),
--    OrderDate DATE,
--	ProductID INT
--);

--INSERT INTO DannysDiner.dbo.Sales
--	VALUES
--	  ('A', '2021-01-01', '1'),
--	  ('A', '2021-01-01', '2'),
--	  ('A', '2021-01-07', '2'),
--	  ('A', '2021-01-10', '3'),
--	  ('A', '2021-01-11', '3'),
--	  ('A', '2021-01-11', '3'),
--	  ('B', '2021-01-01', '2'),
--	  ('B', '2021-01-02', '2'),
--	  ('B', '2021-01-04', '1'),
--	  ('B', '2021-01-11', '1'),
--	  ('B', '2021-01-16', '3'),
--	  ('B', '2021-02-01', '3'),
--	  ('C', '2021-01-01', '3'),
--	  ('C', '2021-01-01', '3'),
--	  ('C', '2021-01-07', '3');

/*
2. Menu Table:
It maps the ProductID to the actual ProductName and
Price of each menu item.
*/
--CREATE TABLE DannysDiner.dbo.Menu
--(
--    ProductId INT,
--    ProductName VARCHAR(5),
--	Price INT
--);

--INSERT INTO DannysDiner.dbo.Menu
--	VALUES
--	  ('1', 'sushi', '10'),
--	  ('2', 'curry', '15'),
--	  ('3', 'ramen', '12');

/*
3. Members Table:
It captures the JoinDate when a CustomerID 
joined the beta version of the Danny’s Diner loyalty program.

*/
--CREATE TABLE DannysDiner.dbo.Members
--(
--    CustomerId VARCHAR(1),
--    JoinDate DATE
--);
--INSERT INTO DannysDiner.dbo.Members
--	VALUES
--		('A', '2021-01-07'),
--		('B', '2021-01-09');


*********************************************************************

--1: What is the total amount each customer spent at the restaurant?

--A:
SELECT s.customer_id, 
       sum(m.price) as TotalSpent
FROM sales s
join menu m on m.product_id = s.product_id
GROUP BY s.customer_id


--2: How many days has each customer visited the restaurant?

--A:
SELECT s.customer_id, 
       count(distinct(s.order_date)) as TotalDays
FROM sales s
GROUP BY s.customer_id


--3: What was the first item from the menu purchased by each customer?

--A:
 SELECT * from
 (
 SELECT s.customer_id,
 	   m.product_name,
   	   row_number() over(partition by s.customer_id ORDER BY  s.order_date) rownum
 FROM sales s
 join menu m on m.product_id = s.product_id
 ) as f1
 WHERE f1.rownum = 1

--4: What is the most purchased item on the menu and how many times was it purchased by all customers?

--A:
SELECT * 
 FROM (
 ;with cte as (
 SELECT s.product_id,count(*) as Amount_Purchased 
 FROM sales s
 group by product_id 
 )
 SELECT mm.product_name,
        cte.* ,
        rank () over(order by Amount_Purchased desc ) as Rank
 FROM cte
 join menu mm on mm.product_id = cte.product_id
 )Ranking
 WHERE Rank = 1

--5: Which item was the most popular for each customer?

--A:

SELECT rn.customer_id,rn.Amount,m.product_name FROM (        
 SELECT customer_id,
        product_id,
		count(*)as Amount,
		rank() over(partition by customer_id order by count(*) desc) as rank 
FROM sales
 group by customer_id,product_id
 ) rn
 join menu m on m.product_id = rn.product_id
 WHERE rn.rank = 1 

--6: Which item was purchased first by the customer after they became a member?

--A:
 SELECT rn.customer_id,rn.order_date,m.product_name FROM (
 SELECT s.*,
        rank() over (partition by s.customer_id order by s.order_date asc) as rank
 FROM sales s
 join members m on s.customer_id = m.customer_id and s.order_date > m.join_date
 ) rn
 join menu m on m.product_id = rn.product_id
 WHERE rn.rank = 1


--7: Which item was purchased just before the customer became a member?

--A:
  SELECT rn.customer_id,
		 rn.order_date,
		 m.product_name FROM (
 SELECT s.*,
        rank() over (partition by s.customer_id order by s.order_date asc) as rank
 FROM sales s
 join members m on s.customer_id = m.customer_id and s.order_date <= m.join_date
 ) rn
 join menu m on m.product_id = rn.product_id

--8: What is the total items and amount spent for each member before they became a member?

--A:
SELECT s.customer_id, 
       count(s.product_id) as TotalItems, 
	   sum(me.price) as AmountSpent
FROM sales s
left join members m on s.customer_id = m.customer_id
join menu me on me.product_id = s.product_id
WHERE s.order_date < m.join_date OR m.join_date IS NULL
GROUP BY s.customer_id

--9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

--A:
;with cte as (
SELECT s.customer_id, 
       me.product_name, 
	   me.price,
	   case 
			when product_name in ('curry','ramen') then price*10
			else price * 20
       end as Points
FROM sales s
left join members m on s.customer_id = m.customer_id
join menu me on me.product_id = s.product_id
)
SELECT cte.customer_id,
	   sum(cte.Points) as TotalPoints
FROM cte
GROUP BY cte.customer_id

--10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January? 

--A:
;with cte as (
SELECT s.customer_id,
       s.order_date,
	   me.product_name,
	   me.price,
	   case
	       when s.order_date between m.join_date and DATEADD(day,+6, m.join_date) then me.price * 20
	   else 
		   case when product_name in ('curry','ramen') then price*10
			else price * 20
			end
       end as Points


FROM sales s
join members m on s.customer_id = m.customer_id
join menu me on me.product_id = s.product_id
)
SELECT customer_id,
       sum(cte.Points) as TotalPoints
FROM cte
GROUP BY cte.customer_id

