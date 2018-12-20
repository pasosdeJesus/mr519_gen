#encoding: UTF-8 

Sip.setup do |config|
      config.ruta_anexos = "#{Rails.root}/archivos/anexos/"
      config.ruta_volcados = "#{Rails.root}/archivos/volcados/"
      # En heroku los anexos son super-temporales
      if !ENV["HEROKU_POSTGRESQL_GREEN_URL"].nil?
        config.ruta_anexos = "#{Rails.root}/tmp/"
      end
      config.titulo = "Aplicación mínima que usa mr519_gen"
end
