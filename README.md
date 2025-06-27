## Credit Risk SQL Analysis


## 📄 Project Overview

This project analyzes the credit application and repayment behavior of customers from a fictional credit-lending institution. It answers business-critical questions around **loan approvals**, **repayment patterns**, **cumulative risk exposure**, and **data quality** using advanced SQL techniques. The goal is to help the credit company **identify risk-prone customers**, **track loan performance**, and **optimize approval decisions**.


## ❓ Problem Statement

Credit lenders must proactively evaluate **applicant reliability** and **repayment behavior** to avoid loan defaults. This project uses structured data to provide insights such as:

* Who pays late and how often?
* Which loan types or purposes have high or low approval and credit scores?
* Which customers have built a strong repayment record over time?


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

![image](https://github.com/user-attachments/assets/ba044c19-7892-42b6-94fd-58036ab9bd18)

SELECT 
    gender, 
    loan_type,
    COUNT(CASE WHEN loan_status = 'Approved' THEN 1 END) AS approved_count,
    ROUND(COUNT(CASE WHEN loan_status = 'Approved' THEN 1 END) * 100.0 / COUNT(*), 0) AS Approval_rate
FROM credit_applications
GROUP BY gender, loan_type;


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

![image](https://github.com/user-attachments/assets/3c71d7a1-b8a5-4958-8cab-1dd40994271b)

SELECT ca.name, ca.customer_id,
COUNT(*) AS total_payments,
SUM(CASE WHEN ph.late_payment = TRUE THEN 1 ELSE 0 END) AS total_late_payment,
ROUND(SUM(CASE WHEN ph.late_payment = TRUE THEN 1 ELSE 0 END)* 100/ COUNT(*),0) AS total_late_payments_pct
FROM credit_applications ca
JOIN payment_history ph ON ca.customer_id = ph.customer_id 
GROUP BY ca.name, ca.customer_id
ORDER BY  total_late_payment DESC
LIMIT 1;


### 📈 7. Cumulative (Rolling) Amount Paid Over Time (Year-over-Year)

**What is the cumulative amount paid by each customer over time?**

SELECT 
  ca.name,
  EXTRACT(YEAR FROM ph.payment_date) AS payment_year,
  SUM(SUM(ph.amount_paid)) OVER (
      PARTITION BY ca.customer_id
      ORDER BY EXTRACT(YEAR FROM ph.payment_date)
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cumulative_amount_paid
FROM credit_applications ca
JOIN payment_history ph ON ca.customer_id = ph.customer_id
GROUP BY ca.name, ca.customer_id, EXTRACT(YEAR FROM ph.payment_date)
ORDER BY cumulative_amount_paid DESC, payment_year;

![WhatsApp Image 2025-06-23 at 10 03 15_a41ab4d5](https://github.com/user-attachments/assets/268cd5d4-537a-4014-b997-c72b903a9346)


### 🔢 8. Payment Frequency

* **What is the average number of payments per customer?**

![WhatsApp Image 2025-06-23 at 11 40 54_a73369bd](https://github.com/user-attachments/assets/2b4b5e93-4540-4e53-8973-3828b8197137)



SELECT 
  AVG(payment_count) AS avg_payments_per_customer
FROM (
  SELECT customer_id, COUNT(*) AS payment_count
  FROM payment_history
  GROUP BY customer_id
) AS sub;

* **Who are the top 10 most active payers?**

![WhatsApp Image 2025-06-23 at 11 41 44_0cc588cc](https://github.com/user-attachments/assets/3c6c8e64-efbc-44fc-a18f-4e26807484ad)

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

![WhatsApp Image 2025-06-23 at 12 07 41_5b3bbb11](https://github.com/user-attachments/assets/4ecf722a-0e8d-4c0f-afc1-e16e05906284)


SELECT AVG(first_payment_date - application_date) AS avg_days_to_first_payment
FROM (
  SELECT ca.customer_id,
         MIN(ca.application_date) AS application_date,
         MIN(ph.payment_date) AS first_payment_date
  FROM credit_applications ca
  JOIN payment_history ph ON ca.customer_id = ph.customer_id
  GROUP BY ca.customer_id
) AS customer_firsts;

### 🧼 11. Data Quality Check

**Which customers have missing or invalid emails or phone numbers?**

![WhatsApp Image 2025-06-23 at 12 13 57_10df2f40](https://github.com/user-attachments/assets/62123519-b5ed-4d8d-85e9-c1642c3cb318)

SELECT *
FROM credit_applications
WHERE 
    email IS NULL OR TRIM(email) = '' OR email NOT LIKE '%@%.%'  
 OR phone IS NULL OR TRIM(phone) = '' OR phone !~ '^[0-9]{10,}$';


### 💳 12. Payment Method Analysis

**Which payment methods are used most frequently, and how do they vary by gender or loan type?**

![WhatsApp Image 2025-06-23 at 12 15 49_057e2d86](https://github.com/user-attachments/assets/578ac775-3a78-44c6-8024-e4ed00e83928)

SELECT ph.payment_method, ca.gender, ca.loan_type, COUNT(*) AS payment_method_ct
FROM credit_applications ca
JOIN payment_history ph ON ca.customer_id = ph.customer_id
GROUP BY ph.payment_method, ca.gender, ca.loan_type
ORDER BY payment_method_ct DESC;


### 📆 13. Seasonal Trends

* **Most late payments by month:**

![WhatsApp Image 2025-06-23 at 12 17 29_8e946c00](https://github.com/user-attachments/assets/cbbb2aa8-9c36-4019-8428-11a5eba7fa74)

SELECT EXTRACT(YEAR FROM payment_date) AS year,
       EXTRACT(MONTH FROM payment_date) AS month,
       COUNT(*) AS late_payment_count
FROM payment_history
WHERE late_payment = TRUE
GROUP BY year, month
ORDER BY late_payment_count DESC;


### 📋 14. Loan Performance Summary

**For each customer: loan amount, total paid, late payment count, and balance.**

![WhatsApp Image 2025-06-23 at 12 19 35_8fe13092](https://github.com/user-attachments/assets/4071b464-355e-4c11-ab0f-d390e5d12e4c)

SELECT
  ca.customer_id,
  ca.loan_amount,
  SUM(ph.amount_paid) AS total_paid,
  SUM(CASE WHEN ph.late_payment = TRUE THEN 1 ELSE 0 END) AS late_payment_count,
  ca.loan_amount - SUM(ph.amount_paid) AS current_balance
FROM credit_applications ca
LEFT JOIN payment_history ph ON ca.customer_id = ph.customer_id
GROUP BY ca.customer_id, ca.loan_amount;

### 🔄 15. Credit Score Adjustment Simulation

**Update rejected applications with credit scores above 700 to “Pending Review.”**

![WhatsApp Image 2025-06-23 at 12 24 01_73f28b70](https://github.com/user-attachments/assets/ce6f3e6a-01e2-4b42-a578-38e1b00e659c)


UPDATE credit_applications
SET loan_status = 'Pending Review'
WHERE loan_status = 'Rejected' AND credit_score > 700;

