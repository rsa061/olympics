{{ config(
    materialized='table'
) }}

with results as (
    select *
    from {{ ref('fct_results') }}
),

athletes as (
    select *
    from {{ ref('dim_athlete') }}
),

games as (
    select *
    from {{ ref('dim_games') }}
),

athlete_games as (
    select
        r.id_atleta,
        r.id_juego,
        g.anio,
        r.tiene_medalla,
        r.tipo_medalla
    from results r
    left join games g
        on r.id_juego = g.cod_juego
    where r.id_atleta is not null
),

final as (
    select
        ag.id_atleta,
        a.nombre,
        a.anio_nac,
        a.bio,
        a.primer_juego,
        count(distinct ag.id_juego) as games_participated,
        min(ag.anio) as first_year,
        max(ag.anio) as last_year,
        max(ag.anio) - min(ag.anio) as career_span_years,
        sum(case when ag.tiene_medalla = 1 then 1 else 0 end) as total_medals,
        sum(case when ag.tipo_medalla = 'GOLD' then 1 else 0 end) as gold_medals,
        sum(case when ag.tipo_medalla = 'SILVER' then 1 else 0 end) as silver_medals,
        sum(case when ag.tipo_medalla = 'BRONZE' then 1 else 0 end) as bronze_medals,
        case
            when count(distinct ag.id_juego) = 0 then null
            else sum(case when ag.tiene_medalla = 1 then 1 else 0 end) * 1.0 / count(distinct ag.id_juego)
        end as medals_per_game
    from athlete_games ag
    left join athletes a
        on ag.id_atleta = a.url
    group by
        ag.id_atleta,
        a.nombre,
        a.anio_nac,
        a.bio,
        a.primer_juego
)

select
    {{ dbt_utils.generate_surrogate_key(['id_atleta']) }} as id_athlete_career,
    *
from final