-- Final SQL Challenge

-- Expand the database

-- Find online a dataset that contains the abbreviations for the Brazilian states and the full names of the states. It does not need to contain any other information about the states, but it is ok if it does.
SELECT city, state
FROM geo;

-- Import the dataset as an SQL table in the Magist database.
CREATE TABLE brazilian_states AS
	SELECT city, state 
    FROM geo;

-- Create the appropriate relationships with other tables in the database.
ALTER TABLE geo MODIFY COLUMN state VARCHAR(3);
ALTER TABLE brazilian_states MODIFY COLUMN state VARCHAR(3);

CREATE INDEX idx_state ON brazilian_states (state);

ALTER TABLE geo
ADD CONSTRAINT fk_geo_brazilian_states
FOREIGN KEY (state)
REFERENCES brazilian_states(state);

-- Analyze customer reviews

-- Find the average review score by state of the customer.
SELECT state, AVG(review_score) as avg_review_score 
FROM geo 
JOIN customers 
ON geo.zip_code_prefix = customers.customer_zip_code_prefix
JOIN orders
ON customers.customer_id = orders.customer_id
JOIN order_reviews
ON orders.order_id = order_reviews.order_id
GROUP BY state
ORDER BY avg_review_score DESC;

-- Do reviews containing positive words have a better score? Some Portuguese positive words are: “bom”, “otimo”, “gostei”, “recomendo” and “excelente”.
SELECT state,
       AVG(CASE WHEN review_comment_message LIKE '%bom%' OR
                     review_comment_message LIKE '%ótimo%' OR
                     review_comment_message LIKE '%gostei%' OR
                     review_comment_message LIKE '%recomendo%' OR
                     review_comment_message LIKE '%excelente%'
                THEN review_score ELSE NULL END) AS avg_pos_review_score,
       AVG(review_score) AS avg_review_score
FROM geo
JOIN customers ON geo.zip_code_prefix = customers.customer_zip_code_prefix
JOIN orders ON customers.customer_id = orders.customer_id
JOIN order_reviews ON orders.order_id = order_reviews.order_id
GROUP BY state
HAVING avg_pos_review_score IS NOT NULL
ORDER BY avg_pos_review_score DESC;

-- Considering only states having at least 30 reviews containing these words, what is the state with the highest score?
SELECT state,
       AVG(CASE WHEN review_comment_message LIKE '%bom%' OR
                     review_comment_message LIKE '%ótimo%' OR
                     review_comment_message LIKE '%gostei%' OR
                     review_comment_message LIKE '%recomendo%' OR
                     review_comment_message LIKE '%excelente%'
                THEN review_score ELSE NULL END) AS avg_pos_review_score,
       COUNT(CASE WHEN review_comment_message LIKE '%bom%' OR
                      review_comment_message LIKE '%ótimo%' OR
                      review_comment_message LIKE '%gostei%' OR
                      review_comment_message LIKE '%recomendo%' OR
                      review_comment_message LIKE '%excelente%'
                 THEN 1 ELSE NULL END) AS pos_review_count
FROM geo
JOIN customers ON geo.zip_code_prefix = customers.customer_zip_code_prefix
JOIN orders ON customers.customer_id = orders.customer_id
JOIN order_reviews ON orders.order_id = order_reviews.order_id
GROUP BY state
HAVING pos_review_count >= 30 AND avg_pos_review_score IS NOT NULL
ORDER BY avg_pos_review_score DESC
LIMIT 1;

-- What is the state where there is a greater score change between all reviews and reviews containing positive words?
SELECT state,
       AVG(review_score) AS avg_review_score,
       AVG(CASE WHEN review_comment_message LIKE '%bom%' OR
					 review_comment_message LIKE '%ótimo%' OR
                     review_comment_message LIKE '%gostei%' OR
                     review_comment_message LIKE '%recomendo%' OR
                     review_comment_message LIKE '%excelente%'
                THEN review_score ELSE NULL END) AS avg_pos_review_score,
       AVG(review_score) - AVG(CASE WHEN review_comment_message LIKE '%bom%' OR
                                        review_comment_message LIKE '%ótimo%' OR
                                        review_comment_message LIKE '%gostei%' OR
                                        review_comment_message LIKE '%recomendo%' OR
                                        review_comment_message LIKE '%excelente%'
                                   THEN review_score ELSE NULL END) AS score_diff
FROM geo
JOIN customers ON geo.zip_code_prefix = customers.customer_zip_code_prefix
JOIN orders ON customers.customer_id = orders.customer_id
JOIN order_reviews ON orders.order_id = order_reviews.order_id
GROUP BY state
HAVING avg_pos_review_score IS NOT NULL
ORDER BY score_diff DESC
LIMIT 1;

-- Automatize a KPI
SELECT *
FROM product_category_name_translation;
-- Create a stored procedure that gets as input:
-- The name of a state (the full name from the table you imported).
-- The name of a product category (in English).
-- A year
-- And outputs the average score for reviews left by customers from the given state for orders with the status “delivered, containing at least a product in the given category, and placed on the given year.

DROP PROCEDURE kpi_average_score;

DELIMITER //

CREATE PROCEDURE kpi_average_score(IN state_input VARCHAR(255), IN product_category_name_en_input VARCHAR(255), IN year_input INT)
BEGIN

-- Get the average review score for orders that match the criteria
SELECT state, AVG(order_reviews.review_score) AS avg_review_score
FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
JOIN products ON order_items.product_id = products.product_id
JOIN product_category_name_translation ON product_category_name_translation.product_category_name = products.product_category_name
JOIN order_reviews ON orders.order_id = order_reviews.order_id
JOIN customers ON orders.customer_id = customers.customer_id
JOIN geo ON customers.customer_zip_code_prefix = geo.zip_code_prefix
WHERE orders.order_status = 'delivered'
AND YEAR(orders.order_purchase_timestamp) = year_input
AND product_category_name_translation.product_category_name_english = product_category_name_en_input
AND geo.state = state_input
GROUP BY geo.state;

END //

DELIMITER ;

-- Test the stored procedure
CALL kpi_average_score('SP', 'music', 2018);


