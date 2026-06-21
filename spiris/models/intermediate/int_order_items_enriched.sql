select
    voi.order_id,
    voi.product_id,
    vo.customer_id,
    vo.order_timestamp,
    vo.order_date,
    vo.order_status,

    c.country,

    p.category,
    p.product_name,

    voi.quantity,
    voi.price_per_unit,
    voi.line_total_amount

from {{ ref('int_valid_order_items') }} voi

inner join {{ ref('int_valid_orders') }} vo
    on voi.order_id = vo.order_id

left join {{ ref('stg_customers') }} c
    on vo.customer_id = c.customer_id

left join {{ ref('stg_products') }} p
    on voi.product_id = p.product_id

-- Enriches valid order items with data from other tables