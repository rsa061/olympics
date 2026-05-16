{{ config(
    materialized='incremental',
    unique_key='cod_juego',
    incremental_strategy='merge'
) }}

with source as (

    select *
    from {{ source('bronze', 'olympic_hosts_raw') }}

    {% if is_incremental() %}
    where game_slug not in (
        select cod_juego
        from {{ this }}
    )
    {% endif %}

),

renamed as (

    select
        trim(game_slug) as cod_juego,
        try_to_timestamp_tz(game_end_date) as fecha_end,
        try_to_timestamp_tz(game_start_date) as fecha_start,
        trim(game_location) as ciudad,
        trim(game_name) as nombre,
        trim(game_season) as estacion,
        try_to_number(game_year) as anio
    from source

)

select * from renamed