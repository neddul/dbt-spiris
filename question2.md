## 2. Data Modeling

I designed the analytics layer using a simple dimensional-modeling approach. 
The source data represents an e-commerce domain with orders, order line items, customers, and products.

The main business event is an order being placed. 
Since an order can contain multiple products, I separate the order-level grain from the order-item grain.

### Model grain

The main analytical grains are:

* `orders_enriched`: one row per valid order
* `daily_sales`: one row per calendar day
* `category_sales`: one row per product category
* `customer_sales_summary`: one row per customer
* `data_quality_issues`: one row per detected data quality issue

Internally, the model is built around two important grains:

* Order grain: one row per order
* Order item grain: one row per product line in an order

This separation is important because order-level metrics and product/category-level metrics answer different questions. 
For example, average order value should be calculated at order level, while category revenue and quantity sold should be calculated from order items.

### Conceptual model

```text
customers
   |
   v
orders
   |
   v
order_items
   ^
   |
products
```

### Design decisions

The raw csv files are first loaded into ingestion models with no transformation other than turning csv info sql to reference. 
Staging models then apply type casting and light standardisation, but do not filter out invalid records. 
This preserves source-data issues so they can be captured in the `data_quality_issues` table.

The intermediate layer creates validated and reusable models. 
Invalid records, such as orders with missing customers, invalid timestamps, duplicate order IDs, missing products, or invalid quantities, are excluded from the intermediate models used for analytics.

The final marts are built from these validated intermediate models:

* `orders_enriched` combines valid orders with customer country and aggregated order totals.
* `daily_sales` aggregates completed orders by calendar day.
* `category_sales` aggregates completed order items by product category.
* `customer_sales_summary` aggregates completed orders by customer.
* `data_quality_issues` exposes invalid or suspicious records for investigation.

Revenue is calculated from order items as:

```text
quantity * price_per_unit
```

Order-level revenue is calculated by summing all line item amounts for each order.

Revenue metrics include only orders with `order_status = 'completed'`. 
Cancelled and refunded orders are excluded because they do not represent realized sales revenue.

This model keeps the final analytics tables simple while still preserving visibility into faulty source records.
