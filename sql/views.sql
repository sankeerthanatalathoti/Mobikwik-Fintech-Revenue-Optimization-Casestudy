/* =====================================================================================
   View Name: vw_pillar1_revenue_time_series
   Purpose:
   Provides a monthly revenue time series combining net transaction revenue and
   interest revenue, used for revenue trend analysis, growth tracking, and
   performance monitoring in BI dashboards.
   ===================================================================================== */

CREATE OR REPLACE VIEW vw_pillar1_revenue_time_series AS
WITH transaction_revenue_monthly AS (
    SELECT
        DATE_FORMAT(transaction_date, '%Y-%m') AS year_month,
        COUNT(DISTINCT customer_id) AS active_customers,
        ROUND(
            SUM(fee_amount + revenue_amount - cashback_given),
            2
        ) AS net_transaction_revenue
    FROM fintech_database.transactions
    GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
),

interest_revenue_monthly AS (
    SELECT
        DATE_FORMAT(open_date, '%Y-%m') AS year_month,
        ROUND(
            SUM(
                (utilized_amount - total_amount_paid)
                * interest_rate
                * (tenure_months / 12)
            ),
            2
        ) AS interest_revenue
    FROM fintech_database.credit_accounts
    GROUP BY DATE_FORMAT(open_date, '%Y-%m')
),

combined_revenue AS (
    SELECT
        tr.year_month,
        tr.active_customers,
        tr.net_transaction_revenue,
        COALESCE(ir.interest_revenue, 0) AS interest_revenue,
        tr.net_transaction_revenue + COALESCE(ir.interest_revenue, 0) AS total_revenue
    FROM transaction_revenue_monthly tr
    LEFT JOIN interest_revenue_monthly ir
        ON tr.year_month = ir.year_month
)

SELECT
    year_month,
    active_customers,
    net_transaction_revenue,
    interest_revenue,
    total_revenue,

    -- Month-over-Month revenue change
    total_revenue
      - LAG(total_revenue) OVER (ORDER BY year_month) AS mom_revenue_change,

    ROUND(
        (
            total_revenue
            - LAG(total_revenue) OVER (ORDER BY year_month)
        ) / LAG(total_revenue) OVER (ORDER BY year_month) * 100,
        2
    ) AS mom_growth_pct,

    -- Cumulative revenue
    ROUND(
        SUM(total_revenue) OVER (
            ORDER BY year_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS cumulative_total_revenue

FROM combined_revenue;

/* =====================================================================================
   View Name: vw_pillar1_customer_performance
   Purpose:
   Provides a customer-level performance view enriched with demographic attributes,
   tenure, income segments, and profitability classification. This view supports
   customer segmentation analysis, ARPU evaluation, and identification of
   loss-making or low-margin customers for optimization strategies.
   ===================================================================================== */

CREATE OR REPLACE VIEW vw_pillar1_customer_performance AS
WITH customers_enriched AS (
    SELECT
        customer_id,
        gender,
        city,
        state,
        education_level,
        marital_status,
        signup_date,
        acquisition_channel,
        campaign_id,
        employment_type,
        customer_type,
        annual_income,

        -- Age
        TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) AS age,

        -- Age bucket
        CASE  
            WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 25 THEN '<25'
            WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 25 AND 34 THEN '25-34'
            WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 35 AND 44 THEN '35-44'
            WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 45 AND 54 THEN '45-54'
            ELSE '55+'
        END AS age_bucket,

        -- Income bucket
        CASE 
            WHEN annual_income < 500000 THEN 'Low'
            WHEN annual_income BETWEEN 500000 AND 1200000 THEN 'Medium'
            ELSE 'High'
        END AS income_bucket,

        -- Tenure
        TIMESTAMPDIFF(DAY, signup_date, CURDATE()) AS tenure_days,

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
        ROUND(SUM(fee_amount + revenue_amount - cashback_given), 2)
            AS net_transaction_revenue
    FROM fintech_database.transactions
    GROUP BY customer_id
),

interest_revenue_per_customer AS (
    SELECT
        customer_id,
        ROUND(SUM(
            (utilized_amount - total_amount_paid)
            * interest_rate
            * (tenure_months / 12)
        ), 2) AS interest_revenue
    FROM fintech_database.credit_accounts
    GROUP BY customer_id
)

SELECT
    c.customer_id,
    c.gender,
    c.city,
    c.state,
    c.education_level,
    c.marital_status,
    c.signup_date,
    c.acquisition_channel,
    c.campaign_id,
    c.employment_type,
    c.customer_type,
    c.age,
    c.age_bucket,
    c.income_bucket,
    c.tenure_days,
    c.tenure_bucket,

    COALESCE(tr.net_transaction_revenue, 0) AS net_transaction_revenue,
    COALESCE(ir.interest_revenue, 0) AS interest_revenue,
    COALESCE(tr.net_transaction_revenue, 0)
        + COALESCE(ir.interest_revenue, 0) AS total_revenue,

    CASE
        WHEN COALESCE(tr.net_transaction_revenue, 0)
           + COALESCE(ir.interest_revenue, 0) < 0
            THEN 'Loss-Making'
        WHEN COALESCE(tr.net_transaction_revenue, 0)
           + COALESCE(ir.interest_revenue, 0) BETWEEN 0 AND 100
            THEN 'Low Margin'
        ELSE 'Profitable'
    END AS profitability_flag

FROM customers_enriched c
LEFT JOIN transaction_revenue_per_customer tr
    ON c.customer_id = tr.customer_id
LEFT JOIN interest_revenue_per_customer ir
    ON c.customer_id = ir.customer_id;


/* =====================================================================================
   View Name: vw_pillar1_product_performance
   Purpose:
   Analyzes product-level transaction performance by combining volume metrics,
   revenue components, unit economics, and efficiency classification. This view
   helps identify high-volume low-margin products, premium low-volume products,
   and balanced offerings to support product mix optimization decisions.
   ===================================================================================== */

CREATE OR REPLACE VIEW vw_pillar1_product_performance AS
SELECT
    product_type,

    /* -------------------------
       Volume metrics
    ------------------------- */
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,

    /* -------------------------
       Revenue components (explicit)
    ------------------------- */
    ROUND(SUM(fee_amount), 2) AS total_fee_revenue,
    ROUND(SUM(revenue_amount), 2) AS total_revenue_amount,
    ROUND(SUM(cashback_given), 2) AS total_cashback_given,

    /* -------------------------
       Net transaction revenue
    ------------------------- */
    ROUND(
        SUM(fee_amount + revenue_amount - cashback_given),
        2
    ) AS net_transaction_revenue,

    /* -------------------------
       Unit economics
    ------------------------- */
    ROUND(
        SUM(fee_amount + revenue_amount - cashback_given) / COUNT(*),
        2
    ) AS avg_revenue_per_transaction,

    ROUND(
        SUM(cashback_given) / COUNT(*),
        2
    ) AS avg_cashback_per_transaction,

    /* -------------------------
       Efficiency flag (for BI slicing)
    ------------------------- */
    CASE
        WHEN
            COUNT(*) >
            (
                SELECT AVG(txn_cnt)
                FROM (
                    SELECT COUNT(*) AS txn_cnt
                    FROM fintech_database.transactions
                    GROUP BY product_type
                ) t
            )
        AND
            (
                SUM(fee_amount + revenue_amount - cashback_given) / COUNT(*)
            ) <
            (
                SELECT AVG(avg_rev)
                FROM (
                    SELECT
                        SUM(fee_amount + revenue_amount - cashback_given) / COUNT(*) AS avg_rev
                    FROM fintech_database.transactions
                    GROUP BY product_type
                ) a
            )
        THEN 'High Volume – Low Margin'

        WHEN
            COUNT(*) <
            (
                SELECT AVG(txn_cnt)
                FROM (
                    SELECT COUNT(*) AS txn_cnt
                    FROM fintech_database.transactions
                    GROUP BY product_type
                ) t
            )
        AND
            (
                SUM(fee_amount + revenue_amount - cashback_given) / COUNT(*)
            ) >
            (
                SELECT AVG(avg_rev)
                FROM (
                    SELECT
                        SUM(fee_amount + revenue_amount - cashback_given) / COUNT(*) AS avg_rev
                    FROM fintech_database.transactions
                    GROUP BY product_type
                ) a
            )
        THEN 'Low Volume – High Margin'

        ELSE 'Balanced'
    END AS product_efficiency_flag

FROM fintech_database.transactions
GROUP BY product_type;

