{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='id_atleta'
) }}

with source as (
    select
       *
    from {{ ref('stg_athlete') }}
)

select *
from source