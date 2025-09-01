-- ========================
-- 1. TABLE CREATION
-- ========================

CREATE TABLE bigbasket (
  index_items      INT,
  product_name     VARCHAR(255),
  category_name    VARCHAR(150),
  sub_category     VARCHAR(150),
  brand_name       VARCHAR(150),
  sale_price       NUMERIC(10,2),
  market_price     NUMERIC(10,2),
  type_product     VARCHAR(150),
  rating_product   NUMERIC(3,1)
);

-- ========================
-- 2. DATA VERIFICATION & CLEANING
-- ========================

-- Row count
SELECT COUNT(*) FROM bigbasket;

-- Sample data
SELECT * FROM bigbasket LIMIT 10;

-- Missing/null values
SELECT
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS null_products,
    SUM(CASE WHEN sale_price IS NULL THEN 1 ELSE 0 END) AS null_sale_price
FROM bigbasket;

DELETE FROM bigbasket WHERE product_name IS NULL;
DELETE FROM bigbasket WHERE sale_price IS NULL;

-- Duplicate check
SELECT product_name, COUNT(*)
FROM bigbasket
GROUP BY product_name
HAVING COUNT(*) >1;

DELETE FROM bigbasket a
USING bigbasket b
WHERE a.ctid < b.ctid
  AND a.product_name = b.product_name
  AND a.sale_price = b.sale_price
  AND a.market_price = b.market_price;

-- ========================
-- 3. DATA EXPLORATION
-- ========================

-- Unique categories & subcategories
SELECT COUNT(DISTINCT category_name) AS unique_categories FROM bigbasket;
SELECT COUNT(DISTINCT sub_category) AS unique_subcategories FROM bigbasket;

-- Top brands by product count
SELECT brand_name, COUNT(*) AS product_count
FROM bigbasket
GROUP BY brand_name
ORDER BY product_count DESC
LIMIT 10;

-- Rating distribution
SELECT rating_product, COUNT(*)
FROM bigbasket
GROUP BY rating_product
ORDER BY rating_product DESC;

-- ========================
-- 4. DATA ANALYSIS (Q&A)
-- ========================

-- Q1: Which brands have the most products listed?
SELECT brand_name, COUNT(*) AS product_count
FROM bigbasket
GROUP BY brand_name 
ORDER BY product_count DESC
LIMIT 20;

-- Q2: Which product category has the highest average rating?
SELECT category_name,
       ROUND(AVG(rating_product),2) AS average_rating
FROM bigbasket
GROUP BY category_name
ORDER BY average_rating DESC;

-- Q3: Which product has the highest discount percentage?
SELECT product_name, category_name, brand_name, sale_price, market_price,
       ROUND(((market_price - sale_price) / market_price) * 100, 2) AS discount_percent
FROM bigbasket
WHERE market_price > 0
  AND ((market_price - sale_price) / market_price) * 100 > 0
ORDER BY discount_percent DESC;

-- Q4: Which brands have the most expensive average price?
SELECT brand_name,
       ROUND(AVG(sale_price),2) AS avg_sale_price
FROM bigbasket
GROUP BY brand_name
ORDER BY avg_sale_price DESC;

-- Q5: Top 5 highest-rated products in each category
SELECT category_name, product_name, rating_product
FROM (
    SELECT category_name, product_name, rating_product,
           ROW_NUMBER() OVER (PARTITION BY category_name ORDER BY rating_product DESC) AS rank
    FROM bigbasket
) ranked
WHERE rank <= 5;

-- Q6: Price difference between market price & sale price by category
SELECT category_name,
       ROUND(AVG(market_price - sale_price), 2) AS avg_price_diff
FROM bigbasket
GROUP BY category_name
ORDER BY avg_price_diff DESC;

-- Q7: Most common product type in each sub-category
SELECT sub_category, type_product, type_count
FROM (
    SELECT sub_category, type_product, COUNT(*) AS type_count,
           ROW_NUMBER() OVER (PARTITION BY sub_category ORDER BY COUNT(*) DESC) AS rn
    FROM bigbasket
    GROUP BY sub_category, type_product
) ranked
WHERE rn = 1;

-- Q8: Which brands dominate each category? (market share by count)
SELECT category_name, brand_name,
       COUNT(*) AS brand_count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY category_name), 2) AS market_share_percent
FROM bigbasket
WHERE brand_name IS NOT NULL
GROUP BY brand_name, category_name
ORDER BY category_name, market_share_percent DESC;

-- Q9: Products with ratings < 3 but high market prices
SELECT product_name, brand_name, category_name, rating_product, market_price
FROM bigbasket
WHERE rating_product < 3
  AND market_price > 500
ORDER BY market_price DESC;

-- ========================
-- 5. DATA TRANSFORMATION & EXTRA ANALYSIS
-- ========================

-- Price segment column
ALTER TABLE bigbasket ADD COLUMN price_segment TEXT;

UPDATE bigbasket
SET price_segment = CASE 
    WHEN sale_price < 100 THEN 'Low'
    WHEN sale_price BETWEEN 100 AND 500 THEN 'Medium'
    ELSE 'High'
END;

-- Q10: Average rating trend per price range
SELECT price_segment, ROUND(AVG(rating_product), 2) AS avg_rating
FROM bigbasket
GROUP BY price_segment
ORDER BY CASE price_segment 
            WHEN 'Low' THEN 1
            WHEN 'Medium' THEN 2
            WHEN 'High' THEN 3
         END;

-- Add discount percentage column
SELECT *, ROUND(((market_price - sale_price) / market_price) * 100, 2) AS discount_percentage
FROM bigbasket;

-- Correlation between price & ratings
SELECT CORR(sale_price, rating_product) AS correlation
FROM bigbasket;

-- Category contribution to total revenue
SELECT category_name,
       ROUND(SUM(sale_price), 2) AS total_revenue,
       ROUND(SUM(sale_price) * 100.0 / SUM(SUM(sale_price)) OVER (), 2) AS percent_of_total
FROM bigbasket
GROUP BY category_name
ORDER BY total_revenue DESC;

-- Final check
SELECT * FROM bigbasket;
