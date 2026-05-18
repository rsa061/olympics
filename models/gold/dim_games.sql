{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='cod_juego'
) }}

with source as (
    select *  
    from {{ ref('stg_games') }}
)

select *
from source