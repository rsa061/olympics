{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='id_resultado'
) }}

with results as (
    select *
    from {{ ref('stg_bronze__olympic_results_raw') }}
),

athletes as (
    select *
    from {{ ref('dim_athlete') }}
),

games as (
    select *
    from {{ ref('dim_games') }}
),

countries as (
    select *
    from {{ ref('dim_country') }}
),

events as (
    select *
    from {{ ref('dim_event') }}
),

final as (
    select
        r.id_resultado,
        g.cod_juego as id_juego,
        e.id_evento as id_evento,
        a.url as id_atleta,
        c.cod_ciudad as id_pais,
        r.tipo_medalla,
        r.puntuacion_valor,
        r.puntuacion_tipo,
        r.ranking_equal,
        r.posicion_ranking,
        r.atletas,
        case
            when r.tipo_medalla is not null then 1
            else 0
        end as tiene_medalla
    from results r
    left join games g
        on r.cod_juego = g.cod_juego
    left join athletes a
        on r.url_atleta = a.url
    left join countries c
        on r.cod_ciudad = c.cod_ciudad
    left join events e
        on r.disciplina = e.disciplina
       and r.evento = e.evento
       and r.tipo_participante = e.tipo_participante
)

select *
from final