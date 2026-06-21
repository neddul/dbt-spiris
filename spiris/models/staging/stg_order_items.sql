select
    cast(order_id as varchar) as order_id,
    cast(product_id as varchar) as product_id,
    try_cast(quantity as int) as quantity,
    try_cast(price_per_unit as decimal) as price_per_unit

from {{ ref('raw_order_items') }}