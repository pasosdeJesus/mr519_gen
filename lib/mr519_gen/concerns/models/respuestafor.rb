# frozen_string_literal: true

module Mr519Gen
  module Concerns
    module Models
      module Respuestafor
        extend ActiveSupport::Concern

        included do
          include Msip::Modelo
          include Msip::Localizacion

          # Evita que rails la suponga en plural
          self.table_name = "mr519_gen_respuestafor"

          belongs_to :formulario,
            class_name: "Mr519Gen::Formulario",
            validate: true,
            optional: false

          has_many :valorcampo,
            dependent: :delete_all,
            class_name: "Mr519Gen::Valorcampo",
            foreign_key: "respuestafor_id",
            validate: true
          accepts_nested_attributes_for :valorcampo, reject_if: :all_blank

          has_many :encuetausuario,
            dependent: :delete_all,
            class_name: "Mr519Gen::Encuestausuario",
            foreign_key: "respuestafor_id",
            validate: true

          campofecha_localizado :fechaini
          campofecha_localizado :fechacambio

          validates :fechaini, presence: true
          validates :fechacambio, presence: true

          validate :fechas_en_orden
          def fechas_en_orden
            return unless fechaini && fechacambio && fechacambio < fechaini

            errors.add(:fechaini, "La fecha de cambio deber ser " +
                       " posterior o igual a la de primera aplicación")
          end

          def presenta_mr519_gen(atr)
            presenta_gen(atr)
          end

          def presenta(atr)
            presenta_mr519_gen(atr)
          end

          scope :filtro_fechainiini, lambda { |f|
            where("fechaini >= ?", f)
            # El control de fecha HTML estándar retorna la fecha
            # en formato yyyy-mm-dd siempre
          }

          scope :filtro_fechainifin, lambda { |f|
            where("fechaini <= ?", f)
          }

          scope :filtro_formulario, lambda { |fid|
            where(formulario_id: fid)
          }
        end
      end
    end
  end
end
