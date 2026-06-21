select
    cast(customer_id as varchar) as customer_id,
    cast(country as varchar) as country,
    try_cast(signup_date as date) as signup_date

from {{ ref('raw_customers') }}