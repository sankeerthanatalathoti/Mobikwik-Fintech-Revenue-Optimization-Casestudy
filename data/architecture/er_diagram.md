ER Diagram & Data Modeling Approach
Overview

This project does not rely on a traditional physical ER diagram with enforced foreign key relationships at the BI layer.
Instead, it follows a view-centric analytical modeling approach, where all joins, aggregations, and business logic are handled upstream in SQL.

This design choice was made deliberately to support analytics performance, clarity, and modularity, which is a common practice in modern fintech and analytics-driven systems.
