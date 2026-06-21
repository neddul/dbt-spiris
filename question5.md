## 5. Scalability Discussion

The current solution uses DuckDB and dbt, which is suitable for a small assignment dataset. 
If the data grew from thousands of rows to billions of rows, I would keep the same logical model but change the storage and compute architecture.

Raw ingestion data would be stored in a data lake, for example S3, GCS, or Azure Data Lake, using a columnar format such as Parquet. 
The raw layer would preserve the original source data, while cleaned and analytics-ready tables would be stored in a warehouse or lakehouse such as BigQuery, Snowflake, Redshift, Databricks, or Spark with Delta/Iceberg tables.

Large fact-like tables such as orders and order items should be partitioned by `order_date`, since most sales reporting is date-based. 
This allows queries and transformations to scan only relevant date partitions instead of the full table. 
Additional clustering or sorting by keys such as `customer_id`, `product_id`, or `category` could improve common analytical queries.

For the current small dataset, a full refresh is simple and acceptable. 
At larger scale, I would keep the pipeline batch-oriented and run it nightly after the business day is complete, so analysts can see updated results the next morning. 
However, instead of rebuilding all historical data every night, the pipeline would process only new or recently changed raw data.

The nightly job could rebuild only the affected date partitions, for example yesterday or the last 3–7 days, to handle late-arriving orders, cancellations, refunds, or corrections. 
Full historical refreshes would only be needed for backfills, major logic changes, or larger data correction projects.

Compute would move from local DuckDB execution to a distributed warehouse or lakehouse engine. 
dbt could still be used to organize the transformation logic, but the heavy processing would be handled by the target engine. 
Transformations could run in parallel by date partition, and compute resources could be scaled up for batch jobs and scaled down afterwards.

The main cost trade-off is between freshness, performance, and compute/storage cost. 
Full-refreshing billions of rows is simple but expensive. Incremental processing is more complex but reduces cost and runtime. 
Storing raw data cheaply in a data lake and only materializing frequently used analytics tables in the warehouse helps balance cost and performance.
