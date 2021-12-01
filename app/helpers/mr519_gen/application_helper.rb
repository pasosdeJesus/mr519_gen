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


    # resps es una serie de registros con asociación respuestafor a
    # Mr519::Respuestafor para una
    # mismo formulario
    def analiza_respuestas(respuestafor_ids, titulo, consolidado, menserr)
      resps = Mr519Gen::Respuestafor.where(id: respuestafor_ids)
      if resps.count == 0
        menserr = "No hay encuestas respondidas"
        return false
      end
      titulo << "Resultados de encuesta: " + 
        resps[0].formulario.nombre
      resps[0].formulario.campo.order(:id).each do |c|
        case c.tipo 
        when Mr519Gen::ApplicationHelper::TEXTO, 
          Mr519Gen::ApplicationHelper::TEXTOLARGO,
          Mr519Gen::ApplicationHelper::FECHA
          cons = ''
          sep = ''
          Mr519Gen::Valorcampo.where(campo_id: c.id).
            where("respuestafor_id IN (#{resps.map(&:id).join(',')})").
            each do |vc|
            if vc.valor && vc.valor.strip != ''
              cons += sep + vc.valor.to_s
              sep = '.<hr>'.html_safe
            end
          end
        when Mr519Gen::ApplicationHelper::ENTERO,
          Mr519Gen::ApplicationHelper::FLOTANTE
          cons = Mr519Gen::Valorcampo.where(campo_id: c.id).
            where("respuestafor_id IN (#{resps.map(&:id).join(',')})").
            average("CASE 
                             WHEN valor = '' THEN 0 
                             ELSE CAST(valor AS NUMERIC) 
                           END")
        when Mr519Gen::ApplicationHelper::BOOLEANO
          si = Mr519Gen::Valorcampo.where(campo_id: c.id).
            where("respuestafor_id IN (#{resps.map(&:id).join(',')})").
            where(valor: 't').count
            no = Mr519Gen::Valorcampo.where(campo_id: c.id).
              where("valor <> 't'").count
            cons = "Si: #{si}.  No: #{no}"  
        when Mr519Gen::ApplicationHelper::SSTABLABASICA
          ab = ::Ability.new
          tb = ab.tablasbasicas.select {|l| 
            l[1] == c.tablabasica.singularize
          }
          cons = ''
          sep = ''
          cla = Ability::tb_clase(tb[0])
          col1 = cla.all 
          if col1.respond_to?(:habilitados)
            col1 = col1.habilitados
          end 
          col1.each do |rb|
            cuenta = Mr519Gen::Valorcampo.where(campo_id: c.id).
              where("respuestafor_id IN (#{resps.map(&:id).join(',')})").
              where("valor = ?", rb.id.to_s).count
              cons += sep + "#{rb.nombre}: #{cuenta}"
              sep = "<br> ".html_safe
          end
          cuenta = Mr519Gen::Valorcampo.where(campo_id: c.id).
            where("respuestafor_id IN (#{resps.map(&:id).join(',')})").
            where("valor = '' OR valor IS NULL").count
          if cuenta > 0
            cons += sep + "No respondida: #{cuenta}"
          end

        when Mr519Gen::ApplicationHelper::SELECCIONSIMPLE
          cons = ''
          sep = ''
          Mr519Gen::Opcioncs.where(campo_id: c.id).each do |op|
            cuenta = Mr519Gen::Valorcampo.where(campo_id: c.id).
              where("respuestafor_id IN (#{resps.map(&:id).join(',')})").
              where("valor = ?", op.id.to_s).count
              cons += sep + "#{op.nombre}: #{cuenta}"
              sep = "<br> ".html_safe
          end
          cuenta = Mr519Gen::Valorcampo.where(campo_id: c.id).
            where("respuestafor_id IN (#{resps.map(&:id).join(',')})").
            where("valor = '' OR valor IS NULL").count
          if cuenta > 0
            cons += sep + "No respondida: #{cuenta}"
          end

        else
          puts "Tipo desconocido"
          cons = "Tipo desconocido"
        end
        if c.tipo != Mr519Gen::ApplicationHelper::PRESENTATEXTO
          consolidado << {pregunta: c.nombre, consolidado: cons}
        end
      end
      return true
    end 
    module_function :analiza_respuestas


    # Dado un objeto que puede tener varios respuestafor  y un formulario_id
    # y un campo_id retorna el valor del campo en el formulario o nil
    def presenta_valor(objeto, formulario_id, campo_id)
      rf = objeto.respuestafor.where(formulario_id: formulario_id).take
      if !rf
        return nil
      end
      vc = rf.valorcampo.where(campo_id: campo_id).take 
      if !vc
        return nil
      end
      vc.presenta_valor(false)
    end
    module_function :presenta_valor



  end
end
