# frozen_string_literal: true

module Mr519Gen
  module Concerns
    module Models
      module Formulario
        extend ActiveSupport::Concern

        included do
          include Msip::Modelo
          include Msip::Localizacion

          # Evita que rails la suponga en plural
          self.table_name = "mr519_gen_formulario"

          has_many :campo,
            class_name: "Mr519Gen::Campo",
            dependent: :destroy,
            foreign_key: "formulario_id",
            inverse_of: :formulario,
            validate: true
          accepts_nested_attributes_for :campo,
            allow_destroy: true,
            reject_if: :all_blank

          has_many :respuestafor,
            class_name: "Mr519Gen::Respuestafor",
            dependent: :destroy,
            foreign_key: "formulario_id",
            validate: true

          validates :nombre,
            length: { maximum: 500 },
            presence: true,
            uniqueness: true,
            allow_blank: false
          validates :nombreinterno,
            length: { maximum: 60 },
            presence: true,
            uniqueness: true,
            allow_blank: false

          validate :caracteres_nombre_interno
          def caracteres_nombre_interno
            return if nombreinterno =~ /^[a-z0-9_]+$/

            errors.add(
              :nombreinterno,
              "Sólo debe tener caracteres alfanuméricos en minusculas y _",
            )
          end

          scope :filtro_nombre, lambda { |n|
            where("unaccent(nombre) ILIKE '%' || unaccent(?) || '%'", n)
          }
        end
      end
    end
  end
end
