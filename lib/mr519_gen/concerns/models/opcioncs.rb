# encoding: UTF-8

module Mr519Gen
  module Concerns
    module Models
      module Opcioncs
        extend ActiveSupport::Concern

        included do
          include Sip::Modelo

          # Evita que rails la suponga en plural
          self.table_name = 'mr519_gen_opcioncs'

          belongs_to :campo,
            class_name: "Mr519Gen::Campo",
            foreign_key: "campo_id", validate: true

          validates :valor, length: {maximum: 1024}
          validates :nombre, length: {maximum: 1024}

        end # included

      end
    end
  end
end

