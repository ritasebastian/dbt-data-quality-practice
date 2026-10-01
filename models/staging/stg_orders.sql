with source as (

    select *
    from {{ ref('raw_orders') }}

),

transformed as (

    select
        order_id,
        customer_id,
        cast(order_date as date) as order_date,
        cast(quantity as integer) as quantity,
        cast(unit_price as decimal(18,2)) as unit_price,
        lower(trim(order_status)) as status,
        cast(quantity as decimal(18,2)) * cast(unit_price as decimal(18,2)) as order_amount,
        cast(updated_at as timestamp) as updated_at

    from source

),

ranked as (

    select
        *,
        row_number() over (
            partition by order_id
            order by updated_at desc
        ) as row_num

    from transformed
    where status != 'cancelled'

)

select
    order_id,
    customer_id,
    order_date,
    quantity,
    unit_price,
    status,
    order_amount,
    updated_at

from ranked
where row_num = 1
