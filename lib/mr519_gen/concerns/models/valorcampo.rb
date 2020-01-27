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
            elsif campo.tipo == Mr519Gen::ApplicationHelper::SMTABLABASICA
              if self.campo.tablabasica.nil? 
                r += 'Problema tablabasica es nil'
              else
                ab = ::Ability.new
                tb = ab.tablasbasicas.select {|l| 
                  l[1] == self.campo.tablabasica.singularize 
                } 
                if tb.count != 1 
                  r += "Problema con tablabasica #{self.campo.tablabasica} " +
                    " porque hay #{tb.count}"
                else
                  cla = ::Ability::tb_clase(tb[0])
                  r += cla.where(id: self.valor_ids).map(&:nombre).join("; ")
                end
              end
            elsif campo.tipo == Mr519Gen::ApplicationHelper::SSTABLABASICA
              if self.campo.tablabasica.nil? 
                r += 'Problema tablabasica es nil'
              else
                ab = ::Ability.new
                tb = ab.tablasbasicas.select {|l| 
                  l[1] == self.campo.tablabasica.singularize 
                } 
                if tb.count != 1 
                  r += "Problema con tablabasica #{self.campo.tablabasica} " +
                    " porque hay #{tb.count}"
                else
                  cla = ::Ability::tb_clase(tb[0])
                  o = cla.where(id: self.valor).take
                  if o.respond_to?(:nombre)
                    r += o.nombre
                  end
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

