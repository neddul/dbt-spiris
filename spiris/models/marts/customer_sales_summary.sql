select
    customer_id,
    country,

    min(order_date) as first_order_date,
    max(order_date) as last_order_date,

    count(distinct order_id) as total_orders,
    sum(order_total_amount) as total_revenue,
    sum(number_of_items) as total_items_bought,

    sum(order_total_amount) / count(distinct order_id) as average_order_value

from {{ ref('orders_enriched') }}

where order_status = 'completed'

group by
    customer_id,
    country