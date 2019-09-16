# encoding: UTF-8

module Mr519Gen
  module Concerns
    module Models
      module Valorcampo
        extend ActiveSupport::Concern

        included do
          include Sip::Modelo

          # Evita que rails la suponga en plural
          self.table_name = 'mr519_gen_valorcampo'

          belongs_to :campo,
            class_name: "Mr519Gen::Campo",
            foreign_key: "campo_id", validate: true

          belongs_to :respuestafor,
            class_name: "Mr519Gen::Respuestafor",
            foreign_key: "respuestafor_id", validate: true

          validates :valor, length: {maximum: 5000}

          def valor_ids=(v)
            self.valorjson = v
          end

          def valor_ids
            self.valorjson
          end

          def presenta_valor(con_nombre_campo = true)
            r = ''
            if con_nombre_campo
              r = "#{campo.presenta_nombre}: "
            end
            if !campo.tipo || campo.tipo == Mr519Gen::ApplicationHelper::ENTERO || 
                campo.tipo == Mr519Gen::ApplicationHelper::FLOTANTE || 
                campo.tipo == Mr519Gen::ApplicationHelper::TEXTO ||
                campo.tipo == Mr519Gen::ApplicationHelper::TEXTOLARGO
              r += "#{valor.to_s}"
            elsif campo.tipo == Mr519Gen::ApplicationHelper::BOOLEANO
              r += valor.to_i == 0 ? "NO" : "SI"
            elsif campo.tipo == Mr519Gen::ApplicationHelper::SELECCIONMULTIPLE
              r += valorjson.to_s
            elsif campo.tipo == Mr519Gen::ApplicationHelper::SELECCIONSIMPLE
              op = Mr519Gen::Opcioncs.where(id: valor.to_i)
              if op.count == 1
                r += op.take.nombre
              end
            end
            r
          end

          def presenta_nombre
            presenta_valor
          end

        end # included

      end
    end
  end
end

