select
    category,
    sum(line_total_amount) as total_revenue,
    sum(quantity) as total_quantity_sold

from {{ ref('int_order_items_enriched') }}

where order_status = 'completed'

group by category