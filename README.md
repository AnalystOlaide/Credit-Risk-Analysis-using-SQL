## Credit Risk SQL Analysis


## 📄 Project Overview

This project analyzes the credit application and repayment behavior of customers from a fictional credit-lending institution. It answers business-critical questions around **loan approvals**, **repayment patterns**, **cumulative risk exposure**, and **data quality** using advanced SQL techniques. The goal is to help the credit company **identify risk-prone customers**, **track loan performance**, and **optimize approval decisions**.


## ❓ Problem Statement

A fictional credit-lending institution seeks to better understand its customer base, evaluate loan approval patterns, and identify potential financial risks through detailed SQL-driven analysis.

## 🎯 Key Business Questions

1. **Customer Profiling**
   - Who are the top earners per loan type?
   - What’s the average credit score by age group?
   - Which records have invalid contact details?

2. **Loan Analysis**
   - What’s the approval rate by gender and loan type?
   - Which loan purposes have the best/worst credit scores?
   - How many applications were submitted monthly in the last 2 years?

3. **Payment Behavior**
   - How soon do customers make their first payment?
   - Who are the most frequent late payers?
   - When do late payments peak (monthly/quarterly)?

4. **Repayment Tracking**
   - How much has each customer paid over time?
   - What’s each customer’s current balance?
   - What are the first and most recent payment dates?

5. **Operational Insights**
   - What are the most used payment methods by gender/loan type?
   - Which rejected applicants should be reconsidered?

6. **Engagement & Retention**
   - What’s the average number of payments per customer?
   - Who are the top 10 most active payers?

## Data Source

**Tables Used:**

* `credit_applications`: Contains demographic, loan, and credit information for each customer
* `payment_history`: Contains all customer payments with date, amount, and late status


## Tools Used

* **Database**: PostgreSQL
* **Techniques**:
  `JOIN`, `GROUP BY`, `ORDER BY`, `CASE`, `EXTRACT`, `DATE_TRUNC`, `WINDOW FUNCTIONS`, `UPDATE`, `IS NULL`, `LIKE`


## Business Questions & SQL Queries

**Viewing the tables**

SELECT *
FROM credit_applications;

![WhatsApp Image 2025-06-23 at 09 38 08_ef7677c2](https://github.com/user-attachments/assets/19c55c23-2bf9-4880-9150-8c0b11e792fd)
![WhatsApp Image 2025-06-23 at 09 38 48_35f031d1](https://github.com/user-attachments/assets/0c70b785-6076-463b-98c1-4b79aa1b79af)

SELECT *
FROM public.payment_history;

![WhatsApp Image 2025-06-23 at 09 40 08_f99dd630](https://github.com/user-attachments/assets/c10926b3-4d5f-4ca7-b7a4-90ecc22de414)


### 🏆 1. Top Earners by Loan Type

**Which 3 customers have the highest income for each loan type?**

![WhatsApp Image 2025-06-23 at 09 44 57_4d576d72](https://github.com/user-attachments/assets/1056be93-4b13-4956-b5eb-e7727f017446)

SELECT name, income, loan_type
FROM credit_applications
ORDER BY loan_type DESC
LIMIT 3;


### ✅ 2. Loan Approval Rates by Gender and Loan Type

**What is the approval rate (%) for each gender across different loan types?**

![image](https://github.com/user-attachments/assets/54f1bd33-d156-4c7d-9491-b38b0d6f7861)

SELECT 
    gender, 
    loan_type,
    ROUND(COUNT(CASE WHEN loan_status = 'Approved' THEN 1 END) * 100.0 / COUNT(*), 0) AS Approval_rate
FROM credit_applications
GROUP BY gender, loan_type
ORDER BY approval_rate DESC;


### 🎯 3. Credit Score by Age Group

**What is the average credit score by age ranges (21–30, 31–40, etc.)?**

![image](https://github.com/user-attachments/assets/037ea314-6b54-48b7-988f-e2b127085c90)

SELECT
CASE 
    WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 21 AND 30 THEN '21-30'
    WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 31 AND 40 THEN '31-40'
    WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 41 AND 50 THEN '41-50'
    WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 51 AND 60 THEN '51-60'
    WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 61 AND 70 THEN '61-70'
    ELSE '71+'
END AS age_group,
ROUND(AVG(credit_score), 0) AS avg_credit_score
FROM credit_applications
GROUP BY age_group
ORDER BY avg_credit_score DESC;


### 📅 4. Loan Application Trends

**How many applications were submitted monthly in the last 2 years?**

![WhatsApp Image 2025-06-23 at 09 56 54_66470469](https://github.com/user-attachments/assets/a673e212-f248-4b85-a6cc-c2cda4b4c747)

![WhatsApp Image 2025-06-23 at 09 57 21_7995a7f3](https://github.com/user-attachments/assets/faab01c9-28d6-4bc5-b732-0d8e024f0d5a)


SELECT 
  DATE_TRUNC('month', application_date) AS application_month,
  COUNT(*) AS applications_count
FROM credit_applications
WHERE application_date >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY application_month
ORDER BY applications_count DESC;


### ⚠️ 5. Risk by Loan Purpose

**Which loan purposes have the highest and lowest average credit scores?**

-- Highest

![image](https://github.com/user-attachments/assets/efeb050d-881a-438d-919f-bf4fa0d6a1d0)

SELECT 
purpose, 
ROUND(AVG(credit_score), 0) AS avg_credit_score
FROM credit_applications
GROUP BY purpose
ORDER BY avg_credit_score DESC
LIMIT 1;

-- Lowest

![image](https://github.com/user-attachments/assets/dc4277b4-7832-470e-a381-3c652136936f)

SELECT 
purpose, 
ROUND(AVG(credit_score), 0) AS avg_credit_score
FROM credit_applications
GROUP BY purpose
ORDER BY avg_credit_score
LIMIT 1;


### 🔁 6. Late Payment Analysis

**Which customers have the most late payments and what is their late payment rate?**

![image](https://github.com/user-attachments/assets/e0cf8343-d5b7-4f4b-8fea-f4a8fa1643cf)



SELECT 
    ca.name, 
    SUM(CASE WHEN ph.late_payment = TRUE THEN 1 ELSE 0 END) AS total_late_payment,
    ROUND(SUM(CASE WHEN ph.late_payment = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 0) AS total_late_payments_pct
FROM credit_applications ca
JOIN payment_history ph ON ca.customer_id = ph.customer_id 
GROUP BY ca.name
ORDER BY total_late_payment DESC
LIMIT 5;


### 📈 7. Cumulative (Rolling) Amount Paid Over Time (Year-over-Year)

**What is the cumulative amount paid by each customer over time?**

WITH yearly_payments AS (
    SELECT 
        ca.customer_id,
        ca.name,
        EXTRACT(YEAR FROM ph.payment_date) AS payment_year,
        SUM(ph.amount_paid) AS yearly_amount
    FROM credit_applications ca
    JOIN payment_history ph ON ca.customer_id = ph.customer_id
    GROUP BY ca.customer_id, ca.name, EXTRACT(YEAR FROM ph.payment_date)
)

SELECT 
    customer_id,
    name,
    payment_year,
    ROUND(
        SUM(yearly_amount) OVER (
            PARTITION BY customer_id
            ORDER BY payment_year
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 2
    ) AS cumulative_amount_paid
FROM yearly_payments
ORDER BY cumulative_amount_paid DESC
LIMIT 1;


![image](https://github.com/user-attachments/assets/c046e8c3-a333-4d56-8103-202339694f88)



### 🔢 8. Payment Frequency

* **What is the average number of payments per customer?**

![image](https://github.com/user-attachments/assets/9ffa2581-beea-4aac-aa2d-d73f5a34558d)

SELECT 
    ROUND(AVG(payment_count),0) AS avg_payments_per_customer
FROM (
    SELECT 
        customer_id,
        COUNT(*) AS payment_count
    FROM payment_history
    GROUP BY customer_id
) AS sub;
* **Who are the top 10 most active loan repayers?**

![image](https://github.com/user-attachments/assets/7c220562-dbb7-4421-b67c-28ec6961da3f)


SELECT ca.name, ph.customer_id, COUNT(*) AS total_payments
FROM payment_history ph
JOIN credit_applications ca ON ca.customer_id = ph.customer_id
GROUP BY ph.customer_id, ca.name
ORDER BY total_payments DESC
LIMIT 10;

### 🕒 9. Payment Timeliness

**What is the first and most recent payment date per customer?**

![WhatsApp Image 2025-06-23 at 12 03 36_b7d51f5b](https://github.com/user-attachments/assets/39dcaecf-927e-442a-8ee9-2130e0c63168)

SELECT customer_id,
MIN(payment_date) AS earliest_payment_date,
MAX(payment_date) AS most_recent_payment_date
FROM payment_history
GROUP BY customer_id;

### 🚀 10. Onboarding Speed

**How many days does it take (on average) for a customer to make their first payment after application?**
![image](https://github.com/user-attachments/assets/8bac62f7-a6c6-4660-81f1-afd67f6f9d7b)



SELECT 
    ROUND(AVG(first_payment_date - application_date), 0) AS avg_days_to_first_payment
FROM (
    SELECT 
        ca.customer_id,
        MIN(ca.application_date) AS application_date,
        MIN(ph.payment_date) AS first_payment_date
    FROM credit_applications ca
    JOIN payment_history ph ON ca.customer_id = ph.customer_id
    GROUP BY ca.customer_id
) AS customer_firsts;

### 🧼 11. Data Quality Check

**How many customer records have missing, blank, or invalid email or phone number formats?**

![image](https://github.com/user-attachments/assets/44ef98ae-3434-4088-86c1-869e1c6a7e87)


SELECT 
    COUNT(*) AS invalid_contact_count
FROM credit_applications
WHERE 
    email IS NULL
    OR TRIM(email) = ''
    OR email NOT LIKE '%@%.%'  
    OR phone IS NULL
    OR TRIM(phone) = ''
    OR phone !~ '^[0-9]{10,}$';
 


### 💳 12. Payment Method Analysis

**Which payment methods are used most frequently, and how do they vary by gender or loan type?**

![WhatsApp Image 2025-06-23 at 12 15 49_057e2d86](https://github.com/user-attachments/assets/578ac775-3a78-44c6-8024-e4ed00e83928)

SELECT ph.payment_method, ca.gender, ca.loan_type, COUNT(*) AS payment_method_ct
FROM credit_applications ca
JOIN payment_history ph ON ca.customer_id = ph.customer_id
GROUP BY ph.payment_method, ca.gender, ca.loan_type
ORDER BY payment_method_ct DESC;


### 📆 13. Seasonal Trends

* **Most late payments by month:** * 

![image](https://github.com/user-attachments/assets/eefd5d14-61ba-48b2-84e2-4dbf788bebd4)

SELECT 
    EXTRACT(MONTH FROM payment_date) AS month,
    COUNT(*) AS late_payment_count
FROM payment_history
WHERE late_payment = TRUE
GROUP BY EXTRACT(MONTH FROM payment_date)
ORDER BY late_payment_count DESC;


### 📋 14. Loan Performance Summary

**For each customer: loan amount, total paid, late payment count, and balance.**

![image](https://github.com/user-attachments/assets/1a0da5bf-db29-4374-8f75-74e49210b210)


(First 18 rows)

SELECT
    ca.name,
    ca.loan_amount,
    SUM(ph.amount_paid) AS total_paid,
    SUM(CASE WHEN ph.late_payment = TRUE THEN 1 ELSE 0 END) AS late_payment_count,
    ROUND(ca.loan_amount - SUM(ph.amount_paid), 0) AS current_balance
FROM credit_applications ca
LEFT JOIN payment_history ph ON ca.customer_id = ph.customer_id
GROUP BY ca.name, ca.loan_amount;

### 🔄 15. Credit Score Adjustment Simulation

**Update rejected applications with credit scores above 700 to “Pending Review.”**

![WhatsApp Image 2025-06-23 at 12 24 01_73f28b70](https://github.com/user-attachments/assets/ce6f3e6a-01e2-4b42-a578-38e1b00e659c)


UPDATE credit_applications
SET loan_status = 'Pending Review'
WHERE loan_status = 'Rejected' AND credit_score > 700;

