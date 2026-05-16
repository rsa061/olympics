{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='id_country_game'
) }}

with results as (
    select *
    from {{ ref('fct_results') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['r.id_pais', 'r.id_juego']) }} as id_country_game,
        r.id_pais,
        r.id_juego,
        count(*) as total_results,
        sum(case when r.tiene_medalla = 1 then 1 else 0 end) as total_medals,
        sum(case when r.tipo_medalla = 'GOLD' then 1 else 0 end) as gold_medals,
        sum(case when r.tipo_medalla = 'SILVER' then 1 else 0 end) as silver_medals,
        sum(case when r.tipo_medalla = 'BRONZE' then 1 else 0 end) as bronze_medals,
        count(distinct r.id_evento) as events_participated,
        count(distinct case when r.tiene_medalla = 1 then r.id_evento end) as events_medaled
    from results r
    group by 1, 2, 3
)

select *
from final