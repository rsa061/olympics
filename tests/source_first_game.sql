select 
    *
from {{ ref('bronze__olympic_athletes') }}
where juegos_participa != 0
    and primer_juego != null
    