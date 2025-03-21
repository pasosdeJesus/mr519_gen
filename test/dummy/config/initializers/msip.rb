# frozen_string_literal: true

require "mr519_gen/version"

Msip.setup do |config|
  config.ruta_anexos = ENV.fetch(
    "MSIP_RUTA_ANEXOS",
    "#{Rails.root.join("archivos/anexos")}",
  )
  config.ruta_volcados = ENV.fetch(
    "MSIP_RUTA_VOLCADOS",
    "#{Rails.root.join("archivos/bd")}",
  )
  config.titulo = "mr519_gen #{Mr519Gen::VERSION}"
  config.descripcion = "Motor para manejar formularios y encuestas"
  config.codigofuente = "https://gitlab.com/pasosdeJesus/mr519_gen"
  config.urlcontribuyentes = "https://gitlab.com/pasosdeJesus/mr519_gen/-/graphs/main"
  config.urlcreditos = "https://gitlab.com/pasosdeJesus/mr519_gen/-/blob/main/CREDITOS.md"
  config.urllicencia = "https://gitlab.com/pasosdeJesus/mr519_gen/-/blob/main/LICENCIA.md"
  config.agradecimientoDios = "<p>
Agradecemos a Jesús/Dios por su misericordia.
</p>
<blockquote>
<p>
Mas Jesús no se lo permitió, sino que le dijo: Vete a tu casa, a los tuyos,
y cuéntales cuán grandes cosas el Señor ha hecho contigo,
y cómo ha tenido misericordia de ti.
</p>
<p>Marcos 5:19</p>
</blockquote>".html_safe
end
