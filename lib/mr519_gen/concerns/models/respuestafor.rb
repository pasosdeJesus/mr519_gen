module Mr519Gen
  module Concerns
    module Models
      module Respuestafor
        extend ActiveSupport::Concern

        included do
          include Sip::Modelo
          include Sip::Localizacion

          # Evita que rails la suponga en plural
          self.table_name = 'mr519_gen_respuestafor'

          belongs_to :formulario, class_name: 'Mr519Gen::Formulario', 
            foreign_key: 'formulario_id', validate: true

          has_many :valorcampo, dependent: :delete_all,
            class_name: 'Mr519Gen::Valorcampo',
            foreign_key: 'respuestafor_id', validate: true
          accepts_nested_attributes_for :valorcampo,  reject_if: :all_blank

          has_many :encuetausuario, dependent: :delete_all,
            class_name: 'Mr519Gen::Encuestausuario',
            foreign_key: 'respuestafor_id', validate: true

          campofecha_localizado :fechaini
          campofecha_localizado :fechacambio

          validates :fechaini, presence: true
          validates :fechacambio, presence: true

          validate :fechas_en_orden
          def fechas_en_orden
            if (fechaini && fechacambio && fechacambio < fechaini) then
                  errors.add(:fechaini, "La fecha de cambio deber ser " +
                             " posterior o igual a la de primera aplicación")
            end
          end

          def presenta_mr519_gen(atr)
            presenta_gen(atr)
          end

          def presenta(atr)
            presenta_mr519_gen(atr)
          end

          scope :filtro_fechainiini, lambda { |f|
            where('fechaini >= ?', f)
            # El control de fecha HTML estándar retorna la fecha
            # en formato yyyy-mm-dd siempre
          }

          scope :filtro_fechainifin, lambda { |f|
            where('fechaini <= ?', f)
          }

          scope :filtro_formulario, lambda { |fid|
            where(formulario_id: fid)
          }

        end
      end
    end
  end
end

