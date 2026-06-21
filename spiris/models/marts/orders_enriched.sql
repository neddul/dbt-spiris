select
    o.order_id,
    o.order_timestamp,
    o.order_date,
    o.customer_id,
    c.country,
    o.order_status,
    a.order_total_amount,
    a.number_of_items

from {{ ref('int_valid_orders') }} o

left join {{ ref('stg_customers') }} c
    on o.customer_id = c.customer_id

left join {{ ref('int_orders_aggregated') }} a
    on o.order_id = a.order_id

where a.order_id is not null