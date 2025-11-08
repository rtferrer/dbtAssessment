with payments as (
    select * from {{ ref('stg_payments') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

-- join orders and payments
joined as (
    select
        p.payment_date,
        o.order_id,
        p.payment_amount,
        p.payment_status,
        p.paymentmethod,
        o.order_status
    from payments p
    left join orders o on p.order_id = o.order_id
),

-- aggregate by day
aggregated as (
    select
        payment_date,
        count(distinct order_id)             as total_orders,
        sum(case when payment_status = 'success' then payment_amount else 0 end) as total_revenue,
        avg(case when payment_status = 'success' then payment_amount else null end) as avg_order_value,
        count_if(payment_status = 'success') as successful_payments,
        count_if(payment_status = 'fail')  as failed_payments
    from joined
    group by payment_date
),

final as (
    select
        payment_date,
        total_orders,
        total_revenue,
        avg_order_value,
        successful_payments,
        failed_payments,
        round(100 * successful_payments / nullif(successful_payments + failed_payments, 0), 2) as payment_success_rate
    from aggregated
)

select * from final
order by payment_date
