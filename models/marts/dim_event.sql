with source as (

    select distinct
        {{ dbt_utils.generate_surrogate_key(['disciplina', 'evento', 'tipo_participante']) }} as id_evento,
        disciplina,
        evento,
        tipo_participante
    from {{ ref('stg_bronze__olympic_results_raw') }}
    where evento is not null

),

final as (

    select
        id_evento,
        disciplina,
        evento,
        tipo_participante
    from source

)

select *
from final