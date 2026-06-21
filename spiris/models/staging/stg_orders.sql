select
    cast(order_id as varchar) as order_id,
    cast(customer_id as varchar) as customer_id,
    try_cast(order_timestamp as timestamp) as order_timestamp,
    cast(order_status as varchar) as order_status

from {{ ref('raw_orders') }}