with duplicate_orders as (

    select
        'orders' as source_table,
        order_id as record_id,
        'duplicate_primary_key' as issue_type,
        'high' as issue_severity,
        'Order ID appears more than once in orders.csv' as issue_description,
        'data_engineering' as suggested_owner
    from {{ ref('stg_orders') }}
    where order_id is not null
    group by order_id
    having count(*) > 1

),

missing_order_id as (

    select
        'orders' as source_table,
        order_id as record_id,
        'missing_order_id' as issue_type,
        'high' as issue_severity,
        'Order is missing order_id' as issue_description,
        'application_team' as suggested_owner
    from {{ ref('stg_orders') }}
    where order_id is null

),

invalid_timestamps as (

    select
        'orders' as source_table,
        order_id as record_id,
        'invalid_or_missing_timestamp' as issue_type,
        'high' as issue_severity,
        'Order timestamp is missing or could not be parsed' as issue_description,
        'application_team' as suggested_owner
    from {{ ref('stg_orders') }}
    where order_timestamp is null

),

missing_customer_id as (

    select
        'orders' as source_table,
        order_id as record_id,
        'missing_customer_id' as issue_type,
        'high' as issue_severity,
        'Order is missing customer_id' as issue_description,
        'application_team' as suggested_owner
    from {{ ref('stg_orders') }}
    where customer_id is null

),

missing_customer_references as (

    select
        'orders' as source_table,
        o.order_id as record_id,
        'missing_customer_reference' as issue_type,
        'high' as issue_severity,
        'Order references a customer_id that does not exist in customers.csv' as issue_description,
        'application_team' as suggested_owner
    from {{ ref('stg_orders') }} o
    left join {{ ref('stg_customers') }} c
        on o.customer_id = c.customer_id
    where o.customer_id is not null
      and c.customer_id is null

),

invalid_quantities as (

    select
        'order_items' as source_table,
        coalesce(order_id, 'missing_order_id') || '-' || coalesce(product_id, 'missing_product_id') as record_id,
        'invalid_quantity' as issue_type,
        'high' as issue_severity,
        'Order item has missing, zero, or negative quantity' as issue_description,
        'application_team' as suggested_owner
    from {{ ref('stg_order_items') }}
    where quantity is null
       or quantity <= 0

),

invalid_prices as (

    select
        'order_items' as source_table,
        coalesce(order_id, 'missing_order_id') || '-' || coalesce(product_id, 'missing_product_id') as record_id,
        'invalid_price' as issue_type,
        'high' as issue_severity,
        'Order item has missing or negative price_per_unit' as issue_description,
        'application_team' as suggested_owner
    from {{ ref('stg_order_items') }}
    where price_per_unit is null
       or price_per_unit < 0

),

missing_order_references as (

    select
        'order_items' as source_table,
        coalesce(oi.order_id, 'missing_order_id') || '-' || coalesce(oi.product_id, 'missing_product_id') as record_id,
        'missing_order_reference' as issue_type,
        'high' as issue_severity,
        'Order item references an order_id that does not exist in orders.csv' as issue_description,
        'application_team' as suggested_owner
    from {{ ref('stg_order_items') }} oi
    left join {{ ref('stg_orders') }} o
        on oi.order_id = o.order_id
    where oi.order_id is not null
      and o.order_id is null

),

missing_product_references as (

    select
        'order_items' as source_table,
        coalesce(oi.order_id, 'missing_order_id') || '-' || coalesce(oi.product_id, 'missing_product_id') as record_id,
        'missing_product_reference' as issue_type,
        'high' as issue_severity,
        'Order item references a product_id that does not exist in products.csv' as issue_description,
        'application_team' as suggested_owner
    from {{ ref('stg_order_items') }} oi
    left join {{ ref('stg_products') }} p
        on oi.product_id = p.product_id
    where oi.product_id is not null
      and p.product_id is null

)

select * from duplicate_orders
union all
select * from missing_order_id
union all
select * from invalid_timestamps
union all
select * from missing_customer_id
union all
select * from missing_customer_references
union all
select * from invalid_quantities
union all
select * from invalid_prices
union all
select * from missing_order_references
union all
select * from missing_product_references