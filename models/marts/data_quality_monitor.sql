with customer_total as (

    select
        'dim_customers' as model_name,
        'total_customers' as metric_name,
        cast(count(*) as double) as metric_value,
        'count' as metric_type,
        'info' as severity,
        'Total number of customer records' as description,
        current_timestamp() as measured_at

    from {{ ref('dim_customers') }}

),

order_total as (

    select
        'fct_orders' as model_name,
        'total_orders' as metric_name,
        cast(count(*) as double) as metric_value,
        'count' as metric_type,
        'info' as severity,
        'Total number of order records' as description,
        current_timestamp() as measured_at

    from {{ ref('fct_orders') }}

),

duplicate_customer_ids as (

    select customer_id
    from {{ ref('dim_customers') }}
    group by customer_id
    having count(*) > 1

),

duplicate_customer_metric as (

    select
        'dim_customers' as model_name,
        'duplicate_customer_ids' as metric_name,
        cast(count(*) as double) as metric_value,
        'count' as metric_type,
        'error' as severity,
        'Number of duplicated customer IDs' as description,
        current_timestamp() as measured_at

    from duplicate_customer_ids

),

duplicate_order_ids as (

    select order_id
    from {{ ref('fct_orders') }}
    group by order_id
    having count(*) > 1

),

duplicate_order_metric as (

    select
        'fct_orders' as model_name,
        'duplicate_order_ids' as metric_name,
        cast(count(*) as double) as metric_value,
        'count' as metric_type,
        'error' as severity,
        'Number of duplicated order IDs' as description,
        current_timestamp() as measured_at

    from duplicate_order_ids

),

invalid_quantity_metric as (

    select
        'fct_orders' as model_name,
        'invalid_order_quantities' as metric_name,
        cast(count(*) as double) as metric_value,
        'count' as metric_type,
        'error' as severity,
        'Orders where quantity is zero or negative' as description,
        current_timestamp() as measured_at

    from {{ ref('fct_orders') }}
    where quantity <= 0

),

orphan_customer_metric as (

    select
        'fct_orders' as model_name,
        'orphan_customer_ids' as metric_name,
        cast(count(*) as double) as metric_value,
        'count' as metric_type,
        'error' as severity,
        'Orders whose customer_id does not exist in dim_customers' as description,
        current_timestamp() as measured_at

    from {{ ref('fct_orders') }} o
    left join {{ ref('dim_customers') }} c
        on o.customer_id = c.customer_id

    where c.customer_id is null

),

null_customer_percentage as (

    select
        'fct_orders' as model_name,
        'null_customer_percentage' as metric_name,
        cast(
            case
                when count(*) = 0 then 0
                else 100.0 * sum(case when customer_id is null then 1 else 0 end) / count(*)
            end
            as double
        ) as metric_value,
        'percentage' as metric_type,
        'warning' as severity,
        'Percentage of orders with a null customer_id' as description,
        current_timestamp() as measured_at

    from {{ ref('fct_orders') }}

),

revenue_metric as (

    select
        'fct_orders' as model_name,
        'total_order_revenue' as metric_name,
        cast(coalesce(sum(order_amount), 0) as double) as metric_value,
        'currency' as metric_type,
        'info' as severity,
        'Total order revenue across valid orders' as description,
        current_timestamp() as measured_at

    from {{ ref('fct_orders') }}

)

select * from customer_total
union all
select * from order_total
union all
select * from duplicate_customer_metric
union all
select * from duplicate_order_metric
union all
select * from invalid_quantity_metric
union all
select * from orphan_customer_metric
union all
select * from null_customer_percentage
union all
select * from revenue_metric
