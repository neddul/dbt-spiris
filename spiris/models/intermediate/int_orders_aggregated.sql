select
    order_id,
    sum(line_total_amount) as order_total_amount,
    count(*) as number_of_items

from {{ ref('int_order_items_enriched') }}

group by order_id


/*

For each order_id:
- sum line_total_amount to calculate the total value of the order
- count rows to calculate the number of line items in the order

*/

