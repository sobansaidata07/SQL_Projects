# Barclays: Data Analytics Virtual Experience Programme
### Completed via Springpod | May 2026

---

## 📋 About the Project

This project was completed as part of the **Barclays: Data Analytics** virtual experience programme in partnership with Barclays and Springpod. The goal was to analyse a real-world contact centre dataset and derive meaningful insights from it — simulating the kind of work a data analyst would do at Barclays.

---

## 📂 Dataset

The dataset contained **20 incidents** logged at a contact centre across various UK locations in July 2022. Each record included:
- Incident number and description
- Caller and agent details
- Location
- Opened and closed dates

---

## 🛠️ Tools Used

| Tool | Purpose |
|------|---------|
| **Google BigQuery** | Querying and analysing the dataset using SQL |
| **Power BI** | Creating the stacked bar chart for visual presentation |

---

## 🔍 Approach

### Q1 — Which was the busiest period?
I loaded the dataset into BigQuery and grouped incidents by their opened date to find the busiest days. I then analysed the data across date ranges to identify the peak period rather than just a single day, which gave a more meaningful picture of incident volume over time.

**Finding:** The busiest period was between **18th and 20th July 2022**, with 6 incidents recorded. Looking at a wider range, between **18th and 22nd July 2022**, a total of 11 incidents were raised — making this the overall busiest stretch.

---

### Q2 — Which category had the highest volume?
I grouped all incidents by their description/category and counted the occurrences of each to rank them by frequency.

**Finding:** **Call Quality** was the most frequently reported incident type, occurring **5 times** across the dataset.

---

### Q3 — Were there any repeat callers?
I grouped the data by Caller ID and filtered for callers who appeared more than once, identifying repeat offenders.

**Finding:** Two repeat callers were identified:
- **Zara Khan** — 2 incidents (Call Quality & System Crash)
- **Isaac Cohen** — 3 incidents (Distorted Audio x2 & System Crash)

---

## 📊 Stacked Bar Chart

A stacked bar chart was created in **Power BI** showing the volume and type of incidents broken down by location across the UK. This visualisation made it easy to spot which locations had the highest incident counts and what types of issues were most common in each area.

---

## 🏆 Certificate

Successfully completed and certified by Springpod & Barclays.
Certificate ID: `ekbbnhsnx221` | Issued: 28/05/2026

---

## 💡 Key Takeaways

- Hands-on experience working with a real-world business dataset
- Practised writing SQL queries in Google BigQuery
- Learned how to translate raw data into visual insights using Power BI
- Understood how data analytics supports decision-making in a banking/contact centre environment

---

*This project was completed as part of a virtual work experience programme and is intended to demonstrate analytical thinking and tool familiarity.*