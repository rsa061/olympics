select *
from {{ ref('fct_results') }}
where atletas = null
  and url_atleta != null
  and nombre_atleta != null
  and primer_juego_atleta != null
  and anio_nac_atleta != null