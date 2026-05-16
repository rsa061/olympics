{{ config(
    materialized='table'
) }}

with base as (
    select
        fr.id_juego,
        fr.id_pais,
        count(*) as total_results,
        sum(case when fr.tiene_medalla = 1 then 1 else 0 end) as total_medals,
        sum(case when fr.tipo_medalla = 'GOLD' then 1 else 0 end) as gold_medals,
        sum(case when fr.tipo_medalla = 'SILVER' then 1 else 0 end) as silver_medals,
        sum(case when fr.tipo_medalla = 'BRONZE' then 1 else 0 end) as bronze_medals,
        count(distinct fr.id_evento) as events_participated,
        count(distinct case when fr.tiene_medalla = 1 then fr.id_evento end) as events_medaled
    from {{ ref('fct_results') }} fr
    group by 1, 2
),

games as (
    select
        cod_juego,
        ciudad as ciudad_sede
    from {{ ref('dim_games') }}
),

countries as (
    select
        cod_3_letras_ciudad,
        nombre_ciudad
    from {{ ref('dim_country') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['b.id_pais', 'b.id_juego']) }} as id_host_country_game,
        b.id_juego,
        b.id_pais,
        b.total_results,
        b.total_medals,
        b.gold_medals,
        b.silver_medals,
        b.bronze_medals,
        b.events_participated,
        b.events_medaled,
        case
            when upper(trim(g.ciudad_sede)) = upper(trim(c.nombre_ciudad)) then 1
            else 0
        end as is_host
    from base b
    left join games g
        on b.id_juego = g.cod_juego
    left join countries c
        on b.id_pais = c.cod_3_letras_ciudad
)

select *
from final