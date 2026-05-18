{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='id_resultado'
) }}

with source as (
    select * from {{ ref('bronze__olympic_results') }}
),

final as (
    select 
        cod_juego,
        {{ dbt_utils.generate_surrogate_key(['disciplina', 'evento', 'tipo_participante']) }} as id_evento,
        {{ dbt_utils.generate_surrogate_key(['url_atleta', 'nombre_atleta']) }} as id_atleta, 
        cod_3_letras_ciudad as id_pais,
        tipo_medalla,
        puntuacion_valor,
        puntuacion_tipo,
        ranking_equal,
        posicion_ranking,
        atletas,
        case 
            when tipo_medalla is not null 
                then 1 
            else 0 end 
        as tiene_medalla
    from source
)

select 
    {{ dbt_utils.generate_surrogate_key([ 'cod_juego', 'id_evento', 'id_pais', 'id_atleta', 'posicion_ranking', 'tipo_medalla', 'atletas'
        ]) }} as id_resultado,
    *
from final