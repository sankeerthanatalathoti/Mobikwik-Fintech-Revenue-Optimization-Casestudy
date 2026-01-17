# Power BI –   Imp DAX Measures

This file contains all custom DAX measures created on top of SQL views.
SQL handles the core business logic, while DAX is used only for KPI,
YoY comparison, formatting, and executive-level insights.


### Average Revenue per Customer (ARPU)
```DAX
Avg Revenue per Customer =
DIVIDE (
    SUM ( 'fintech_database vw_customer_performance'[total_revenue] ),
    DISTINCTCOUNT ( 'fintech_database vw_customer_performance'[customer_id] )
)
```
-------------------------------------------------------------
### Mature Customer Count
```DAX
Mature Customer Count =
CALCULATE (
    DISTINCTCOUNT ( 'fintech_database vw_customer_performance'[customer_id] ),
    'fintech_database vw_customer_performance'[tenure_bucket] = "Mature"
)
```
------------------------------------------------------------
### REVENUE GROWTH – YEAR OVER YEAR [Total Revenue YoY Growth %]
```DAX
YoY Revenue Growth with % =
VAR _CY = [total_revenue_by_year]
VAR _PY = [total_revenue_PY]
VAR _YoY = DIVIDE ( _CY - _PY, _PY )

RETURN
FORMAT ( _YoY, "+0.00%;-0.00%;0.00%" )
```
------------------------------------------------------------------
### KPI – INTEREST REVENUE [Interest Revenue YoY %] 
```DAX
Interest Revenue YoY % =
VAR _CY = [Interest Revenue]
VAR _PY = [Interest Revenue PY]
VAR _YoY = DIVIDE ( _CY - _PY, _PY )

VAR _Formatted =
    FORMAT ( _YoY, "+0.00%;-0.00%;0.00%" )

RETURN
IF (
    _YoY > 0,
    UNICHAR(129157) & " " & _Formatted,
    IF (
        _YoY < 0,
        UNICHAR(129158) & " " & _Formatted,
        _Formatted
    )
)
```
-------------------------------------------------------------------
### KPI – NET TRANSACTION REVENUE [Net Transaction Revenue YoY %]
```DAX
Net Txn Revenue YoY % =
VAR _CY = [Net Transaction Revenue]
VAR _PY = [Net Transaction Revenue PY]
VAR _YoY = DIVIDE ( _CY - _PY, _PY )

VAR _Formatted =
    FORMAT ( _YoY, "+0.00%;-0.00%;0.00%" )

RETURN
IF (
    _YoY > 0,
    UNICHAR(129157) & " " & _Formatted,
    IF (
        _YoY < 0,
        UNICHAR(129158) & " " & _Formatted,
        _Formatted
    )
)
```
---------------------------------------------------------------------
### KPI – TOTAL REVENUE TAG [YoY Revenue Growth Tag %]
```DAX
YoY Revenue Growth Tag % =
VAR _CY = [total_revenue_by_year]
VAR _PY = [total_revenue_PY]
VAR _YoY = DIVIDE ( _CY - _PY, _PY )

VAR _Formatted =
    FORMAT ( _YoY, "+0.00%;-0.00%;0.00%" )

RETURN
IF (
    _YoY > 0,
    UNICHAR(129157) & " " & _Formatted,
    IF (
        _YoY < 0,
        UNICHAR(129158) & " " & _Formatted,
        _Formatted
    )
)
```
