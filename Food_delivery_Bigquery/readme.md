# Food Delivery Platform Analysis
### Blinkit vs JioMart vs Swiggy Instamart

**Tools:** BigQuery (GoogleSQL) · Looker Studio  
**Type:** End-to-end Data Analysis Project  
**Level:** Fresher Portfolio Project

---

## What This Project Is About

Instead of just running random queries, I structured the work around 5 business cases — 
the kind of problems a manager or operations team would actually bring to a data analyst.

---

## Tools & Stack

| Tool | Purpose |
|------|---------|
| BigQuery (Google Cloud) | Data storage, cleaning, SQL analysis |
| GoogleSQL | CTEs, window functions, stored procedures, views |
| Looker Studio | Interactive dashboard |

---

## Dataset Columns

| Column | Description |
|--------|-------------|
| order_id | Unique order identifier |
| customer_id | Unique customer identifier |
| platform | Blinkit / JioMart / Swiggy Instamart |
| order_datetime | Date and time of order |
| delivery_time_minutes | Delivery duration in minutes |
| category | Product category |
| order_value | Order amount in INR |
| customer_feedback | Text feedback |
| rating | Service rating (1–5) |
| delivery_delay | Whether order was delayed (Boolean) |
| refund_requested | Whether refund was requested (Boolean) |

> Note: This is a synthetic dataset. Numbers are fabricated for learning purposes.

---

## Project Structure

```
food-delivery-analysis/
├── sql/
│   ├── Basic_query_check.sql
│   ├── customer_churn_analysis.sql
│   ├── Delivery_delay_impact_ratings_refunds.sql
│   ├── Final_Summary.sql
│   ├── food_delivery_refund_driver_analysis.sql
│   ├── low_performance_categories.sql
│   └── platform_performance_analysis.sql
├── dashboard/
│   └── dashboard.pdf
├── Food_Delivery_Analysis_Project.docx
└── README.md
```

---

## Business Cases Solved

### Case 1 — Are delivery delays causing low ratings and refunds?
The operations team suspected delivery delays were driving poor customer experience.

**Finding:** Delivery delay showed almost no impact on ratings (3.23 vs 3.24) and refund behavior. Delay alone is not the primary driver.

---

### Case 2 — What is actually driving refund requests?
An escalation came in asking whether refunds are a platform issue, category issue, or delivery issue.

**Finding:** Rating is the strongest driver. Orders with rating 1–2 had a 100% refund rate. Orders with rating 3–5 had 0% refund rate. Platform and category showed no meaningful difference (~45–47% across the board).

---

### Case 3 — Which product categories are causing problems?
Management wanted to identify high-risk categories per platform.

**Finding:** Refund volume was highest in Fruits & Vegetables, Snacks, and Personal Care — but these are also high-volume categories. When normalized, no category showed a clear deviation in ratings (~3.2 across all). The issue appears systemic, not category-specific.

---

### Case 4 — Which platform is performing best?
A neutral platform comparison was needed before a partner review meeting.

**Finding:** All three platforms are nearly identical across revenue, ratings, refund rate, and delay rate. No platform is clearly better or worse. This is a characteristic of the synthetic dataset.

---

### Case 5 — Which high-value customers are at risk of churning?
Leadership was concerned about losing top-spending customers.

**Finding:** Used NTILE(10) to segment customers into spend deciles and isolated the top 10% as VIP customers. Compared them against overall baseline using a 4-point risk score. VIP customers showed higher operational friction than average, but the issue was segment-level rather than specific individuals.

---

## SQL Concepts Practiced

- CTEs (`WITH` clause) — used in every case to write layered, readable logic
- Window Functions — `DENSE_RANK`, `NTILE`, `ROW_NUMBER` for customer ranking and segmentation
- `CASE WHEN` — for calculating refund rates, delay rates, and risk scores
- `CROSS JOIN` — comparing individual customer metrics against overall baseline
- Aggregations — `SUM`, `AVG`, `COUNT`, `COUNTIF`, `ROUND`
- Stored Procedure — dynamic SQL procedure to run summary by any dimension
- Views — 3 views created as a clean data layer for Looker Studio
- Subqueries — for percentage normalization

---

## Dashboard

Built in Looker Studio connected directly to BigQuery views.
**[View Dashboard →](https://datastudio.google.com/s/hthJzVXoBpk)**

Includes:
- KPI cards: Total Orders, Refund Orders, Delayed Orders, Revenue, Refund Value, Delayed Value
- Platform comparison bar charts
- Orders & Refunds by Delivery Time (dual-axis line chart)
- Orders & Refunds by Rating

---

## Key Learnings

- Data does not always confirm the initial assumption — and that is a valid finding worth presenting
- Structuring queries around business problems is more valuable than writing many random queries
- Window functions like `NTILE` are practical tools for customer segmentation
- Connecting BigQuery views to Looker Studio is a clean, professional workflow
- Writing insights that explain *why* a number looks the way it does matters more than just reporting the number

---

## Limitations

- Synthetic dataset — real-world data would likely show clearer differentiation between platforms
- No meaningful date column — time-series and trend analysis was not possible
- No product-level data — only category-level analysis was possible
- Customer feedback text was not used for NLP/sentiment analysis

---

*This project was built as part of my data analytics learning journey. All SQL was written and tested in BigQuery. Dashboard built in Looker Studio.*