with source as (

    select distinct
        disciplina,
        evento,
        tipo_participante
    from {{ ref('stg_bronze__olympic_results_raw') }}
    where evento is not null

),

final as (

    select
        disciplina,
        evento,
        tipo_participante
    from source

)

select *
from final