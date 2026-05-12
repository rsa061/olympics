{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

with results as (

    select *
    from {{ ref('stg_bronze__olympic_results_raw') }}

    {% if is_incremental() %}
    where cod_juego not in (
        select distinct cod_juego
        from {{ this }}
    )
    {% endif %}

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
        r.cod_juego as cod_juego,
        g.nombre as nombre_juego,
        g.ciudad as ciudad_juego,
        g.estacion as estacion_juego,
        g.anio as anio_juego,
        g.fecha_start as fecha_start_juego,
        g.fecha_end as fecha_end_juego,

        e.disciplina as disciplina,
        e.evento as evento,
        e.tipo_participante,

        r.tipo_medalla,
        r.atletas,

        r.ranking_equal,
        r.posicion_ranking ,

        r.nombre_ciudad,
        c.cod_ciudad,
        c.cod_3_letras_ciudad,

        r.url_atleta,
        a.nombre as nombre_atleta,
        a.juegos_participa as juegos_participa_atleta,
        a.primer_juego as primer_juego_atleta,
        a.anio_nac as anio_nac_atleta,
        a.medallas as medallas_atleta,
        a.bio as bio_atleta,

        r.puntuacion_valor,
        r.puntuacion_tipo,

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