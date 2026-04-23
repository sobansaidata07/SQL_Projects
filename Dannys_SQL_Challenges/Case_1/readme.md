# 🍜 Case Study #1 - Danny's Diner

## 📌 Source
[8 Week SQL Challenge by Danny Ma](https://8weeksqlchallenge.com/case-study-1/)

## 📖 Introduction
Danny opened a Japanese restaurant in 2021 selling sushi, 
curry and ramen. He wants to use customer data to understand 
visiting patterns, spending habits and favourite menu items
to help grow his loyalty program.

## 🗃️ Dataset
3 tables provided:

- **sales** — customer purchases with order dates
- **menu** — product names and prices  
- **members** — loyalty program join dates

## 🛠️ Tool Used
- MySQL v8

## ❓ Questions Solved
1. Total amount each customer spent
2. How many days each customer visited
3. First item purchased by each customer
4. Most purchased item on the menu
5. Most popular item for each customer
6. First item purchased after becoming a member
7. Item purchased just before becoming a member
8. Total items and amount spent before membership
9. Total points per customer (with sushi 2x multiplier)
10. Total points for A & B at end of January

## 📂 Files
- `dannys_Diner.sql` — all queries and solutions

## 💡 Concepts Used
- INNER JOINs
- Aggregate Functions (SUM, COUNT)
- Subqueries
- CTEs (Common Table Expressions)
- Window Functions (DENSE_RANK)
- CASE WHEN
- Date Functions (DATE_ADD)