# frozen_string_literal: true

module Mr519Gen
  module ApplicationHelper
    include Msip::PaginacionAjaxHelper

    TEXTO = 1
    TEXTOLARGO = 2
    ENTERO = 3
    BOOLEANO = 4
    FLOTANTE = 5
    SELECCIONMULTIPLE = 10
    SELECCIONSIMPLE = 11
    FECHA = 12
    PRESENTATEXTO = 13
    SMTABLABASICA = 14
    SSTABLABASICA = 15

    TIPOS_CAMPO = [
      ["Booleano", BOOLEANO],
      ["Entero", ENTERO],
      ["Fecha", FECHA],
      ["Flotante", FLOTANTE],
      ["Respuesta abierta", TEXTO],
      ["Respuesta abierta larga", TEXTOLARGO],
      ["Presentar texto", PRESENTATEXTO],
      ["Selección Múltiple", SELECCIONMULTIPLE],
      ["Selección Múltiple con Tabla Básica", SMTABLABASICA],
      ["Selección Simple", SELECCIONSIMPLE],
      ["Selección Simple con Tabla Básica", SSTABLABASICA],
    ]

    # La misma constante debe estar en app/javascript/motor.coffee
    LONG_NOMBREINTERNO = 60

    def asegura_camposdinamicos(modeloconrf, _current_usuario_id)
      if modeloconrf.nil? || modeloconrf.respuestafor.nil? ||
          modeloconrf.respuestafor.formulario.nil?
        return
      end

      ci = modeloconrf.respuestafor.formulario.campo_ids
      cd = modeloconrf.respuestafor.valorcampo.map(&:campo_id)
      sobran = cd - ci
      borrar = modeloconrf.respuestafor.valorcampo.where(campo_id: sobran)
        .map(&:id)
      modeloconrf.respuestafor.valorcampo_ids -= borrar
      puts modeloconrf.respuestafor.valorcampo_ids
      faltan = ci - cd
      faltan.each do |f|
        vc = Mr519Gen::Valorcampo.new(
          respuestafor_id: modeloconrf.respuestafor_id,
          campo_id: f,
          valor: "",
        )
        vc.save!(validate: false)
      end
    end
    module_function :asegura_camposdinamicos

    def nombre_a_nombreinterno(nombre)
      ni = nombre.gsub(/[^A-Za-z0-9_]/, "_")
      ni = ni.downcase
      ni[0..(LONG_NOMBREINTERNO - 1)]
    end
    module_function :nombre_a_nombreinterno

    # resps es una serie de registros con asociación respuestafor a
    # Mr519::Respuestafor para un mismo formulario
    def analiza_respuestas(respuestafor_ids, titulo, consolidado, _menserr)
      resps = Mr519Gen::Respuestafor.where(id: respuestafor_ids)
      if resps.count == 0
        _menserr << "No hay encuestas respondidas"
        return false
      end
      titulo << "Resultados de encuesta: " +
        resps[0].formulario.nombre
      resps[0].formulario.campo.order(:id).each do |c|
        case c.tipo
        when Mr519Gen::ApplicationHelper::TEXTO,
          Mr519Gen::ApplicationHelper::TEXTOLARGO,
          Mr519Gen::ApplicationHelper::FECHA
          cons = ""
          sep = ""
          Mr519Gen::Valorcampo.where(campo_id: c.id)
            .where("respuestafor_id IN (#{resps.map(&:id).join(",")})")
            .each do |vc|
            if vc.valor && vc.valor.strip != ""
              cons += sep + vc.valor.to_s
              sep = ".<hr>".html_safe
            end
          end
        when Mr519Gen::ApplicationHelper::ENTERO,
          Mr519Gen::ApplicationHelper::FLOTANTE
          cons = Mr519Gen::Valorcampo.where(campo_id: c.id)
            .where("respuestafor_id IN (#{resps.map(&:id).join(",")})")
            .average("CASE
                             WHEN valor = '' THEN 0
                             ELSE CAST(valor AS NUMERIC)
                           END")
        when Mr519Gen::ApplicationHelper::BOOLEANO
          si = Mr519Gen::Valorcampo.where(campo_id: c.id)
            .where("respuestafor_id IN (#{resps.map(&:id).join(",")})")
            .where(valor: "t").count
          no = Mr519Gen::Valorcampo.where(campo_id: c.id)
            .where("valor <> 't'").count
          cons = "Si: #{si}.  No: #{no}"
        when Mr519Gen::ApplicationHelper::SSTABLABASICA
          ab = ::Ability.new
          tb = ab.tablasbasicas.select do |l|
            l[1] == c.tablabasica.singularize
          end
          cons = ""
          sep = ""
          cla = Ability.tb_clase(tb[0])
          col1 = cla.all
          col1 = col1.habilitados if col1.respond_to?(:habilitados)
          col1.each do |rb|
            cuenta = Mr519Gen::Valorcampo.where(campo_id: c.id)
              .where("respuestafor_id IN (#{resps.map(&:id).join(",")})")
              .where("valor = ?", rb.id.to_s).count
            cons += sep + "#{rb.nombre}: #{cuenta}"
            sep = "<br> ".html_safe
          end
          cuenta = Mr519Gen::Valorcampo.where(campo_id: c.id)
            .where("respuestafor_id IN (#{resps.map(&:id).join(",")})")
            .where("valor = '' OR valor IS NULL").count
          cons += sep + "No respondida: #{cuenta}" if cuenta > 0

        when Mr519Gen::ApplicationHelper::SELECCIONSIMPLE
          cons = ""
          sep = ""
          Mr519Gen::Opcioncs.where(campo_id: c.id).each do |op|
            cuenta = Mr519Gen::Valorcampo.where(campo_id: c.id)
              .where("respuestafor_id IN (#{resps.map(&:id).join(",")})")
              .where("valor = ?", op.id.to_s).count
            cons += sep + "#{op.nombre}: #{cuenta}"
            sep = "<br> ".html_safe
          end
          cuenta = Mr519Gen::Valorcampo.where(campo_id: c.id)
            .where("respuestafor_id IN (#{resps.map(&:id).join(",")})")
            .where("valor = '' OR valor IS NULL").count
          cons += sep + "No respondida: #{cuenta}" if cuenta > 0

        else
          puts "Tipo desconocido"
          cons = "Tipo desconocido"
        end
        consolidado << { pregunta: c.nombre, consolidado: cons } if c.tipo != Mr519Gen::ApplicationHelper::PRESENTATEXTO
      end
      true
    end
    module_function :analiza_respuestas

    # Dado un objeto que puede tener varios respuestafor  y un formulario_id
    # y un campo_id retorna el valor del campo en el formulario o nil
    def presenta_valor(objeto, formulario_id, campo_id)
      rf = objeto.respuestafor.find_by(formulario_id: formulario_id)
      return unless rf

      vc = rf.valorcampo.find_by(campo_id: campo_id)
      return unless vc

      vc.presenta_valor(false)
    end
    module_function :presenta_valor
  end
end
