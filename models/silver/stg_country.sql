with source as (

    select distinct
        cod_3_letras_ciudad,
        cod_ciudad,
        nombre_ciudad
    from {{ ref('bronze__olympic_results') }}
    where cod_3_letras_ciudad is not null

),

dedup as (

    select
        *,
        row_number() over (
            partition by cod_3_letras_ciudad
            order by cod_ciudad
        ) as rn
    from source

)

select
    cod_3_letras_ciudad,
    cod_ciudad,
    nombre_ciudad
from dedup
where rn = 1