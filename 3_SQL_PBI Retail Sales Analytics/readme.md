
---

## 🗄️ Database Design
- Database: `Sales_Analytics`  
- **Tables:**  
  - `Customers` – customer details (email, gender, region, signup date, loyalty tier) 👥  
  - `Products` – product info (name, category, launch date, price, supplier code) 🛍️  
  - `Sales` – transaction data (order ID, customer ID, product ID, quantity, price, order date, delivery, payment, discount) 💳  

Relationships: `Sales` connects `Customers` and `Products` via `customer_id` and `product_id`.

---

## 🧹 Data Cleaning & Transformation
- All cleaning done in SQL using functions like `TRIM()`, `LOWER()`, `UPPER()`, `CASE WHEN`, `STR_TO_DATE()`, `CAST()`  
- Customer data: standardized names, genders, regions, signup dates 👤  
- Product data: formatted prices, dates, categories 🛒  
- Sales data: fixed delivery status, payment methods, numeric prices, removed duplicates 📋  
- Invalid/mismatched values replaced with `"Unknown"` ❓

---

## 🔍 Analytical Layer
- Analytical views created in SQL with calculated fields:  
  - **Gross Sales** = quantity × unit price 💰  
  - **Net Sales** = gross sales after discount 💵  
  - **Total Discount Amount** 💸  
- Over 60 SQL queries for:  
  - Revenue and orders analysis  
  - Sales trends (monthly/yearly) 📆  
  - Customer segmentation & loyalty tiers  
  - Product performance  
  - Delivery & payment insights  
  - Regional sales 🌍  
  - Discount vs net revenue correlation  

---

## 📐 Power BI Data Modeling
- Star schema:  
  - Fact table: `sales_data`  
  - Dimension tables: `customer_data`, `product_data`  
- Relationships: `customer_id` and `product_id` (one-to-many) 🔗  
- Minor Power Query cleaning: trimming text, extracting year/month/quarter 🗓️  

---

## 📏 Power BI Measures
- Total Customers 👥  
- Total Products 🛒  
- Total Orders 🧾  
- Total Quantity  
- Total Gross Sales 💰  
- Total Net Sales 💵  
- Average Discount Rate 💸  
- Average Order Quantity  

Advanced DAX used: `CALCULATE`, `TREATAS` ⚡  

---

## 📊 Dashboard Overview
**Pages:** Customer Insights | Product Performance | Order Analysis  

- Customer Insights: gender, loyalty tiers, signup trends 👤  
- Product Performance: category distribution, suppliers, seasonality 🏷️  
- Order Analysis:  
  - Total Orders: 2476  
  - Total Quantity Sold: 7420  
  - Gross Sales: 215.90K 💰  
  - Net Sales: 194.14K 💵  
  - Avg Discount Rate: 10% 💸  
- Delivery: 41% delivered ✅, 40% delayed ⏳, 19% cancelled ❌  
- Payment: Credit card most preferred 💳  

---

## 💡 Key Business Insights
- Q4 has highest sales activity 📈  
- Gold loyalty customers contribute most to revenue 🏅  
- Delivery delays highlight operational improvement needs ⚠️  
- Discounts have minimal impact on net revenue ❌💸  
- Credit cards dominate payments 💳  

---

## ✅ Conclusion
This project demonstrates a full end-to-end analytics workflow:  
- Raw data ingestion → SQL cleaning → Structured tables → Analytical views → Power BI dashboards  
- The layered architecture ensures clarity, maintainability, and scalability 🏗️  
- Reflects practical knowledge in data engineering and business intelligence 💼  

---

**⚠️ Note:** Dataset is used for educational purposes only; all rights remain with the original owner.