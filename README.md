# BigBasket SQL Data Analysis Project

## Project Overview

This project is a complete **end-to-end SQL analysis** on the BigBasket dataset (27,000+ rows). The goal was to simulate a **real-world data analyst workflow**-  from setting up raw tables, cleaning data, running exploratory checks, to generating business insights and category/brand-level analysis.

Instead of just writing a few random queries, I treated this like an **actual moderate-level SQL project** that could fit into a data portfolio. Every step has been structured to reflect how SQL is used in practical data analysis work.

---

## Dataset

* **Source:** BigBasket products dataset (27k rows, multiple categories and brands).
  
* Full Dataset: data/bigbasket.csv
  * Contains the complete data used for all queries and analysis. But, due to GitHub’s preview size limits, the file cannot be viewed in-browser. To access it, click “View raw” to download.

* Sample Dataset: data/bigbasket_sample.csv
  * A smaller file (~1,250 rows). It is added for quick preview directly on GitHub without downloading.

* **Fields Included:**

  * `product_name`
  * `category_name`
  * `sub_category`
  * `brand_name`
  * `sale_price`
  * `market_price`
  * `type_product`
  * `rating_product`

The raw dataset was uploaded as `bigbasket.csv` inside the `/data/` folder.
*(Note: GitHub can’t preview large CSVs, but the file is downloadable and usable for queries.)*

---

## Project Structure

```
bigbasket-sql-project/
│── README.md         # Project documentation (this file)
│── queries.sql       # All SQL queries used in this project
│── data/
│   └── bigbasket.csv # The dataset (27k+ rows)
│── schema.sql        # (Optional) CREATE TABLE schema
```

---

## Steps Followed

### 1. Data Setup

* Created a table `bigbasket` with proper schema.
* Imported dataset into PostgreSQL.

### 2. Data Cleaning

* Checked **row counts**, missing values, and duplicates.
* Removed products without names or sale prices.
* Deduplicated rows based on `product_name + sale_price + market_price`.

### 3. Data Exploration

* Counted unique categories and subcategories.
* Looked at **brand distribution** (top brands by product count).
* Explored **ratings distribution** across products.

### 4. Data Analysis & Business Questions

Some of the **key questions answered using SQL**:

1. Which brands have the most products listed?
2. Which product categories have the highest average ratings?
3. Which products have the **highest discount percentages**?
4. Which brands are most expensive on average?
5. Top 5 highest-rated products in each category.
6. Price difference between **market price vs sale price** by category.
7. Most common product type in each sub-category.
8. Which brands dominate each category (market share by count)?
9. Which products have **low ratings (<3)** but **high market price (>500)**?
10. How do ratings trend across different **price segments** (Low, Medium, High)?

### 5. Transformations & Deeper Analysis

* Added a new column: **Price Segment** (Low / Medium / High).
* Calculated **Discount %** for each product.
* Checked **correlation between price & ratings**.
* Measured each category’s **contribution to total revenue**.

---

## 📈 Key Insights

* **Brands:** A handful of brands dominate product listings, while long-tail brands are scattered with fewer SKUs.
* **Categories:** Some categories consistently scored higher in ratings (better customer satisfaction), while others lagged.
* **Discounts:** A few products had **>80% discounts**, which stood out as anomalies.
* **Expensive Brands:** Premium brands clearly separated themselves when ranked by average price.
* **Market Share:** In many categories, **1–2 brands captured >40% share**, showing strong brand concentration.
* **Ratings vs Price:** Higher price segments did **not always guarantee higher ratings** — correlation was weak.
* **Revenue Contribution:** A small set of categories contributed the **majority of overall revenue** (Pareto effect).


---

## SQL Functions & Concepts Used

This project goes beyond basic SELECT queries and covers a **moderate range of SQL functions and techniques**:

* **Aggregation Functions:**
  * `COUNT()` – product counts, category sizes
  * `SUM()` – revenue totals
  * `AVG()` – average ratings, prices
  * `ROUND()` – rounding decimals for better readability

* **Conditional Expressions:**
  * `CASE WHEN` – categorizing products into **Low / Medium / High** price segments

* **Data Cleaning & Verification:**
  * Handling `NULL` values
  * `DELETE` with conditions (removing bad rows)
  * Duplicate removal using `CTID` trick

* **Grouping & Filtering:**
  * `GROUP BY` – category/brand-level analysis
  * `HAVING` – filtering groups (finding duplicates)

* **Sorting & Limiting:**
  * `ORDER BY` with `DESC` and `LIMIT` for top-N queries

* **Window Functions (Intermediate SQL):**
  * `ROW_NUMBER() OVER (PARTITION BY … ORDER BY …)` → top 5 products in each category
  * `SUM() OVER (PARTITION BY …)` → calculating brand **market share**

* **Statistical Function:**
  * `CORR()` → correlation between price and ratings

* **Joins (implicit in cleaning):**
  * `DELETE USING` → used to remove duplicate rows


