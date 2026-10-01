select
    customer_id,
    first_name,
    last_name,
    email,
    customer_tier,
    updated_at

from {{ ref('stg_customers') }}
