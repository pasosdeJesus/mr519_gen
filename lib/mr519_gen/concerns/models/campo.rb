# encoding: UTF-8

module Mr519Gen
  module Concerns
    module Models
      module Campo
        extend ActiveSupport::Concern

        included do
          include Sip::Modelo

          # Evita que rails la suponga en plural
          self.table_name = 'mr519_gen_campo'

          belongs_to :formulario,
            class_name: "Mr519Gen::Formulario",
            foreign_key: "formulario_id", validate: true

          has_many :valorcampo, dependent: :delete_all,
            class_name: 'Mr519Gen::Valorcampo',
            foreign_key: 'campo_id',  validate: true

          validates :nombre, length: {maximum: 128}, presence: true
          validates :ayudauso, length: {maximum: 1024}
        end # included

      end
    end
  end
end

