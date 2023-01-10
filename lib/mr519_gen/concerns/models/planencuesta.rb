# frozen_string_literal: true

module Mr519Gen
  module Concerns
    module Models
      module Planencuesta
        extend ActiveSupport::Concern

        included do
          include Msip::Modelo
          include Msip::Localizacion

          # Evita que rails la suponga en plural
          self.table_name = "mr519_gen_planencuesta"

          belongs_to :formulario,
            class_name: "Mr519Gen::Formulario",
            optional: false
          # belongs_to :plantillacorreoinv, class_name: '::Plantillacorreo',
          #  foreign_key: :plantillacorreoinv_id, optional: true

          has_secure_token :adurl

          has_many :encuestapersona,
            dependent: :destroy,
            class_name: "Mr519Gen::Encuestapersona",
            foreign_key: "planencuesta_id"
          accepts_nested_attributes_for :encuestapersona,
            allow_destroy: true,
            reject_if: :all_blank
          has_many :persona,
            through: :encuestapersona,
            class_name: "Msip::Persona"

          campofecha_localizado :fechaini
          campofecha_localizado :fechafin

          validate :fechas_ordenadas
          def fechas_ordenadas
            return unless fechaini && fechafin && fechaini > fechafin

            errors.add(
              :fechafin,
              "La fecha de terminación debe ser posterior a la de inicio",
            )
          end

          def presenta_nombre
            formulario_id ? formulario.nombre + " (#{id})" : "#{id}"
          end
        end # included
      end
    end
  end
end
