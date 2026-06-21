select
    order_date as date,
    sum(order_total_amount) as total_revenue,
    count(distinct order_id) as total_orders,
    sum(order_total_amount) / count(distinct order_id) as average_order_value

from {{ ref('orders_enriched') }}

where order_status = 'completed'

group by order_date