with source as (

    select *
    from {{ ref('raw_customers') }}

),

cleaned as (

    select
        trim(customer_id) as customer_id,
        trim(first_name) as first_name,
        trim(last_name) as last_name,
        lower(trim(email)) as email,
        lower(trim(customer_tier)) as customer_tier,
        cast(updated_at as timestamp) as updated_at

    from source

)

select *
from cleaned
where customer_id is not null
