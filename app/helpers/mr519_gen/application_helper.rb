module Mr519Gen
  module ApplicationHelper
    include ::FontAwesome::Rails::IconHelper
    include Sip::PaginacionAjaxHelper

    TEXTO = 1
    TEXTOLARGO = 2
    ENTERO = 3
    BOOLEANO = 4
    FLOTANTE = 5
    SELECCIONMULTIPLE = 10
    SELECCIONSIMPLE = 11

    TIPOS_CAMPO = [ ['Texto', TEXTO],
                      ['Texto largo', TEXTOLARGO],
                      ['Entero', ENTERO],
                      ['Booleano', BOOLEANO],
                      ['Flotante', FLOTANTE],
                      ['Selección Múltiple', SELECCIONMULTIPLE],
                      ['Selección Simple', SELECCIONSIMPLE]
    ]

    def asegura_camposdinamicos(modeloconrf)
      if modeloconrf.nil? || modeloconrf.respuestafor.nil? ||
          modeloconrf.respuestafor.formulario.nil? 
        return
      end
      ci = modeloconrf.respuestafor.formulario.campo_ids
      cd = modeloconrf.respuestafor.valorcampo.map(&:campo_id)
      sobran = cd - ci
      borrar = modeloconrf.respuestafor.valorcampo.where(campo_id: sobran).
        map(&:id)
      modeloconrf.respuestafor.valorcampo_ids -= borrar
      puts modeloconrf.respuestafor.valorcampo_ids 
      faltan = ci - cd
      faltan.each do |f|
        vc = Mr519Gen::Valorcampo.new(
          respuestafor_id: modeloconrf.respuestafor_id, 
          campo_id: f, 
          valor: '')
        vc.save!(validate: false)
      end
    end
    module_function :asegura_camposdinamicos


  end
end
