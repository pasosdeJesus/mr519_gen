module Mr519Gen
  module ApplicationHelper
    include Sip::PaginacionAjaxHelper

    TEXTO = 1
    TEXTOLARGO = 2
    ENTERO = 3
    BOOLEANO = 4
    FLOTANTE = 5
    SELECCIONMULTIPLE = 10
    SELECCIONSIMPLE = 11
    FECHA = 12
    PRESENTATEXTO = 13
    SMTABLABASICA =14  
    SSTABLABASICA =15

    TIPOS_CAMPO = [ 
                      ['Booleano', BOOLEANO],
                      ['Entero', ENTERO],
                      ['Fecha', FECHA],
                      ['Flotante', FLOTANTE],
                      ['Respuesta abierta', TEXTO],  
                      ['Respuesta abierta larga', TEXTOLARGO],
                      ['Presentar texto', PRESENTATEXTO],
                      ['Selección Múltiple', SELECCIONMULTIPLE],
                      ['Selección Múltiple con Tabla Básica', SMTABLABASICA],
                      ['Selección Simple', SELECCIONSIMPLE],
                      ['Selección Simple con Tabla Básica', SSTABLABASICA ]
    ]

    # La misma constante debe estar en app/javascript/motor.coffee
    LONG_NOMBREINTERNO=60

    def asegura_camposdinamicos(modeloconrf, current_usuario_id)
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

    def nombre_a_nombreinterno(nombre)
      ni = nombre.gsub(/[^A-Za-z0-9_]/, '_')
      ni = ni.downcase
      ni = ni[0..(LONG_NOMBREINTERNO-1)]
      return ni
    end
    module_function :nombre_a_nombreinterno

  end
end
