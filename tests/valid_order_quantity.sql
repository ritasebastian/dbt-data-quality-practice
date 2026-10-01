select
    order_id,
    quantity

from {{ ref('fct_orders') }}

where quantity <= 0
