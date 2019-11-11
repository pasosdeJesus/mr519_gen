# encoding: UTF-8

module Mr519Gen
  module Concerns
    module Models
      module Formulario
        extend ActiveSupport::Concern

        included do
          include Sip::Modelo
          include Sip::Localizacion

          # Evita que rails la suponga en plural
          self.table_name = 'mr519_gen_formulario'

          has_many :campos,
            class_name: "Mr519Gen::Campo",
            foreign_key: "formulario_id", validate: true,
            dependent: :destroy
          accepts_nested_attributes_for :campos,
            allow_destroy: true, reject_if: :all_blank

          has_many :respuestafor,
            class_name: "Mr519Gen::Respuestafor",
            foreign_key: "formulario_id", validate: true,
            dependent: :destroy

          validates :nombre, length: {maximum: 500}, presence: true,
            uniqueness: true, allow_blank: false
          validates :nombreinterno, length: {maximum: 60}, presence: true,
            uniqueness: true, allow_blank: false

          validate :caracteres_nombre_interno
          def caracteres_nombre_interno
            if !(nombreinterno =~ /^[a-z0-9_]+$/)
              errors.add(:nombreinterno,
                         'Sólo debe tener caracteres alfanuméricos en minusculas y _')
            end
          end

        end

      end
    end
  end
end
