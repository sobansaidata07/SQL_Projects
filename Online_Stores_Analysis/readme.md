# 📊 Super Store Sales Analysis Project

## 📌 Project Overview
This project analyzes a **US-based retail dataset (2014–2017)** to understand sales performance, profitability, discount impact, customer behavior, and regional trends.

The main objectives of the project were to:

- Clean and normalize raw data using **SQL**
- Design a proper **relational database structure**
- Perform **financial calculations**
- Build an **interactive Power BI dashboard**
- Generate **actionable business insights**

---

# 📂 Dataset Description

The dataset consists of three main tables:

1. **Orders**
2. **Returns**
3. **People**

## Orders Table
Contains transactional-level data including:

- Order ID
- Customer details
- Product details
- Sales, Quantity, Discount, Profit
- Order Date & Ship Date
- Location details

## Returns Table

- Order ID
- Returned (Yes)

## People Table

- Person
- Region

---

# 🧹 Data Preparation (SQL Implementation)

## Step 1: Data Import

- Converted Excel sheets into **CSV format**
- Imported into database as:

```
raw_orders
raw_returns
raw_people
```

---

# 🔎 Exploratory Data Analysis (EDA)

## People Table

- No missing values found
- Applied **NOT NULL constraints**

## Returns Table

- No missing values
- No duplicate records
- Order IDs validated

## Orders Table

Data type corrections:

- **Order Date & Ship Date → DATE**
- **Postal Code → VARCHAR (identifier)**
- **Sales, Discount, Profit → DECIMAL(20,4)**

Additional findings:

- **8 duplicate rows detected**
- No NULL values

---

# 🏗 Database Design & Normalization

The database was redesigned using **normalization principles**.

## Tables Created

### Customer Table
```
customer_id (PK)
customer_name
segment
```

### Product Table
```
product_id (PK)
category
sub_category
product_name
```

Handled **30 duplicate product IDs** using:

- `DISTINCT`
- `INSERT IGNORE`

### Orders Table
```
order_id (PK)
customer_id (FK)
order_date
ship_date
ship_mode
country
city
state
postal_code
region
```

Constraint applied:

```
ship_date > order_date
```

### Sales Table (Fact Table)

```
order_id (FK)
product_id (FK)
customer_id (FK)
sales
quantity
discount
profit
```

Composite Primary Key:

```
(order_id, product_id, customer_id)
```

Each row represents:

```
1 Order × 1 Product × 1 Customer
```

---

# 🧼 Data Cleaning & Procedures

## Stored Procedures Created

- Insert **distinct customers**
- Insert **distinct products (trimmed values)**
- Convert dates using `STR_TO_DATE`
- Aggregate duplicate sales rows using:

```
SUM(sales)
SUM(quantity)
AVG(discount)
SUM(profit)
GROUP BY order_id, product_id, customer_id
```

---

# ⚠ Challenges & Solutions

## Issue 1: Same customer ID with different addresses
**Solution**

- Assumed delivery address variation
- Stored address in **Orders table** instead of Customer table

---

## Issue 2: Same product ID with different names
**Solution**

- Used **product_id as primary key**
- Inserted distinct records using **INSERT IGNORE**

---

## Issue 3: Duplicate transactional rows
**Solution**

- Aggregated rows using **GROUP BY**

---

# 💰 Financial Calculations

## Revenue Calculations

```
Net Revenue = Sales
Gross Revenue = Net Revenue / (1 - Discount)
Discount Value = Gross Revenue - Net Revenue
Cost = Net Revenue - Profit
```

## Per Unit Calculations

```
Selling Price per Unit = Net Sales / Quantity
Cost per Unit = Cost / Quantity
Profit per Unit = Profit / Quantity
```

---

# 📊 Reporting Views Created

Views created for simplified reporting:

- `People_data_view`
- `Returns_data_view`
- `Customer_data_view`
- `Product_data_view`
- `Orders_data_view`
- `Sales_data_view`

### Orders View Includes

- Shipping days calculation

### Sales View Includes

- Net Sales
- Gross Sales
- Cost
- Discount Value
- Per-unit metrics

---

# 📈 Power BI Dashboard

## Visualizations Created

### KPI Cards

- Total Sales
- Total Profit
- Profit Ratio
- Total Orders
- Total Customers
- Quantity Sold

### Charts

**Bar Chart**
- Region-wise Sales

**Matrix Table**
- Category & Subcategory
- Loss-making subcategories highlighted

**Top 10 Customers**
- Ranked by Profit

**Sales & Profit Trends**
- Yearly
- Quarterly
- Monthly (using bookmarks)

### Map Visualizations

- Sales by State
- Profit by State
- Orders by State
- Region-wise Profit

---

# 📊 Key Business Insights

## Overall Performance

| Metric | Value |
|------|------|
| Total Orders | 1,812 |
| Customers | 793 |
| Quantity Sold | 36,749 |
| Gross Sales | $2.83M |
| Net Sales | $2.27M |
| Discount Given | $561K |
| Actual Profit | $282K |
| Profit Ratio | 12.45% |

---

# 📉 Sales Trend

- Sales declined in **2015**
- Strong recovery observed:
  - **2016 → +29%**
  - **2017 → +20%**

Sales increased from:

```
$601K → $725K
```

---

# 🧾 Category Insights

**Technology**

- Most stable category
- No loss-making products

**Furniture**

- Loss-making subcategories:
  - Tables
  - Bookcases

**Office Supplies**

- Loss-making subcategory:
  - Supplies

---

# 💸 Discount Impact

- **Average Discount:** 16%

High discounting observed:

- Bottom cities → **30–40%**
- Bottom products → **40–60%**

Profit comparison:

```
Potential Profit: $844K
Actual Profit: $282K
```

➡ Excessive discounting is the **primary reason for reduced profitability**.

---

# 🌍 Geographic Insights

Top order states:

- California → 1003 orders
- New York → 556 orders
- Texas → 484 orders

**Texas is loss-making.**

Other loss-making states:

- Florida
- Arizona
- Oregon
- Ohio
- Illinois
- North Carolina

---

# 👥 Customer Segmentation

| Segment | Customers |
|-------|-------|
| Gold | 14 |
| Silver | 131 |
| Bronze | 648 |

Observation:

A **small percentage of customers generate the majority of revenue**.

---

# 🚀 Strategic Recommendations

1. Reduce discount rates in **loss-making states**
2. Focus growth strategy on **Technology category**
3. Re-evaluate pricing of **Furniture (Tables & Bookcases)**
4. Improve **return management** (approx. $177K impact)
5. Create **loyalty programs** for Gold & Silver customers
6. Set **discount caps** to avoid 40–60% discounting

---

# ✅ Final Conclusion

The business shows **strong sales growth after 2015**, especially in **Q4 periods**.

However, **excessive discounting** (average **16%**, up to **60%** in some products) significantly reduces profitability.

By optimizing discounts and focusing on:

- High-margin products
- Profitable regions
- Loyal customers

The company can **significantly increase profits without increasing sales volume**.

---