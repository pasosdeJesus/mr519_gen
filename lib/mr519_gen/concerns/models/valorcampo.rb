# frozen_string_literal: true

module Mr519Gen
  module Concerns
    module Models
      module Valorcampo
        extend ActiveSupport::Concern

        included do
          include Msip::Modelo

          # Evita que rails la suponga en plural
          self.table_name = "mr519_gen_valorcampo"

          belongs_to :campo,
            class_name: "Mr519Gen::Campo",
            optional: false,
            validate: true

          belongs_to :respuestafor,
            optional: false,
            class_name: "Mr519Gen::Respuestafor",
            validate: true

          validates :valor, length: { maximum: 5000 }

          def valor_ids=(v)
            self.valorjson = v
          end

          def valor_ids
            valorjson
          end

          def presenta_valor(con_nombre_campo = true)
            r = ""
            r = "#{campo.presenta_nombre}: " if con_nombre_campo
            if !campo.tipo ||
                campo.tipo == Mr519Gen::ApplicationHelper::TEXTO ||
                campo.tipo == Mr519Gen::ApplicationHelper::TEXTOLARGO ||
                campo.tipo == Mr519Gen::ApplicationHelper::FECHA
              r += "#{valor}"
            elsif campo.tipo == Mr519Gen::ApplicationHelper::ENTERO
              if r == ""
                r = valor.to_i
              else
                r += "#{valor}"
              end
            elsif campo.tipo == Mr519Gen::ApplicationHelper::FLOTANTE
              if r == ""
                r = valor.to_f
              else
                r += "#{valor.to_f}"
              end
            elsif campo.tipo == Mr519Gen::ApplicationHelper::PRESENTATEXTO
              r += campo.nombre
            elsif campo.tipo == Mr519Gen::ApplicationHelper::BOOLEANO
              r += valor.to_i == 0 ? "NO" : "SI"
            elsif campo.tipo == Mr519Gen::ApplicationHelper::SELECCIONMULTIPLE
              r += valorjson.to_s
            elsif campo.tipo == Mr519Gen::ApplicationHelper::SELECCIONSIMPLE
              op = Mr519Gen::Opcioncs.where(id: valor.to_i)
              r += op.take.nombre if op.count == 1
            elsif campo.tipo == Mr519Gen::ApplicationHelper::SMTABLABASICA
              if campo.tablabasica.nil?
                r += "Problema tablabasica es nil"
              else
                ab = ::Ability.new
                tb = ab.tablasbasicas.select do |l|
                  l[1] == campo.tablabasica.singularize
                end
                if tb.count != 1
                  r += "Problema con tablabasica #{campo.tablabasica} " +
                    " porque hay #{tb.count}"
                else
                  cla = ::Ability.tb_clase(tb[0])
                  r += cla.where(id: valor_ids).map(&:nombre).join("; ")
                end
              end
            elsif campo.tipo == Mr519Gen::ApplicationHelper::SSTABLABASICA
              if campo.tablabasica.nil?
                r += "Problema tablabasica es nil"
              else
                ab = ::Ability.new
                tb = ab.tablasbasicas.select do |l|
                  l[1] == campo.tablabasica.singularize
                end
                if tb.count != 1
                  r += "Problema con tablabasica #{campo.tablabasica} " +
                    " porque hay #{tb.count}"
                else
                  cla = ::Ability.tb_clase(tb[0])
                  o = cla.where(id: valor).take
                  r += o.nombre if o.respond_to?(:nombre)
                end
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
