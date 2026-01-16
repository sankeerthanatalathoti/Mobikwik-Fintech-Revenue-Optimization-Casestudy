/* =====================================================================================
   EDA 1: Monthly Revenue Trend & Growth Analysis
   Business Question:
   How has total revenue evolved over time, and what is the month-over-month (MoM)
   growth pattern across transaction and interest-based revenue streams?
   ===================================================================================== */

WITH transaction_revenue_monthly AS (
    SELECT 
        DATE_FORMAT(t.transaction_date, '%Y-%m') AS yearmonth,
        COUNT(DISTINCT t.customer_id) AS total_customers,
        ROUND(
            SUM(t.fee_amount + t.revenue_amount - t.cashback_given),
            2
        ) AS net_transaction_revenue
    FROM fintech_database.transactions t
    GROUP BY DATE_FORMAT(t.transaction_date, '%Y-%m')
),

interest_revenue_monthly AS (
    SELECT
        DATE_FORMAT(ca.open_date, '%Y-%m') AS yearmonth,
        ROUND(
            SUM(
                (ca.utilized_amount - ca.total_amount_paid)
                * ca.interest_rate
                * (ca.tenure_months / 12)
            ),
            2
        ) AS interest_revenue
    FROM fintech_database.credit_accounts ca
    GROUP BY

/* =====================================================================================
   EDA 2: Average Revenue Per Customer (ARPU) Trend Analysis
   Business Question:
   How does average revenue per customer (ARPU) change over time, and how does it
   relate to total revenue growth and active customer base expansion?
   ===================================================================================== */

WITH revenue_union AS (

    /* -----------------------------------------------------
       Transaction revenue per customer per month
       ----------------------------------------------------- */
    SELECT
        DATE_FORMAT(t.transaction_date, '%Y-%m') AS yearmonth,
        t.customer_id,
        (t.fee_amount + t.revenue_amount - t.cashback_given) AS revenue
    FROM fintech_database.transactions t

    UNION ALL

    /* -----------------------------------------------------
       Interest revenue per customer per month
       ----------------------------------------------------- */
    SELECT
        DATE_FORMAT(ca.open_date, '%Y-%m') AS yearmonth,
        ca.customer_id,
        (
            (ca.utilized_amount - ca.total_amount_paid)
            * ca.interest_rate
            * (ca.tenure_months / 12)
        ) AS revenue
    FROM fintech_database.credit_accounts ca
),

monthly_customer_revenue AS (
    SELECT
        yearmonth,
        customer_id,
        ROUND(SUM(revenue), 2) AS total_revenue_per_customer
    FROM revenue_union
    GROUP BY yearmonth, customer_id
)

SELECT
    yearmonth,
    ROUND(SUM(total_revenue_per_customer), 2) AS total_revenue,
    COUNT(DISTINCT customer_id) AS active_customers,
    ROUND(
        SUM(total_revenue_per_customer)
        / COUNT(DISTINCT customer_id),
        2
    ) AS avg_revenue_per_customer
FROM monthly_customer_revenue
GROUP BY yearmonth
ORDER BY yearmonth;


/* =====================================================================================
   EDA 3: Transaction Revenue Seasonality Analysis
   Business Question:
   Are there recurring seasonal patterns in transaction revenue across calendar months,
   indicating consistent high or low revenue periods?
   ===================================================================================== */

WITH transaction_rev AS (
    SELECT 
        DATE_FORMAT(t.transaction_date, '%Y-%m') AS yearmonth,
        YEAR(t.transaction_date) AS year,
        MONTH(t.transaction_date) AS month_num,
        MONTHNAME(t.transaction_date) AS month_name,
        COUNT(t.transaction_date) AS transaction_count,
        ROUND(
            SUM(t.fee_amount + t.revenue_amount - t.cashback_given),
            2
        ) AS net_transaction_revenue
    FROM fintech_database.transactions t
    GROUP BY
        DATE_FORMAT(t.transaction_date, '%Y-%m'),
        YEAR(t.transaction_date),
        MONTH(t.transaction_date),
        MONTHNAME(t.transaction_date)
),

calendar_month_avg AS (
    SELECT
        month_num,
        month_name,
        ROUND(AVG(net_transaction_revenue), 2) AS avg_calendar_month_revenue
    FROM transaction_rev
    GROUP BY
        month_num,
        month_name
),

overall_monthly_avg AS (
    SELECT 
        ROUND(AVG(avg_calendar_month_revenue), 2) AS overall_avg_revenue
    FROM calendar_month_avg
)

SELECT
    cma.month_num,
    cma.month_name,
    cma.avg_calendar_month_revenue,
    oma.overall_avg_revenue,
    CASE
        WHEN cma.avg_calendar_month_revenue > oma.overall_avg_revenue
            THEN 'High Season'
        WHEN cma.avg_calendar_month_revenue < oma.overall_avg_revenue
            THEN 'Off Season'
        ELSE 'Normal'
    END AS seasonality_type
FROM calendar_month_avg cma
CROSS JOIN overall_monthly_avg oma
ORDER BY cma.month_num;


/* =====================================================================================
   EDA 4: Year-over-Year Revenue Volatility Analysis
   Business Question:
   How does total revenue volatility change year over year, and which years exhibit
   higher-than-normal fluctuations compared to historical averages?
   
   Methodology:
   - Calculate YoY % change in total revenue
   - Compute average absolute YoY % change as a volatility baseline
   - Classify each year as High / Low / Normal volatility
   ===================================================================================== */

WITH transaction_revenue_yearly AS (
    SELECT 
        DATE_FORMAT(t.transaction_date, '%Y') AS yearcheck,
        COUNT(DISTINCT t.customer_id) AS total_customers,
        ROUND(
            SUM(t.fee_amount + t.revenue_amount - t.cashback_given),
            2
        ) AS net_transaction_revenue
    FROM fintech_database.transactions t
    GROUP BY DATE_FORMAT(t.transaction_date, '%Y')
),

interest_revenue_yearly AS (
    SELECT
        DATE_FORMAT(ca.open_date, '%Y') AS yearcheck,
        ROUND(
            SUM(
                (ca.utilized_amount - ca.total_amount_paid)
                * ca.interest_rate
                * (ca.tenure_months / 12)
            ),
            2
        ) AS interest_revenue
    FROM fintech_database.credit_accounts ca
    GROUP BY DATE_FORMAT(ca.open_date, '%Y')
),

total_revenue AS (
    SELECT
        try.yearcheck,
        ROUND(
            try.net_transaction_revenue
            + COALESCE(iry.interest_revenue, 0),
            2
        ) AS total_revenue
    FROM transaction_revenue_yearly try
    LEFT JOIN interest_revenue_yearly iry
        ON try.yearcheck = iry.yearcheck
),

yoy_calc AS (
    SELECT
        yearcheck,
        total_revenue,
        COALESCE(
            LAG(total_revenue) OVER (ORDER BY yearcheck),
            0
        ) AS previous_year_revenue,
        ROUND(
            (total_revenue - LAG(total_revenue) OVER (ORDER BY yearcheck))
            / LAG(total_revenue) OVER (ORDER BY yearcheck)
            * 100,
            2
        ) AS yoy_pct_change
    FROM total_revenue
),

volatility_baseline AS (
    SELECT
        AVG(ABS(yoy_pct_change)) AS avg_abs_yoy_change
    FROM yoy_calc
    WHERE yoy_pct_change IS NOT NULL
)

SELECT
    yc.yearcheck,
    yc.total_revenue,
    yc.previous_year_revenue,
    yc.yoy_pct_change,
    ABS(yc.yoy_pct_change) AS abs_yoy_pct_change,
    vb.avg_abs_yoy_change,
    CASE
        WHEN ABS(yc.yoy_pct_change) > vb.avg_abs_yoy_change
            THEN 'High Volatility'
        WHEN ABS(yc.yoy_pct_change) < vb.avg_abs_yoy_change
            THEN 'Low Volatility'
        ELSE 'Normal Volatility'
    END AS volatility_flag
FROM yoy_calc yc
CROSS JOIN volatility_baseline vb
ORDER BY yc.yearcheck;

/* =====================================================================================
   EDA 5: Cumulative Total Revenue Growth Analysis
   Business Question:
   How has cumulative total revenue evolved over time, and what does the year-over-year
   change in cumulative revenue indicate about long-term revenue sustainability?
   
   Methodology:
   - Aggregate yearly transaction and interest revenue
   - Compute total revenue per year
   - Calculate running (cumulative) total revenue
   - Measure YoY % change in cumulative revenue
   ===================================================================================== */

WITH transaction_revenue_yearly AS (
    SELECT 
        DATE_FORMAT(t.transaction_date, '%Y') AS date_year,
        COUNT(DISTINCT t.customer_id) AS total_customers,
        ROUND(
            SUM(t.fee_amount + t.revenue_amount - t.cashback_given),
            2
        ) AS net_transaction_revenue
    FROM fintech_database.transactions t
    GROUP BY DATE_FORMAT(t.transaction_date, '%Y')
),

interest_revenue_yearly AS (
    SELECT
        DATE_FORMAT(ca.open_date, '%Y') AS date_year,
        ROUND(
            SUM(
                (ca.utilized_amount - ca.total_amount_paid)
                * ca.interest_rate
                * (ca.tenure_months / 12)
            ),
            2
        ) AS interest_revenue
    FROM fintech_database.credit_accounts ca
    GROUP BY DATE_FORMAT(ca.open_date, '%Y')
),

total_revenue_cte AS (
    SELECT
        try.date_year,
        try.total_customers,
        try.net_transaction_revenue,
        COALESCE(iry.interest_revenue, 0) AS interest_revenue,
        ROUND(
            try.net_transaction_revenue
            + COALESCE(iry.interest_revenue, 0),
            2
        ) AS total_revenue
    FROM transaction_revenue_yearly try
    LEFT JOIN interest_revenue_yearly iry
        ON try.date_year = iry.date_year
),

cumulative_calc AS (
    SELECT
        date_year,
        total_revenue,
        SUM(total_revenue)
            OVER (
                ORDER BY date_year
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS running_total_revenue
    FROM total_revenue_cte
)

SELECT
    date_year,
    total_revenue,
    running_total_revenue,
    LAG(running_total_revenue)
        OVER (ORDER BY date_year) AS previous_year_running_total,
    ROUND(
        (running_total_revenue
         - LAG(running_total_revenue) OVER (ORDER BY date_year))
        / COALESCE(LAG(running_total_revenue) OVER (ORDER BY date_year), 0)
        * 100,
        2
    ) AS yoy_pct_change_cumulative
FROM cumulative_calc
ORDER BY date_year;

/* =====================================================================================
   Customer Performance Analysis
   Dimension: Age Bucket
   Business Question:
   How does average revenue per customer (ARPU) differ across customer age groups,
   and which age segments contribute disproportionately to total revenue?
   ===================================================================================== */

WITH customers_cte AS (
    SELECT
        customer_id,
        signup_date,
        acquisition_channel,
        campaign_id,
        gender,
        city,
        state,
        employment_type,
        education_level,
        marital_status,
        customer_type,
        annual_income,

        /* ---------------- Age & Segmentation Buckets ---------------- */
        TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) AS age,

        CASE  
            WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 25 THEN '<25'
            WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 25 AND 34 THEN '25-34'
            WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 35 AND 44 THEN '35-44'
            WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 45 AND 54 THEN '45-54'
            ELSE '55+'
        END AS age_bucket,

        CASE 
            WHEN annual_income < 500000 THEN 'Low'
            WHEN annual_income BETWEEN 500000 AND 1200000 THEN 'Medium'
            ELSE 'High'
        END AS income_bucket,

        CASE 
            WHEN TIMESTAMPDIFF(DAY, signup_date, CURDATE()) < 180 THEN 'New'
            WHEN TIMESTAMPDIFF(DAY, signup_date, CURDATE()) BETWEEN 180 AND 365 THEN 'Growing'
            ELSE 'Mature'
        END AS tenure_bucket
    FROM fintech_database.customers
),

transaction_revenue_per_customer AS (
    SELECT
        customer_id,
        ROUND(
            SUM(fee_amount + revenue_amount - cashback_given),
            2
        ) AS net_transaction_revenue
    FROM fintech_database.transactions
    GROUP BY customer_id
),

interest_revenue_per_customer AS (
    SELECT
        customer_id,
        ROUND(
            SUM(
                (utilized_amount - total_amount_paid)
                * interest_rate
                * (tenure_months / 12)
            ),
            2
        ) AS interest_revenue
    FROM fintech_database.credit_accounts
    GROUP BY customer_id
),

total_revenue_per_customer AS (
    SELECT
        c.customer_id,
        c.age_bucket,
        c.income_bucket,
        c.tenure_bucket,
        COALESCE(tr.net_transaction_revenue, 0) AS net_transaction_revenue,
        COALESCE(ir.interest_revenue, 0) AS interest_revenue,
        COALESCE(tr.net_transaction_revenue, 0)
        + COALESCE(ir.interest_revenue, 0) AS total_revenue
    FROM customers_cte c
    LEFT JOIN transaction_revenue_per_customer tr
        ON c.customer_id = tr.customer_id
    LEFT JOIN interest_revenue_per_customer ir
        ON c.customer_id = ir.customer_id
)

SELECT
    age_bucket,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    COUNT(DISTINCT customer_id) AS customers_count,
    ROUND(
        SUM(total_revenue) / COUNT(DISTINCT customer_id),
        2
    ) AS avg_revenue_per_customer
FROM total_revenue_per_customer
GROUP BY age_bucket
ORDER BY total_revenue DESC;

/* =====================================================================================
   Customer Performance Analysis
   Dimension: Employment Type
   Business Question:
   How does average revenue per customer (ARPU) differ across employment types, and
   which employment segments contribute the most to overall revenue?
   ===================================================================================== */

WITH customers_cte AS (
    SELECT
        customer_id,
        employment_type
    FROM fintech_database.customers
),

transaction_revenue_per_customer AS (
    SELECT
        customer_id,
        ROUND(
            SUM(fee_amount + revenue_amount - cashback_given),
            2
        ) AS net_transaction_revenue
    FROM fintech_database.transactions
    GROUP BY customer_id
),

interest_revenue_per_customer AS (
    SELECT
        customer_id,
        ROUND(
            SUM(
                (utilized_amount - total_amount_paid)
                * interest_rate
                * (tenure_months / 12)
            ),
            2
        ) AS interest_revenue
    FROM fintech_database.credit_accounts
    GROUP BY customer_id
),

total_revenue_per_customer AS (
    SELECT
        c.customer_id,
        c.employment_type,
        COALESCE(tr.net_transaction_revenue, 0) AS net_transaction_revenue,
        COALESCE(ir.interest_revenue, 0) AS interest_revenue,
        COALESCE(tr.net_transaction_revenue, 0)
        + COALESCE(ir.interest_revenue, 0) AS total_revenue
    FROM customers_cte c
    LEFT JOIN transaction_revenue_per_customer tr
        ON c.customer_id = tr.customer_id
    LEFT JOIN interest_revenue_per_customer ir
        ON c.customer_id = ir.customer_id
)

SELECT
    employment_type,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    COUNT(DISTINCT customer_id) AS customers_count,
    ROUND(
        SUM(total_revenue) / COUNT(DISTINCT customer_id),
        2
    ) AS avg_revenue_per_customer
FROM total_revenue_per_customer
GROUP BY employment_type
ORDER BY total_revenue DESC;

/* =====================================================================================
   Customer Performance Analysis
   Dimension: Customer Type
   Business Question:
   How does average revenue per customer (ARPU) differ across customer types, and
   which customer segments contribute the most to total revenue?
   ===================================================================================== */

WITH customers_cte AS (
    SELECT
        customer_id,
        customer_type
    FROM fintech_database.customers
),

transaction_revenue_per_customer AS (
    SELECT
        customer_id,
        ROUND(
            SUM(fee_amount + revenue_amount - cashback_given),
            2
        ) AS net_transaction_revenue
    FROM fintech_database.transactions
    GROUP BY customer_id
),

interest_revenue_per_customer AS (
    SELECT
        customer_id,
        ROUND(
            SUM(
                (utilized_amount - total_amount_paid)
                * interest_rate
                * (tenure_months / 12)
            ),
            2
        ) AS interest_revenue
    FROM fintech_database.credit_accounts
    GROUP BY customer_id
),

total_revenue_per_customer AS (
    SELECT
        c.customer_id,
        c.customer_type,
        COALESCE(tr.net_transaction_revenue, 0) AS net_transaction_revenue,
        COALESCE(ir.interest_revenue, 0) AS interest_revenue,
        COALESCE(tr.net_transaction_revenue, 0)
        + COALESCE(ir.interest_revenue, 0) AS total_revenue
    FROM customers_cte c
    LEFT JOIN transaction_revenue_per_customer tr
        ON c.customer_id = tr.customer_id
    LEFT JOIN interest_revenue_per_customer ir
        ON c.customer_id = ir.customer_id
)

SELECT
    customer_type,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    COUNT(DISTINCT customer_id) AS customers_count,
    ROUND(
        SUM(total_revenue) / COUNT(DISTINCT customer_id),
        2
    ) AS avg_revenue_per_customer
FROM total_revenue_per_customer
GROUP BY customer_type
ORDER BY total_revenue DESC;

/* =====================================================================================
   Customer Revenue Leakage Analysis
   Business Question:
   Which customers generate negative or low net revenue, indicating potential
   loss-making segments or inefficient monetization?
   
   Objective:
   - Identify loss-making and low-margin customers
   - Quantify revenue leakage at the individual customer level
   - Support targeted monetization and cost-optimization strategies
   ===================================================================================== */

WITH transaction_revenue_per_customer AS (
    SELECT
        customer_id,
        ROUND(
            SUM(fee_amount + revenue_amount - cashback_given),
            2
        ) AS net_transaction_revenue
    FROM fintech_database.transactions
    GROUP BY customer_id
),

interest_revenue_per_customer AS (
    SELECT
        customer_id,
        ROUND(
            SUM(
                (utilized_amount - total_amount_paid)
                * interest_rate
                * (tenure_months / 12)
            ),
            2
        ) AS interest_revenue
    FROM fintech_database.credit_accounts
    GROUP BY customer_id
),

total_revenue_per_customer AS (
    SELECT
        c.customer_id,
        COALESCE(tr.net_transaction_revenue, 0) AS net_transaction_revenue,
        COALESCE(ir.interest_revenue, 0) AS interest_revenue,
        COALESCE(tr.net_transaction_revenue, 0)
        + COALESCE(ir.interest_revenue, 0) AS total_revenue
    FROM fintech_database.customers c
    LEFT JOIN transaction_revenue_per_customer tr
        ON c.customer_id = tr.customer_id
    LEFT JOIN interest_revenue_per_customer ir
        ON c.customer_id = ir.customer_id
)

SELECT
    customer_id,
    net_transaction_revenue,
    interest_revenue,
    total_revenue,
    CASE
        WHEN total_revenue < 0 THEN 'Loss-Making'
        WHEN total_revenue BETWEEN 0 AND 100 THEN 'Low Margin'
        ELSE 'Profitable'
    END AS customer_profitability_flag
FROM total_revenue_per_customer
ORDER BY total_revenue ASC;
/* =====================================================================================
   Product Performance Analysis
   Dimension: Product Type
   Business Question:
   Which product types generate the highest net transaction revenue, and how do
   transaction volumes and average revenue per transaction vary across products?
   ===================================================================================== */

SELECT
    product_type,
    COUNT(*) AS total_transactions,
    ROUND(
        SUM(fee_amount + revenue_amount - cashback_given),
        2
    ) AS net_transaction_revenue,
    ROUND(
        SUM(fee_amount + revenue_amount - cashback_given)
        / COUNT(*),
        2
    ) AS avg_revenue_per_transaction
FROM fintech_database.transactions
GROUP BY product_type
ORDER BY net_transaction_revenue DESC;

/* =====================================================================================
   Product Performance Analysis
   Focus: Product Efficiency & Revenue Quality
   Business Question:
   Which product types are high-volume but low-margin versus low-volume but high-margin,
   and how can product mix optimization improve overall revenue quality?
   
   Methodology:
   - Calculate transaction volume and revenue metrics per product
   - Establish benchmark averages across products
   - Classify products based on volume–margin efficiency
   ===================================================================================== */

WITH product_metrics AS (
    SELECT
        product_type,
        COUNT(*) AS total_transactions,
        ROUND(
            SUM(fee_amount + revenue_amount - cashback_given),
            2
        ) AS net_transaction_revenue,
        ROUND(
            SUM(fee_amount + revenue_amount - cashback_given)
            / COUNT(*),
            2
        ) AS avg_revenue_per_transaction
    FROM fintech_database.transactions
    GROUP BY product_type
),

benchmarks AS (
    SELECT
        AVG(total_transactions) AS avg_txn_volume,
        AVG(avg_revenue_per_transaction) AS avg_txn_margin
    FROM product_metrics
)

SELECT
    pm.product_type,
    pm.total_transactions,
    pm.net_transaction_revenue,
    pm.avg_revenue_per_transaction,
    CASE
        WHEN pm.total_transactions > b.avg_txn_volume
             AND pm.avg_revenue_per_transaction < b.avg_txn_margin
            THEN 'High Volume – Low Margin'
        WHEN pm.total_transactions < b.avg_txn_volume
             AND pm.avg_revenue_per_transaction > b.avg_txn_margin
            THEN 'Low Volume – High Margin'
        ELSE 'Balanced'
    END AS efficiency_status
FROM product_metrics pm
CROSS JOIN benchmarks b
ORDER BY pm.net_transaction_revenue DESC;




  
