select
    oi.order_id,
    oi.product_id,
    oi.quantity,
    oi.price_per_unit,
    oi.quantity * oi.price_per_unit as line_total_amount

from {{ ref('stg_order_items') }} oi

left join {{ ref('int_valid_orders') }} vo
    on oi.order_id = vo.order_id

left join {{ ref('stg_products') }} p
    on oi.product_id = p.product_id

where oi.order_id is not null
  and oi.product_id is not null
  and oi.quantity is not null
  and oi.quantity > 0
  and oi.price_per_unit is not null
  and oi.price_per_unit > 0
  and vo.order_id is not null
  and p.product_id is not null

/*

Removes items with missing order_id and product_id, invalid quanitity and price,
and references to nonexistent orders and products.

*/