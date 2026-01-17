SQL View Output Tables – Documentation
=====================================

This file documents the output of the analytical SQL views created in `views.sql`.
The actual result sets are captured as screenshots due to wide schemas and large
column counts, which are difficult to represent cleanly as static tables.

All screenshots are uploaded in the `sql/` directory and named according to the
corresponding view.

------------------------------------------------------------
1. Revenue Time Series View
------------------------------------------------------------
View Name:
vw_pillar1_revenue_time_series

Purpose:
Provides a month-level revenue time series combining:
- Net transaction revenue
- Interest revenue
- Total revenue
- Active customers
- Month-over-Month (MoM) revenue change
- MoM growth percentage
- Cumulative total revenue

Use Case:
- Trend analysis
- Revenue growth monitoring
- Executive KPI tracking

Screenshot Reference:
revenue_time_series_view_image_output.png


------------------------------------------------------------
2. Customer Performance View
------------------------------------------------------------
View Name:
vw_pillar1_customer_performance

Purpose:
Provides a customer-level performance dataset enriched with:
- Demographics (age, gender, location, education, marital status)
- Customer segmentation (age bucket, income bucket, tenure bucket)
- Revenue metrics (net transaction, interest, total revenue)
- Profitability classification (Loss-Making / Low Margin / Profitable)

Use Case:
- Customer segmentation analysis
- Identifying loss-making customers
- Targeting high-value customer cohorts

Screenshot Reference:
cx_view_image_output.png


------------------------------------------------------------
3. Product Performance View
------------------------------------------------------------
View Name:
vw_pillar1_product_performance

Purpose:
Provides product-level performance metrics including:
- Transaction volume
- Unique customer count
- Revenue components (fees, revenue, cashback)
- Net transaction revenue
- Unit economics (average revenue and cashback per transaction)
- Product efficiency classification

Efficiency Flags:
- High Volume – Low Margin
- Low Volume – High Margin
- Balanced

Use Case:
- Product profitability analysis
- Margin vs volume trade-off evaluation
- Product optimization decisions

Screenshot Reference:
product_view_image_output.png


------------------------------------------------------------
Notes
------------------------------------------------------------
- Screenshots are used instead of raw tables due to large column widths.
- Views are designed to be directly consumed by BI tools such as Power BI.
- All business logic is implemented in SQL for transparency and scalability.

