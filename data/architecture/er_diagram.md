# ER Diagram & Data Modeling Approach

## Overview

This project does not rely on a traditional physical ER diagram with enforced foreign key relationships at the BI layer.

Instead, it follows a **view-centric analytical modeling approach**, where all joins, aggregations, and business logic are handled upstream in SQL using analytical views.

This approach reflects real-world fintech analytics systems where BI tools consume curated datasets rather than raw transactional tables.

---
<img width="1278" height="511" alt="ER_Diagram_Mobikwik" src="https://github.com/user-attachments/assets/20d43b08-4013-4900-987b-47563c567f1b" />


## Why a Traditional ER Diagram Is Not Enforced

- All entity relationships (customers, transactions, credit accounts) are resolved in SQL
- Analytical views already contain the required joins and aggregations
- Power BI and Python consume **flattened, analytics-ready views**
- No additional relationship modeling is required in the BI layer

This improves performance, clarity, and maintainability.

---

## Logical Data Model (View-Based)

The project is structured around the following analytical views:

### 1. Customer Performance View
- Customer demographics and attributes
- Age, income, and tenure segmentation
- Net transaction revenue and interest revenue
- Profitability classification (Loss-Making, Low Margin, Profitable)

### 2. Product Performance View
- Transaction volume by product type
- Revenue components and unit economics
- Product efficiency classification
- Used for product mix and margin optimization

### 3. Revenue Time Series View
- Monthly revenue aggregation
- Active customers and growth metrics
- MoM trends, cumulative revenue, and forecasting inputs

Each view is independent and analytics-ready.

---

## Relationship Handling Strategy

All relationships are handled **within SQL views**, not inside Power BI.

This eliminates the need for:
- Physical foreign key constraints in BI
- Complex relationship modeling
- Additional joins at report level

---

## Note for Reviewers

> This project intentionally uses a SQL-first, view-driven data modeling approach.  
> The absence of enforced ER relationships at the BI layer is a design decision aligned with modern analytics best practices.

