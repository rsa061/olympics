{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='id_country_game'
) }}

with results as (

    select *
    from {{ ref('fct_results') }}

),

games as (

    select *
    from {{ ref('dim_games') }}

),

countries as (

    select *
    from {{ ref('dim_country') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['r.id_pais', 'r.id_juego']) }} as id_country_game,
        r.id_pais,
        r.id_juego,

        g.anio,
        g.estacion,
        g.nombre as nombre_juego,
        g.ciudad,

        c.nombre_ciudad as nombre_pais,
        c.cod_3_letras_ciudad as cod_3_letras_pais,

        count(*) as total_results,
        sum(case when r.tiene_medalla = 1 then 1 else 0 end) as total_medals,
        sum(case when r.tipo_medalla = 'GOLD' then 1 else 0 end) as gold_medals,
        sum(case when r.tipo_medalla = 'SILVER' then 1 else 0 end) as silver_medals,
        sum(case when r.tipo_medalla = 'BRONZE' then 1 else 0 end) as bronze_medals,

        count(distinct r.id_evento) as events_participated,
        count(distinct case when r.tiene_medalla = 1 then r.id_evento end) as events_medaled,
        _fivetran_deleted,
        _fivetran_synced

    from results r
    left join games g
        on r.id_juego = g.cod_juego
    left join countries c
        on r.id_pais = c.cod_ciudad

    group by
        1, 2, 3, 4, 5, 6, 7, 8, 9

)

select *
from final