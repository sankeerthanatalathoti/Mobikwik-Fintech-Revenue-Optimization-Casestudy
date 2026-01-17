# MobiKwik Fintech Revenue Optimization Case Study

---

## 📌 Company Context: MobiKwik (Indian FinTech)

MobiKwik (One MobiKwik Systems Ltd.) is a leading Indian fintech company founded in 2009, serving **180+ million registered users** and **4.7+ million merchants** across India. The platform operates across **UPI, digital wallets, bill payments, and credit products** such as **BNPL and EMI**, processing high transaction volumes at national scale.

Despite strong growth in transaction activity, recent industry trends show that **revenue growth has remained flat or modest**, reflecting the broader challenge of monetizing beyond basic payment transactions in a highly competitive and regulated fintech ecosystem.

### Key Facts and Industry Context
- 180M+ users and 4.7M+ merchants on the platform  
- Among India’s top digital wallet and fast-growing UPI players  
- Payment volumes continue to grow, but revenue growth has lagged behind volume growth  
- Indian fintechs face regulatory tightening on unsecured credit  
- Industry shift toward profitability over rapid expansion  

---

## 🎯 Business Problem Statement — Revenue Sustainability & Monetization Effectiveness

During **2024–2025**, the Indian fintech sector—including platforms like MobiKwik—has experienced a disconnect between **rising transaction volumes** and **stagnant or modest revenue growth**. While digital payment usage continues to scale rapidly, the ability to convert transaction activity into sustainable revenue has weakened due to:

- Regulatory tightening on unsecured credit  
- Margin pressure on payment products  
- Strategic shift toward profitability over growth-at-all-costs  

As a result, fintech firms face challenges in identifying:
- Which **products** actually drive value  
- Which **customer segments** contribute meaningful revenue  
- Which **revenue streams** are underperforming  
- Where **revenue leakage** exists  

The core challenge is **not usage growth**, but **converting usage into sustainable, realized revenue**.

### Industry Context & Public Reference

This business problem aligns with real-world challenges faced by Indian fintech platforms.  
Recent public reporting highlights that despite strong transaction activity, revenue growth has remained flat while losses have widened—reinforcing the need for improved monetization and revenue sustainability strategies.

**Referenced Industry Article:**  
- [MobiKwik’s net loss widens to ₹55 crore as revenue growth remains flat — Economic Times](https://economictimes.indiatimes.com/tech/technology/mobikwiks-net-loss-widens-to-rs-55-crore-as-revenue-growth-remains-flat/articleshow/121282482.cms)

### Project Scope
This project simulates such a business environment to analyze **revenue sustainability** and **monetization effectiveness** across multiple dimensions.

The analysis focuses on:
- Net transactional revenue  
- Projected interest revenue  
- Product-level performance (UPI, Wallet, BNPL, EMI, Card)  
- Customer performance metrics such as tenure, customer type, and income segment  

By identifying **high- and low-performing products**, **customer segments**, **revenue gaps**, and **leakage points**, the project evaluates **revenue uplift opportunities** through scenario simulation and forecasting, enabling data-driven recommendations to optimize:
- Product mix  
- Customer strategy  
- Long-term profitability  

---

## ⚠️ Disclaimer

This project uses a **synthetic (dummy) dataset** created solely for **analytical and educational purposes**. All data values, metrics, and customer records are simulated and **do not represent actual MobiKwik financials, users, or internal performance**.

Any insights derived are intended to demonstrate **analytical thinking and problem-solving approaches**, and **do not reflect the company’s real business data**.

## 📂 Data & Assumptions

### Data Sources

The analysis is based on a synthetic dataset representing a fintech platform’s core operational data. The raw data consists of three primary tables:

- **Customers** — Columns:
customer_id [text ],
signup_date [datetime ],
acquisition_channel [text] ,
campaign_id [text ],
gender [ text ],
date_of_birth [datetime] ,
city [ text ],
state [text] ,
employment_type [text] ,
annual_income [int ],
education_level [text] ,
marital_status [ text ],
customer_type [ text]
- **Transactions** —Columns:
transaction_id [text] ,
customer_id [text] ,
transaction_date [datetime] ,
product_type [text] ,
merchant_category [text ],
channel [text ],
transaction_amount [double] ,
fee_amount [double ],
revenue_amount [double] ,
cashback_given [double ],
is_first_transaction [int ],
transaction_status [text]
- **Credit Accounts** — Columns:
credit_account_id [text], 
customer_id [text ],
credit_product [text] ,
open_date [datetime ],
tenure_months [int ],
credit_limit [int ],
utilized_amount [int ],
total_amount_paid [int ],
interest_rate [double] ,
repayment_status [text ],
delinquency_flag [int ],
last_payment_date [datetime]

These raw tables were used for exploratory data analysis (EDA) in SQL.

### Analytical Views (SQL)

The raw transactional tables were transformed into analytical SQL views and then consumed directly in Power BI. This ensured business-ready metrics, consistent calculations, and optimized dashboard performance.

<img width="805" height="538" alt="ER_Diagram_Views" src="https://github.com/user-attachments/assets/02459a38-da62-41c9-bc4c-74fe81d6509b" />

## 📊 Executive Summary

This analysis evaluates revenue sustainability and monetization effectiveness for a fintech
platform operating at scale. Despite strong transaction activity and a large active customer base,
the findings reveal significant structural inefficiencies in revenue realization.

The data highlights high volatility in net transactional revenue, indicating weak revenue
predictability despite growing usage. A substantial portion of total revenue potential remains
unrealized, with projected interest revenue forming the majority of the gap between potential
and realized earnings.

Customer-level analysis shows that monetization remains low even across long-tenure and active
users, resulting in limited revenue per customer at scale. Product-level insights further
demonstrate an inefficient product mix, where high-volume products drive transaction count
but contribute disproportionately low revenue, while structured credit products generate
higher revenue per transaction.

Overall, the analysis confirms that the core business challenge is not transaction growth,
but monetization efficiency. These findings establish a clear foundation for identifying
revenue leakages, structural gaps, and realistic revenue uplift opportunities through
targeted optimization rather than scale expansion.

### Revenue Realization vs Revenue Potential

(Revenue KPIs – Total Revenue Potential, Net Transaction Revenue, Projected Interest Revenue) 

<img width="1168" height="209" alt="KPIs" src="https://github.com/user-attachments/assets/4dfbd1a4-0aca-4a2e-afba-73958f00c52b" />

(Monthly Net Transaction Revenue Trend & Monthly Interest Revenue Trend)

<img width="1019" height="410" alt="Net_Transaction_Revenue" src="https://github.com/user-attachments/assets/37281e48-e26e-4dfa-a317-824cd5cef30e" />

<img width="1016" height="372" alt="Interest_revenue" src="https://github.com/user-attachments/assets/38b468aa-da7c-4047-b9c1-02a9f9f59c7b" />


The analysis reveals a significant gap between total revenue potential and actual realized
revenue. While the total revenue potential is estimated at approximately **₹24.7M**, only
**₹4.60M** is currently realized as net transaction revenue.

A substantial portion of the remaining revenue potential—approximately **80–82%**—is
concentrated in **projected interest revenue**, which has not yet been converted into realized
cash. This highlights a structural monetization and realization gap rather than a lack of
revenue-generating opportunities.

Trend analysis further reinforces this observation. Net transaction revenue exhibits volatility
over time, while interest revenue remains relatively stable but largely unrealized. Together,
these patterns indicate that revenue challenges stem from **realization efficiency and
conversion mechanisms**, not from transaction activity or revenue scale alone.


### Revenue Volatility & Growth Inconsistency

<table>
  <tr>
    <td><img width="287" height="155" alt="yoy_growth_perc" src="https://github.com/user-attachments/assets/0e154d46-ef54-44f5-979d-dcdc45dc9259" /></td>
    <td><img width="389" height="508" alt="MoM_Growth_perc" src="https://github.com/user-attachments/assets/e463317d-1af1-4430-ac88-77ac36e79c5d" /></td>
  </tr>
</table>


The analysis indicates that net transaction revenue growth is inconsistent across time
periods, reflecting instability rather than sustained momentum. While revenue declined by
**–5.52% in 2024**, it recovered by **+9.24% in 2025**, highlighting a reactive growth pattern
instead of steady, compounding growth.

Month-on-month revenue growth further reinforces this volatility, with frequent positive and
negative fluctuations. These swings suggest that revenue performance is sensitive to short-term
factors and lacks structural stability.

Overall, the observed volatility indicates weak revenue predictability and limited monetization
control. Despite ongoing transaction activity, revenue growth remains uneven—reinforcing that
usage growth alone is insufficient to ensure sustainable revenue performance.

## Customer Monetization Efficiency

This section evaluates how effectively the platform monetizes its active customer base.
The objective is to understand whether customer scale and engagement translate into
proportional revenue contribution.

---

### Customer Monetization Overview

(Customer KPIs – Active Customers & ARPU screenshot)

<img width="726" height="149" alt="APRU" src="https://github.com/user-attachments/assets/541b45d7-ae4d-4b25-85c1-1ed8d654a711" />


The platform serves a large active customer base of approximately **15,000 users**.
However, the **net transaction ARPU** remains limited at around **₹306–307**, indicating
that average revenue generated per user is low when distributed across the entire
customer base.

This suggests that while customer adoption and activity are strong, monetization at
scale remains inefficient.

---

### ARPU vs Customer Scale Mismatch

(ARPU KPI & ARPC / Customer Revenue Distribution screenshot)

<img width="630" height="112" alt="ARPC Vs ARPU" src="https://github.com/user-attachments/assets/1d923292-0419-4cba-8ff0-2a5f0370ebf7" />


A closer examination of customer-level monetization reveals a clear mismatch between
customer scale and revenue contribution. While **ARPU remains low at ₹306–307**, the
**average revenue per contributing customer (ARPC)** is significantly higher at
approximately **₹1,647**.

This disparity indicates that **only a subset of customers is responsible for generating
meaningful revenue**, while a large portion of active users contributes minimal revenue
despite being transactionally active.

In effect, customer scale exists, but revenue does not scale proportionally with it.
Incremental users are adding transaction volume, but not equivalent revenue value,
highlighting under-monetization across the broader customer base.

---

### Customer Tenure & Monetization Quality

(Customer Tenure – Revenue & Profitability Status – Revenue visuals side by side)

<img width="727" height="345" alt="cx_Tenure Vs Profitability status" src="https://github.com/user-attachments/assets/44ba2f71-0a0b-4124-8ee8-daaa01e9936e" />


Customer-level analysis indicates that **mature customers contribute the highest share of
revenue (₹3.09M)**. However, this contribution is primarily driven by customer longevity
rather than a meaningful increase in monetization efficiency.

At the same time, revenue quality analysis shows that value creation is concentrated
within **profitable customers**, while loss-making and low-margin segments contribute
limited sustainable revenue. This suggests that only a subset of retained customers
generates consistent value.

Together, these patterns highlight that extended customer tenure does not automatically
translate into higher-quality revenue. Monetization plateaus over time, indicating missed
opportunities for tenure-based monetization, differentiated pricing, or targeted
cross-sell strategies.

---

### Key Customer-Level Insights

- Large active customer base, but low average revenue per user (ARPU)  
- Revenue contribution is concentrated among a smaller subset of customers (higher ARPC)  
- Customer scale does not translate into proportional revenue growth  
- Retention without monetization uplift limits customer lifetime value  

These insights confirm that customer count is not the primary constraint. Instead,
the challenge lies in improving **monetization efficiency across the existing customer
base**, which naturally leads to examining **product usage and revenue contribution
patterns** in the next section.
