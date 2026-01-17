## End-to-End Analytics Architecture

This project follows a layered analytics architecture commonly used in
fintech and data-driven organizations.

---

### High-Level Architecture Flow

![Analytics Architecture Flow]
<img width="703" height="957" alt="Mobikwik_Analytics _Architecture_Flow drawio" src="https://github.com/user-attachments/assets/80504df2-6176-41ea-8a42-101a967375ee" />


### Layer-wise Explanation

#### 1. Cloud Storage Layer
- Acts as the source-of-truth storage
- Holds raw transactional and customer data
- Conceptually implemented using AWS S3

#### 2. SQL Modeling Layer
- Core analytical layer of the project
- Uses views for:
  - Revenue time series
  - Product performance
  - Customer performance
- Enables reusable, BI-ready datasets

#### 3. Python Analytics Layer
- Used for advanced analysis not feasible directly in BI
- Scenario forecasting
- Multi-variable revenue simulations
- What-if analysis

#### 4. Power BI Visualization Layer
- Business-facing analytics
- KPI tracking
- YoY growth, ARPU, uplift metrics
- Scenario comparison dashboards

---

### Why This Architecture Works
- Clear separation of concerns
- Scalable and cloud-ready
- Mirrors real-world fintech analytics pipelines
- Suitable for enterprise decision-making

             
