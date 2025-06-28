--View tables

SELECT *
FROM public.credit_applications;

SELECT *
FROM public.payment_history;

-- Which 3 customers have the highest income for each loan type?

SELECT name, income, loan_type
FROM credit_applications
ORDER BY loan_type DESC
LIMIT 3;

-- What is the loan approval rate (%) for each gender across different loan types?

SELECT 
    gender, 
    loan_type,
    ROUND(COUNT(CASE WHEN loan_status = 'Approved' THEN 1 END) * 100.0 / COUNT(*), 0) AS Approval_rate
FROM credit_applications
GROUP BY gender, loan_type
ORDER BY approval_rate DESC;


-- What is the average credit score for each age group (e.g., 21–30, 31–40, etc.)?

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


-- How many loan applications were submitted each month in the last 2 years?

SELECT 
    DATE_TRUNC('month', application_date) AS application_month,
    COUNT(*) AS applications_count
FROM credit_applications
WHERE application_date >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY application_month
ORDER BY applications_count DESC;

-- Which loan purpose has the highest and lowest average credit scores?

--Highest

SELECT 
purpose, 
ROUND(AVG(credit_score), 0) AS avg_credit_score
FROM credit_applications
GROUP BY purpose
ORDER BY avg_credit_score DESC
LIMIT 1;

--Lowest

SELECT 
purpose, 
ROUND(AVG(credit_score), 0) AS avg_credit_score
FROM credit_applications
GROUP BY purpose
ORDER BY avg_credit_score
LIMIT 1;

-- Which customers have the highest number of late payments, and what is their late payment rate?

SELECT 
    ca.name, 
    SUM(CASE WHEN ph.late_payment = TRUE THEN 1 ELSE 0 END) AS total_late_payment,
    ROUND(SUM(CASE WHEN ph.late_payment = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 0) AS total_late_payments_pct
FROM credit_applications ca
JOIN payment_history ph ON ca.customer_id = ph.customer_id 
GROUP BY ca.name
ORDER BY total_late_payment DESC
LIMIT 5;

-- What is the TOP cumulative (rolling) amount paid by each customer over time?

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

--What is the average number of payments per customer, and Who are the top 10 most active loan repayers?

-- 1. Average number of payments per customer
SELECT 
    ROUND(AVG(payment_count),0) AS avg_payments_per_customer
FROM (
    SELECT 
        customer_id,
        COUNT(*) AS payment_count
    FROM payment_history
    GROUP BY customer_id
) AS sub;

-- 2. Top 10 most active loan repayers

SELECT 
    ca.name,
    ca.customer_id,
    ca.loan_amount,
    SUM(ph.amount_paid) AS total_paid,
    ROUND(SUM(ph.amount_paid) * 100.0 / ca.loan_amount, 2) AS repayment_percentage,
    ca.loan_amount - SUM(ph.amount_paid) AS balance_remaining
FROM credit_applications ca
JOIN payment_history ph ON ca.customer_id = ph.customer_id
GROUP BY ca.name, ca.customer_id, ca.loan_amount
HAVING SUM(ph.amount_paid) > 0
ORDER BY repayment_percentage DESC
LIMIT 10;




-- What is the earliest and most recent payment date recorded for each customer?
SELECT
    customer_id,
    MIN(payment_date) AS earliest_payment_date,
    MAX(payment_date) AS most_recent_payment_date
FROM payment_history
GROUP BY customer_id;

-- How many days (on average) does it take each customer to make their first payment after the loan application date?

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

-- How many customer records have missing, blank, or invalid email or phone number formats?
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
 
-- Which payment method is used most frequently, and how does it vary by gender or loan type?

SELECT 
    ph.payment_method, 
    ca.gender, 
    ca.loan_type,
    COUNT(*) AS payment_method_ct
FROM credit_applications ca
JOIN payment_history ph ON ca.customer_id = ph.customer_id
GROUP BY ph.payment_method, ca.gender, ca.loan_type
ORDER BY payment_method_ct DESC;

-- During which months are late payments most frequent?
SELECT 
    EXTRACT(MONTH FROM payment_date) AS month,
    COUNT(*) AS late_payment_count
FROM payment_history
WHERE late_payment = TRUE
GROUP BY EXTRACT(MONTH FROM payment_date)
ORDER BY late_payment_count DESC;


-- For each customer, display the loan amount, total paid amount, count of late payments, and current balance.

SELECT
    ca.name,
    ca.loan_amount,
    SUM(ph.amount_paid) AS total_paid,
    SUM(CASE WHEN ph.late_payment = TRUE THEN 1 ELSE 0 END) AS late_payment_count,
    ROUND(ca.loan_amount - SUM(ph.amount_paid), 0) AS current_balance
FROM credit_applications ca
LEFT JOIN payment_history ph ON ca.customer_id = ph.customer_id
GROUP BY ca.name, ca.loan_amount;

-- Simulate updating the status of all rejected applications with credit scores above 700 to “Pending Review.”

UPDATE credit_applications
SET loan_status = 'Pending Review'
WHERE loan_status = 'Rejected' AND credit_score > 700;

