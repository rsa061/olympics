{% snapshot snp_olympic_athletes %}

{{
    config(
        target_schema='snapshots',
        unique_key='url',
        strategy='check',
        check_cols=['nombre', 'juegos_participa', 'primer_juego', 'anio_nac', 'medallas', 'bio']
    )
}}

select
    url,
    nombre,
    juegos_participa,
    primer_juego,
    anio_nac,
    medallas,
    bio
from {{ ref('stg_bronze__olympic_athletes_raw') }}

{% endsnapshot %}