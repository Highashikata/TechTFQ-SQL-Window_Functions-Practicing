--- Checking the tables
select * from product;


--- Fetching the most expensive product under each category
SELECT *,
       First_value(product_name)
         OVER(
           partition BY product_category
           ORDER BY price DESC) most_expensive_product
FROM   product; 



--- Displaying the least expensive product under each category 

SELECT *,
       Last_value(product_name)
         OVER(
           partition BY product_category
           ORDER BY price)
FROM   product;



---- Using the FRAME CLAUSE
SELECT *,
       Last_value(product_name)
         OVER(
           partition BY product_category
           ORDER BY price range between unbounded preceding and current row) AS heapest_product
FROM   product;



SELECT *,
       Last_value(product_name)
         OVER(
           partition BY product_category
           ORDER BY price range between unbounded preceding and unbounded following) AS heapest_product
FROM   product;



----- 

SELECT *,
       First_value(product_name) OVER(PARTITION BY product_category
                                      ORDER BY price DESC) AS most_expensive_product,
       last_value(product_name) OVER(PARTITION BY product_category
                                     ORDER BY price RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS heapest_product,
       last_value(product_name) OVER(PARTITION BY product_category
                                     ORDER BY price RANGE BETWEEN 3 PRECEDING an 2 FOLLOWING)
FROM product;



---- Alternative way to write window function; using the factorizing WINDOW

Select * from product;

SELECT   *,
         first_value(product_name) OVER wid AS most_expensive_prodct ,
         lead(product_name) OVER wid        AS following_most_expensive_prod,
		 lag(product_name) OVER wid        AS previous_most_expensive_prod,
		 Nth_value(product_name, 2) over wid as second_most_expensive_prodct,
		 Nth_value(product_name, 3) over wid as third_most_expensive_prodct
FROM     product window wid                 AS (partition BY product_category ORDER BY price 
											  	range BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED following);
												
												
--- For this query, whe're going to change the frame clause to see the impact on the last and Nth values
SELECT   *,
         first_value(product_name) OVER wid AS most_expensive_prodct ,
         lead(product_name) OVER wid        AS following_most_expensive_prod,
		 lag(product_name) OVER wid        AS previous_most_expensive_prod,
		 Nth_value(product_name, 2) over wid as second_most_expensive_prodct,
		 Nth_value(product_name, 3) over wid as third_most_expensive_prodct
FROM     product window wid                 AS (partition BY product_category ORDER BY price 
											  	range BETWEEN UNBOUNDED PRECEDING AND current row);




------ Using the window function NTILE: we want to segregate al the expensive phones, mid range phones and the cheaper phones

SELECT *,
       Ntile(3)
         OVER(
           ORDER BY price DESC) AS Price_Buckets
FROM   product
WHERE  product_category = 'Phone';

--- we're going to add Bucket names for each group

SELECT x.*,
       CASE
         WHEN price_buckets = 1 THEN 'Expensive Phones'
         WHEN price_buckets = 2 THEN 'Mid Range Phones'
         WHEN price_buckets = 3 THEN 'Cheaper Phones'
         ELSE 'Not specified'
       END AS Bucket_Names
FROM   (SELECT *,
               Ntile(3)
                 OVER(
                   ORDER BY price DESC) AS Price_Buckets
        FROM   product
        WHERE  product_category = 'Phone') AS x;


---- Usigng the temporary table

WITH cte
     AS (SELECT *,
                Ntile(3)
                  OVER(
                    ORDER BY price DESC) AS price_buckets
         FROM   product
         WHERE  product_category = 'Phone')
SELECT *,
       CASE
         WHEN price_buckets = 1 THEN 'Expensive Phones'
         WHEN price_buckets = 2 THEN 'Mid Range Phones'
         WHEN price_buckets = 3 THEN 'Cheaper Phones'
         ELSE 'Not specified'
       END AS Bucket_Names
FROM   cte;


----

select * from sales;

SELECT *,
       Cume_dist()
         over (
           ORDER BY price DESC) AS cume_distribution,
       Round(Cume_dist()
               over (
                 ORDER BY price DESC) :: NUMERIC * 100, 2) AS cume_dist_percent
FROM   sales;


-- Fetching all the prodcts which are constituting the 1st 30% o the data in products based on price

select * from sales;


select *, 
	product_name, 
	cume_dist_percent || '' || '%' 
	from (
	select *, 
	  cume_dist() over(order by price desc) as cumulative_dist, 
	  round(cume_dist() over(order by price desc):: numeric*100, 2) as cume_dist_percent 
	from sales) x  
where cume_dist_percent <= 30;



----- Using the function PERCENT_RANK()

select *, 
	  cume_dist() over(order by price desc) as cumulative_dist,
	  PERCENT_rank() over(order by price desc) as pe_rank
from sales;


