**Schema (MySQL v8)**

    CREATE SCHEMA dannys_diner;
    
    CREATE TABLE dannys_diner.sales (
      `customer_id` VARCHAR(1),
      `order_date` DATE,
      `product_id` INTEGER
    );
    
    INSERT INTO dannys_diner.sales
      (`customer_id`, `order_date`, `product_id`)
    VALUES
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
      ('C', '2021-01-07', '3');
    
    CREATE TABLE dannys_diner.menu (
      `product_id` INTEGER,
      `product_name` VARCHAR(5),
      `price` INTEGER
    );
    
    INSERT INTO dannys_diner.menu
      (`product_id`, `product_name`, `price`)
    VALUES
      ('1', 'sushi', '10'),
      ('2', 'curry', '15'),
      ('3', 'ramen', '12');
    
    CREATE TABLE dannys_diner.members (
      `customer_id` VARCHAR(1),
      `join_date` DATE
    );
    
    INSERT INTO dannys_diner.members
      (`customer_id`, `join_date`)
    VALUES
      ('A', '2021-01-07'),
      ('B', '2021-01-09');

---

**Query #1**

    /* --------------------
       Case Study Questions
       --------------------*/
    -- 1. What is the total amount each customer spent at the restaurant?
    select s.customer_id , sum(m.price) as spent 
    from dannys_diner.sales as s inner join dannys_diner.menu as m on 
    m.product_id = s.product_id 
    group by s.customer_id 
    order by spent desc;

| customer_id | spent |
| ----------- | ----- |
| A           | 76    |
| B           | 74    |
| C           | 36    |

---
**Query #2**

    -- 2. How many days has each customer visited the restaurant?
    select customer_id , count(distinct order_date) as days from 
    dannys_diner.sales group by customer_id;

| customer_id | days |
| ----------- | ---- |
| A           | 4    |
| B           | 6    |
| C           | 2    |

---
**Query #3**

    -- 3. What was the first item from the menu purchased by each customer?
    SELECT s.customer_id,p.product_name,s.order_date
    from dannys_diner.sales AS s
    inner join dannys_diner.menu AS p 
        ON p.product_id = s.product_id
    where s.order_date = (select min(order_date) from dannys_diner.sales AS s2 
    where s2.customer_id = s.customer_id);

| customer_id | product_name | order_date |
| ----------- | ------------ | ---------- |
| A           | sushi        | 2021-01-01 |
| A           | curry        | 2021-01-01 |
| B           | curry        | 2021-01-01 |
| C           | ramen        | 2021-01-01 |
| C           | ramen        | 2021-01-01 |

---
**Query #4**

    -- 4. What is the most purchased item on the menu and how many times 
    -- was it purchased by all customers?
    select p.product_name , count(s.product_id) as orders from 
    dannys_diner.sales as s inner join dannys_diner.menu as p 
    on p.product_id = s.product_id 
    group by p.product_name 
    order by orders desc limit 1;

| product_name | orders |
| ------------ | ------ |
| ramen        | 8      |

---
**Query #5**

    -- 5. Which item was the most popular for each customer?
    with base as (select s.customer_id , m.product_name,count(m.product_id) as orders from 
    dannys_diner.sales as s inner join dannys_diner.menu as m on m.product_id = s.product_id 
    group by s.customer_id , m.product_name )
    select * from (select customer_id , product_name ,orders, 
    dense_rank()over(partition by customer_id order by orders desc) as rankings from base) as t 
     where rankings = 1 ;

| customer_id | product_name | orders | rankings |
| ----------- | ------------ | ------ | -------- |
| A           | ramen        | 3      | 1        |
| B           | curry        | 2      | 1        |
| B           | sushi        | 2      | 1        |
| B           | ramen        | 2      | 1        |
| C           | ramen        | 3      | 1        |

---
**Query #6**

    -- 6. Which item was purchased first by the customer after they became a member?
    with base as (
      select s.customer_id , p.product_name , s.order_date , m.join_date from
      dannys_diner.sales as s inner join dannys_diner.menu as p
      on p.product_id = s.product_id 
      inner join dannys_diner.members as m 
      on m.customer_id = s.customer_id 
    where s.order_date >= m.join_date)
    select b.customer_id , b.product_name from base as b
    where b.order_date = (select min(b1.order_date) from base as b1 
                          where b1.customer_id = b.customer_id);

| customer_id | product_name |
| ----------- | ------------ |
| B           | sushi        |
| A           | curry        |

---
**Query #7**

    -- 7. Which item was purchased just before the customer became a member?
    
    -- Windows functions
    with base as (
      select c.customer_id , p.product_name , c.order_date , m.join_date
      from dannys_diner.sales as c inner join dannys_diner.menu as p 
      on p.product_id = c.product_id 
      inner join dannys_diner.members as m 
      on m.customer_id = c.customer_id
      where c.order_date < m.join_date)
    select b.customer_id , b.product_name 
    from base as b 
    where b.order_date = (select max(b1.order_date) from base as b1
                          where b1.customer_id = b.customer_id);

| customer_id | product_name |
| ----------- | ------------ |
| B           | sushi        |
| A           | sushi        |
| A           | curry        |

---
**Query #8**

    -- Subquery method                      
    select c.customer_id , p.product_name 
      from dannys_diner.sales as c inner join dannys_diner.menu as p 
      on p.product_id = c.product_id 
      inner join dannys_diner.members as m 
      on m.customer_id = c.customer_id
      where c.order_date < m.join_date and 
    (c.order_date = (select max(c1.order_date) from 
                     dannys_diner.sales as c1 
                     where c1.customer_id = c.customer_id and 
                     c1.order_date < m.join_date));

| customer_id | product_name |
| ----------- | ------------ |
| B           | sushi        |
| A           | sushi        |
| A           | curry        |

---
**Query #9**

    -- 8. What is the total items and amount spent for each member before they became a member?
    
    -- Total_quantity 
    select s.customer_id , count( p.product_id) as items ,
    sum(p.price) as spend from 
    dannys_diner.sales as s inner join dannys_diner.menu as p 
    on p.product_id = s.product_id 
    inner join dannys_diner.members as m 
    on m.customer_id = s.customer_id 
    where s.order_date < m.join_date 
    group by s.customer_id ;

| customer_id | items | spend |
| ----------- | ----- | ----- |
| B           | 3     | 40    |
| A           | 2     | 25    |

---
**Query #10**

    -- Unique items
    select s.customer_id , count(distinct p.product_id) as items ,
    sum(p.price) as spend from 
    dannys_diner.sales as s inner join dannys_diner.menu as p 
    on p.product_id = s.product_id 
    inner join dannys_diner.members as m 
    on m.customer_id = s.customer_id 
    where s.order_date < m.join_date 
    group by s.customer_id ;

| customer_id | items | spend |
| ----------- | ----- | ----- |
| A           | 2     | 25    |
| B           | 2     | 40    |

---
**Query #11**

    -- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier -
    -- how many points would each customer have?
    
    select c.customer_id , sum(p.price) as spend ,
    (sum(case when p.product_name = 'sushi' 
    then p.price*20 else p.price*10 end)) as multipler_spend from 
    dannys_diner.sales as c inner join dannys_diner.menu as p 
    on p.product_id = c.product_id
    group by c.customer_id ;

| customer_id | spend | multipler_spend |
| ----------- | ----- | --------------- |
| A           | 76    | 860             |
| B           | 74    | 940             |
| C           | 36    | 360             |

---
**Query #12**

    -- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
    select s.customer_id , 
    sum(p.price) as spend ,
    sum(
      case when s.order_date >= m.join_date and 
      s.order_date <= (date_add(m.join_date , interval 6 day))
      then price * 20
      when p.product_name = 'sushi'
      then price * 20 
      else price * 10 end) as multipler_spend
    from dannys_diner.sales as s inner join dannys_diner.menu as p 
    on p.product_id = s.product_id 
    inner join dannys_diner.members as m
     on m.customer_id = s.customer_id 
    where (s.order_date >= m.join_date)
    and (month(s.order_date) = 1)group by s.customer_id;

| customer_id | spend | multipler_spend |
| ----------- | ----- | --------------- |
| B           | 22    | 320             |
| A           | 51    | 1020            |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/2rM8RAnq7h5LLDTzZiRWcd/11132)