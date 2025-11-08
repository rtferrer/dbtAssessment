{{
  config(
    materialized='view'
  )
}}

select
    id                     as payment_id,
    orderid                as order_id,
    paymentmethod,
    status                 as payment_status,
    amount                 as payment_amount,
    created::date          as payment_date,

from {{ source('stripe', 'payment') }}