SELECT *
FROM sales_exercise;

-- Let’s consider store 20. What was the total (rounded) profit of this store?
SELECT SUM(Weekly_Sales) AS profit
FROM sales_exercise 
WHERE store = 20;

-- What was the total profit for department 51 (store 20)?
SELECT SUM(Weekly_Sales) AS profit
FROM sales_exercise 
WHERE store = 20
AND Dept = 51;

-- In which week did store 20 achieve a profit record (for the whole store)? How much profit did they make?
SELECT Store, Date, SUM(Weekly_Sales) AS profit
FROM sales_exercise 
WHERE store = 20
GROUP BY Date
ORDER BY PROFIT DESC;

-- Which was the worst week for store 20 (for the whole store)? How much was the profit?
SELECT Store, Date, SUM(Weekly_Sales) AS profit
FROM sales_exercise 
WHERE store = 20
GROUP BY Date
ORDER BY PROFIT ASC;

-- What is the (rounded) average of the weekly sales for store 20 (the whole store)?
SELECT Store, AVG(Weekly_Sales) AS avg_profit
FROM sales_exercise 
WHERE store = 20;

-- What are the 3 stores that have the best historical average of weekly sales?
SELECT Store, AVG(Weekly_Sales) AS avg_profit
FROM sales_exercise 
GROUP BY store
ORDER BY avg_profit DESC;

-- Which departments from store 20 were the best and the worst in terms of overall sales?
SELECT Dept, SUM(Weekly_Sales) AS sales
FROM sales_exercise 
WHERE store = 20
GROUP BY Dept
ORDER BY sales DESC;

-- How much profit does the average department make in store 20?
SELECT AVG(avg_profit_dept) AS avg_profit_store_20
FROM (
  SELECT Dept, AVG(Weekly_Sales) AS avg_profit_dept
  FROM sales_exercise
  WHERE Store = 20
  GROUP BY Dept
) subquery_by_dept;

-- Consider store 20. 
-- Calculate the difference between the total profit of each department and the total profit of the average department. 
-- This will be the departments’ “performance metric”. 
-- Which department is the worst performer and what’s its performance?

SELECT Dept,
	   SUM(Weekly_Sales) AS total_profit,
       SUM(Weekly_Sales) - (SELECT AVG(avg_profit_dept) 
                            FROM (
                              SELECT Dept, AVG(Weekly_Sales) AS avg_profit_dept
                              FROM sales_exercise
                              WHERE Store = 20
                              GROUP BY Dept
                            ) subquery_by_dept
                           ) AS performance_metric
FROM sales_exercise
WHERE Store = 20
GROUP BY Dept
ORDER BY performance_metric ASC;

SELECT SUM(Weekly_Sales) 
FROM sales_exercise
WHERE Store = 20
AND Dept = 78;

-- Which department-store combination is the overall best performer (and what’s its performance?)? 
-- Consider the performance metric from the previous question, that is, the difference between a department’s sales and the sales of the average department of the corresponding store.

SELECT Dept,
	   SUM(Weekly_Sales) AS total_profit,
       SUM(Weekly_Sales) - (SELECT AVG(avg_profit_dept) 
                            FROM (
                              SELECT Dept, AVG(Weekly_Sales) AS avg_profit_dept
                              FROM sales_exercise
                              WHERE Store = 14
                              GROUP BY Dept
                            ) subquery_by_dept
                           ) AS performance_metric
FROM sales_exercise
WHERE Store = 14
GROUP BY Dept
ORDER BY performance_metric DESC;