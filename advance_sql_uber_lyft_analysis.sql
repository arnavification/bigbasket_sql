-- Uber_Lyft_analysis.sql
-- PostgreSQL-compatible analysis queries for Uber & Lyft dataset

-- IMPORTANT: Create & connect to database 'uber' (see README) before running.

-- Create schema and set search_path
CREATE SCHEMA IF NOT EXISTS rides;
SET search_path = rides, public;

-- Create raw staging table (all as text)
CREATE TABLE IF NOT EXISTS rides (
  distance_text         text,
  cab_type_text         text,
  time_stamp_text       text,
  destination_text      text,
  source_text           text,
  price_text            text,
  surge_multiplier_text text,
  id_text               text,
  product_id_text       text,
  name_text             text
);


-- Initial Checks (Checking sample data and row count)
USE uber;
  
-- Sample rows
SELECT * FROM rides LIMIT 10;

-- Row count
SELECT COUNT(*) AS total_rows FROM rides;

-- Basic Distinct Exploration (finding unique values)

-- Cab types
SELECT DISTINCT cab_type_text FROM rides;

-- Car categories
SELECT DISTINCT name_text FROM rides;

-- Sources
SELECT DISTINCT source_text FROM rides;

-- Destinations
SELECT DISTINCT destination_text FROM rides;

-- Summary Stats (Overall picture of distance & price)

SELECT 
    ROUND(AVG(CAST(price_text AS NUMERIC)),2) AS avg_price,
    ROUND(MIN(CAST(price_text AS NUMERIC)),2) AS min_price,
    ROUND(MAX(CAST(price_text AS NUMERIC)),2) AS max_price,
    ROUND(AVG(CAST(distance_text AS NUMERIC)),2) AS avg_distance,
    ROUND(MAX(CAST(distance_text AS NUMERIC)),2) AS max_distance
FROM rides;

-- Pricing Comparison (Uber vs Lyft)

SELECT 
    cab_type_text, 
    ROUND(AVG(CAST(price_text AS NUMERIC)), 2) AS avg_price, 
    ROUND(MAX(CAST(price_text AS NUMERIC)), 2) AS max_price, 
    COUNT(*) AS rides
FROM rides
GROUP BY cab_type_text;

-- Most Expensive Car Categories

SELECT 
    name_text, 
    ROUND(AVG(CAST(price_text AS NUMERIC)), 2) AS avg_price, 
    MAX(CAST(price_text AS NUMERIC)) AS max_price
FROM rides
GROUP BY name_text
ORDER BY avg_price DESC
LIMIT 10;

-- Most Popular Routes

SELECT 
    source_text AS source,
    destination_text AS destination,
    COUNT(*) AS total_rides
FROM rides
GROUP BY source_text, destination_text
ORDER BY total_rides DESC
LIMIT 10;

-- Surge Pricing Impact

SELECT 
    surge_multiplier_text,
    ROUND(AVG(CAST(price_text AS NUMERIC)), 2) AS avg_price, 
    COUNT(*) AS rides
FROM rides
GROUP BY surge_multiplier_text
ORDER BY surge_multiplier_text;

-- Price vs Distance Relationship

SELECT 
    CASE 
        WHEN CAST(distance_text AS NUMERIC) < 2 THEN '0-2 km'
        WHEN CAST(distance_text AS NUMERIC) BETWEEN 2 AND 5 THEN '2-5 km'
        WHEN CAST(distance_text AS NUMERIC) BETWEEN 5 AND 10 THEN '5-10 km'
        ELSE '10+ km'
    END AS distance_bucket,
    ROUND(AVG(CAST(price_text AS NUMERIC)), 2) AS avg_price,
    COUNT(*) AS rides
FROM rides
GROUP BY distance_bucket
ORDER BY MIN(CAST(distance_text AS NUMERIC));


-- Time Analysis (convert timestamp → date/hour)

SELECT 
    to_timestamp(CAST(CAST(time_stamp_text AS NUMERIC) AS BIGINT) / 1000) AS ride_time,
    EXTRACT(HOUR FROM to_timestamp(CAST(CAST(time_stamp_text AS NUMERIC) AS BIGINT) / 1000)) AS ride_hour,
    TO_CHAR(to_timestamp(CAST(CAST(time_stamp_text AS NUMERIC) AS BIGINT) / 1000), 'Day') AS ride_day
FROM rides
LIMIT 10;


-- Rides by Hour of Day

SELECT 
    EXTRACT(HOUR FROM to_timestamp(CAST(CAST(time_stamp_text AS NUMERIC) AS BIGINT) / 1000)) AS ride_hour,
    COUNT(*) AS total_rides,
    ROUND(AVG(CAST(price_text AS NUMERIC)), 2) AS avg_price
FROM rides
GROUP BY ride_hour
ORDER BY ride_hour;


-- Rides by Day of Week

SELECT 
    TO_CHAR(
        to_timestamp(CAST(CAST(time_stamp_text AS NUMERIC) AS BIGINT) / 1000), 
        'Day'
    ) AS ride_day,
    COUNT(*) AS total_rides,
    ROUND(AVG(CAST(price_text AS NUMERIC)), 2) AS avg_price
FROM rides
GROUP BY ride_day
ORDER BY total_rides DESC;


-- Ranking Top Routes by Price (Window function)

SELECT 
    source_text AS source,
    destination_text AS destination,
    ROUND(AVG(CAST(price_text AS NUMERIC)), 2) AS avg_price,
    RANK() OVER (ORDER BY AVG(CAST(price_text AS NUMERIC)) DESC) AS price_rank
FROM rides
GROUP BY source_text, destination_text
ORDER BY price_rank;


-- Top 3 Ride Categories per Cab Type

SELECT *
FROM (
    SELECT 
        name_text, 
        ROUND(AVG(CAST(price_text AS NUMERIC)), 2) AS avg_price,
        RANK() OVER (
            ORDER BY AVG(CAST(price_text AS NUMERIC)) DESC
        ) AS rnk
    FROM rides
    GROUP BY name_text
) t
WHERE rnk <= 3;

-- Surge vs No Surge Revenue Share

SELECT 
    CASE WHEN CAST(surge_multiplier_text AS NUMERIC) > 1 
         THEN 'Surge' ELSE 'Normal' END AS surge_flag,
    COUNT(*) AS total_rides,
    ROUND(AVG(CAST(price_text AS NUMERIC)),2) AS avg_price,
    ROUND(SUM(CAST(price_text AS NUMERIC)),2) AS total_revenue
FROM rides
GROUP BY surge_flag;

-- Correlation Check (Distance vs Price approx)

SELECT 
    ROUND(SUM(CAST(price_text AS NUMERIC)) / SUM(CAST(distance_text AS NUMERIC)), 2) AS avg_price_per_km
FROM rides
WHERE CAST(distance_text AS NUMERIC) > 0;


-- Revenue Contribution by Car Category

SELECT 
    name_text, 
    ROUND(SUM(CAST(price_text AS NUMERIC)),2) AS total_revenue,
    ROUND(SUM(CAST(price_text AS NUMERIC)) * 100.0 / 
          (SELECT SUM(CAST(price_text AS NUMERIC)) FROM rides), 2) AS revenue_percent
FROM rides
GROUP BY name_text
ORDER BY total_revenue DESC;


-- Detect Outliers in Pricing

SELECT *
FROM rides
WHERE CAST(price_text AS NUMERIC) > (
          SELECT AVG(CAST(price_text AS NUMERIC)) 
                 + 3*STDDEV(CAST(price_text AS NUMERIC)) 
          FROM rides
      )
ORDER BY CAST(price_text AS NUMERIC) DESC
LIMIT 10;



