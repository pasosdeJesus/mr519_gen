# encoding: UTF-8

module  Mr519Gen
  module Concerns
    module Models
      module Encuestausuario
        extend ActiveSupport::Concern

        included do
          include Sip::Modelo 
          include Sip::Localizacion

          # Evita que rails la suponga en plural
          self.table_name = 'mr519_gen_encuestausuario'

          belongs_to :usuario, class_name: '::Usuario', 
            foreign_key: 'usuario_id', validate: true
          belongs_to :formulario, class_name: 'Mr519Gen::Formulario', 
            foreign_key: 'formulario_id', validate: true

          has_many :encuestausuario_valorcampo, dependent: :delete_all,
            class_name: 'Mr519Gen::EncuestausuarioValorcampo',
            foreign_key: 'encuestausuario_id', validate: true
          accepts_nested_attributes_for :encuestausuario_valorcampo,
            allow_destroy: true, reject_if: :all_blank
          has_many :valorcampo, through: :encuestausuario_valorcampo,
            class_name: 'Mr519Gen::Valorcampo'
          accepts_nested_attributes_for :valorcampo,  reject_if: :all_blank

          campofecha_localizado :fecha
          campofecha_localizado :fechainicio
          campofecha_localizado :fechafin

          validates :fechainicio, presence: true

          validate :fechas_en_orden
          def fechas_en_orden
            if (fechafin && fechainicio && fechafin < fechainicio) then
                  errors.add(:fechainicio, "La fecha de inicio debe ser " +
                             " anterior a la de terminación")
            end
            if (fechainicio && fecha && fecha < fechainicio) then
                  errors.add(:fecha, "La fecha de aplicación debe ser " +
                             " posterior a la de inicio")
            end
          end

          def presenta_mr519_gen(atr)
            presenta_gen(atr)
          end

          def presenta(atr)
            presenta_mr519_gen(atr)
          end

          scope :filtro_fechaini, lambda { |f|
            where('fecha >= ?', f)
            # El control de fecha HTML estándar retorna la fecha
            # en formato yyyy-mm-dd siempre
          }

          scope :filtro_fechafin, lambda { |f|
            where('fecha <= ?', f)
          }

          scope :filtro_usuario, lambda { |u|
            where("usuunaccent(nombre) ILIKE '%' || unaccent(?) || '%'", n)
          }
 
          scope :filtro_usuario, lambda { |uid|
            where(usuario_id: uid)
          }
          
          scope :filtro_formulario, lambda { |fid|
            where(formulario_id: fid)
          }

        end
      end
    end
  end
end

