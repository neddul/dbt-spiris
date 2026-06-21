# E-commerce Data Engineering Assignment

## Overview

This project is a dbt-based data pipeline for preparing e-commerce transaction data for analytics.

The pipeline ingests raw CSV files, applies typing and validation logic, creates analytics-ready marts, and exposes data quality issues in a separate issue table.

The solution uses:

* dbt
* DuckDB
* SQL
* CSV source files

The assignment focuses on ingestion, transformation, data modeling, data quality, and scalability considerations.

---

## How to Run the Pipeline

### 1. Install dependencies

Create and activate a Python environment, then install dbt with the DuckDB adapter.

```bash
pip install dbt-duckdb
```

### 2. Place the source files

The source CSV files should be available in the `data/` folder:

```text
data/
  orders.csv
  order_items.csv
  customers.csv
  products.csv
```

### 3. Check dbt connection

```bash
dbt debug
```

### 4. Run the dbt models

```bash
dbt run
```

This builds the ingestion, staging, intermediate, and mart models.

### 5. Run tests

```bash
dbt test
```

Some staging tests may fail because the provided dataset intentionally contains data quality issues. These issues are captured in the `data_quality_issues` mart.

The final analytics marts are built from validated intermediate models.



## Assumptions

* The source CSV files are available in the `data/` folder
* DuckDB is used as the analytical database for this assignment
* `order_id` is expected to be unique in orders
* `customer_id` should exist in customers for an order to be valid
* `product_id` should exist in products for an order item to be valid
* Revenue calculations include only completed orders
* Cancelled and refunded orders are excluded from revenue figures
* Orders with duplicate primary keys are treated as invalid rather than deduplicated, because there is no reliable update timestamp to determine which row should be kept
* Missing country is treated as a warning rather than a reason to exclude an otherwise valid order

---

## Possible Improvements

* Add orchestration using Airflow, Dagster, or Prefect
* Add Docker or docker-compose for easier local setup
* Add CI/CD to run `dbt run` and `dbt test` automatically on pull requests
* Add more custom dbt tests for business rules, such as non-negative revenue and valid order statuses
* Add source freshness checks if the data arrives on a schedule
* Add snapshots for slowly changing customer or product attributes
* Add incremental dbt models for large-scale processing
* Add documentation generation using `dbt docs generate`
* Add lineage diagrams and more detailed model descriptions
* Add monitoring/alerting for the `data_quality_issues` table
* Add more data from usage of application to see stuff how the users use the app, clicks on webpage with timestamps and sessions