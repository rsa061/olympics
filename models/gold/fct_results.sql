{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='id_resultado'
) }}

with results as (
    select *
    from {{ ref('stg_results') }}
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

joined as (
    
    select
        r.id_resultado,
        g.cod_juego,
        e.id_evento,
        r.id_atleta, 
        c.cod_3_letras_ciudad as id_pais,
        r.tipo_medalla,
        r.puntuacion_valor,
        r.puntuacion_tipo,
        r.ranking_equal,
        r.posicion_ranking,
        r.atletas,
        r.tiene_medalla,
        row_number() over (
            partition by
                g.cod_juego,
                e.id_evento,
                c.cod_3_letras_ciudad,
                r.id_atleta,  
                coalesce(to_varchar(r.posicion_ranking), ''),
                coalesce(r.tipo_medalla, ''),
                coalesce(r.atletas, '')
            order by g.cod_juego
        ) as rn
    from results r
    left join games g
        on r.cod_juego = g.cod_juego
    left join athletes a
        on r.id_atleta = a.id_atleta
    left join countries c
        on r.id_pais = c.cod_3_letras_ciudad
    left join events e
        on r.id_evento = e.id_evento
),

final as (
    select
        id_resultado,
        cod_juego as id_juego,
        id_evento,
        id_atleta,
        id_pais,
        tipo_medalla,
        puntuacion_valor,
        puntuacion_tipo,
        ranking_equal,
        posicion_ranking,
        atletas,
        tiene_medalla
    from joined
    where rn = 1
)

select * from final

