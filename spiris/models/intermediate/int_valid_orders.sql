-- count occurances of each order
with orders_with_counts as (

    select
        *,
        count(*) over (partition by order_id) as order_id_count
    from {{ ref('stg_orders') }}

)

select
    o.order_id,
    o.customer_id,
    o.order_timestamp,
    cast(o.order_timestamp as date) as order_date,
    o.order_status

from orders_with_counts o

inner join {{ ref('stg_customers') }} c
    on o.customer_id = c.customer_id

where o.order_id is not null
  and o.customer_id is not null
  and o.order_timestamp is not null
  and c.customer_id is not null
  and o.order_id_count = 1 -- remove duplicate orders

/*

This removes orders with missing order_id and customer_id, but also 
invalid timestamps and nonexistient customers.

*/