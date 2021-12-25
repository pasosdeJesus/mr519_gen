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
            class_name: "Mr519Gen::Formulario", foreign_key: "formulario_id", 
            validate: true, optional: false

          has_many :valorcampo, dependent: :delete_all, 
            class_name: 'Mr519Gen::Valorcampo',
            foreign_key: 'campo_id',  validate: true

          has_many :opcioncs, dependent: :delete_all,
            class_name: 'Mr519Gen::Opcioncs',
            foreign_key: 'campo_id',  validate: true
          accepts_nested_attributes_for :opcioncs,
            allow_destroy: true, reject_if: :all_blank

          validates :ancho, allow_nil: true,
            numericality: {greater_than: 0, less_than: 13}
          validates :ayudauso, length: {maximum: 1024}
          validates :columna, allow_nil: true,
            numericality: {greater_than: 0, less_than: 13}
          validates :fila, allow_nil: true,
            numericality: {greater_than: 0}
          validates :nombre, length: {maximum: 512}, presence: true,
            allow_blank: true
          validates :nombreinterno, length: {maximum: 60}, presence: true,
            allow_blank: false, uniqueness: {
              scope: :formulario_id, 
              message: 'en el mismo formulario los campos deben tener nombre interno diferente'}

          validate :caracteres_nombre_interno
          def caracteres_nombre_interno
            if !(nombreinterno =~ /^[a-z0-9_]+$/)
              errors.add(:nombreinterno,
                         'Sólo debe tener caracteres alfanuméricos en minusculas y _')
            end
          end

        end # included

      end
    end
  end
end

