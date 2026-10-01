# dbt + Spark Data Quality Practice

This is a complete practice project for a dbt + Spark / Databricks-style data engineering assessment.

## What it demonstrates

- staging models
- marts
- built-in dbt data tests
- custom SQL tests
- referential integrity
- business-rule validation
- cross-model consistency
- a data-quality monitoring model

## Project structure

```text
dbt-data-quality-practice/
├── README.md
├── dbt_project.yml
├── seeds/
│   ├── raw_customers.csv
│   └── raw_orders.csv
├── models/
│   ├── schema.yml
│   ├── staging/
│   │   ├── stg_customers.sql
│   │   └── stg_orders.sql
│   └── marts/
│       ├── dim_customers.sql
│       ├── fct_orders.sql
│       └── data_quality_monitor.sql
└── tests/
    ├── order_amount_positive.sql
    ├── valid_order_quantity.sql
    └── customer_order_consistency.sql
```

## Data flow

```text
raw_customers.csv -> stg_customers -> dim_customers
raw_orders.csv    -> stg_orders    -> fct_orders
                                      |
                                      -> data_quality_monitor
```

## Main checks

### Customers
- `customer_id` is unique
- `customer_id` is not null
- `customer_tier` is one of `bronze`, `silver`, `gold`

### Orders
- `order_id` is unique
- `order_id` is not null
- `customer_id` is not null
- every order customer exists in `dim_customers`
- `quantity` is greater than zero
- `order_amount` is greater than zero

## Monitoring model

`data_quality_monitor.sql` outputs:

- `model_name`
- `metric_name`
- `metric_value`
- `metric_type`
- `severity`
- `description`
- `measured_at`

Metrics include:
- total customers
- total orders
- duplicate customer IDs
- duplicate order IDs
- invalid order quantities
- orphan customer IDs
- null customer percentage
- total order revenue

## Typical commands

```bash
dbt seed
dbt run
dbt test
dbt build
dbt run --select data_quality_monitor
```

A custom dbt SQL test returns bad rows:
- 0 rows = PASS
- 1+ rows = FAIL
