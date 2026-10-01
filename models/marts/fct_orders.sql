select
    order_id,
    customer_id,
    order_date,
    quantity,
    unit_price,
    status,
    order_amount,
    updated_at

from {{ ref('stg_orders') }}
