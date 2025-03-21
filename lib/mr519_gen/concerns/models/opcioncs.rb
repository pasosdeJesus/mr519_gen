# frozen_string_literal: true

module Mr519Gen
  module Concerns
    module Models
      module Opcioncs
        extend ActiveSupport::Concern

        included do
          include Msip::Modelo

          # Evita que rails la suponga en plural
          self.table_name = "mr519_gen_opcioncs"

          belongs_to :campo,
            class_name: "Mr519Gen::Campo",
            inverse_of: :opcioncs,
            optional: true,
            validate: true

          validates :valor,
            length: { maximum: 60 },
            presence: true,
            uniqueness: {
              scope: :campo_id,
              message: "En el mismo campo los valores de las opciones deben ser diferentes",
            }
          validates :nombre,
            length: { maximum: 1024 },
            presence: true,
            allow_blank: false,
            uniqueness: {
              scope: :campo_id,
              message: "En el mismo campo las opciones deben tener nombre diferente",
            }
        end # included
      end
    end
  end
end
