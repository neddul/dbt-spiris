## 4. Data Quality

Data quality is handled in two ways:

1. dbt tests are used as automated checks for key assumptions.
2. A `data_quality_issues` mart captures faulty or suspicious records in a readable table for investigation.

The staging layer does not filter out invalid records, it only applies typing and light standardisation. 
This makes sure bad source records are still visible. 
The intermediate layer then filters out records that are unsafe for analytics, and the final marts are built only from validated data.

### Implemented checks

| Check | What it detects | Action on failure | Production monitoring |
|---|---|---|---|
| Duplicate `order_id` | Detects orders where the primary key appears more than once. | Exclude duplicated orders from analytics and write them to `data_quality_issues`. | Alert if duplicate count is greater than zero. |
| Invalid or missing `order_timestamp` | Detects timestamps that could not be parsed with `try_cast` or are missing. | Exclude from analytics because the order cannot be assigned to a reliable date. | Track daily count of invalid timestamps and alert on increase. |
| Missing customer reference | Detects orders where `customer_id` does not exist in `customers`. | Exclude from valid order models and expose in `data_quality_issues`. | Alert application/data team if broken references appear. |
| Invalid quantity | Detects order items where quantity is null, zero, or negative. | Exclude from revenue calculations and expose in `data_quality_issues`. | Monitor invalid quantity count and percentage of total order items. |
| Missing product reference | Detects order items where `product_id` does not exist in `products`. | Exclude from category sales because category cannot be assigned. | Alert if missing product references occur. |
| Missing country | Detects customers with missing country. | Treat as warning. Keep order revenue, but expose the issue and optionally use `unknown` in marts. | Monitor missing country rate over time. |

### Data quality issue table

The `data_quality_issues` table stores detected issues with:

- `source_table`
- `record_id`
- `issue_type`
- `issue_severity`
- `issue_description`
- `suggested_owner`

This makes data quality issues visible not only to data engineers, but also to application teams or customer support. 
For example, negative quantities could indicate an application bug or abusive behaviour, while missing customer references could indicate an upstream data integrity issue.

Some dbt tests are expected to fail on the staging layer because the provided source data intentionally contains bad records. 
Final analytics marts are built from validated intermediate models and are expected to pass their core tests.