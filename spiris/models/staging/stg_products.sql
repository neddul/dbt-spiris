select
    cast(product_id as varchar) as product_id,
    cast(category as varchar) as category,
    cast(product_name as varchar) as product_name

from {{ ref('raw_products') }}