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
          belongs_to :respuestafor, class_name: 'Mr519Gen::Respuestafor', 
            foreign_key: 'respuestafor_id', validate: true
          accepts_nested_attributes_for :respuestafor,  reject_if: :all_blank

          has_one :formulario, through: :respuestafor,
            class_name: 'Mr519Gen::Formulario'
          accepts_nested_attributes_for :formulario,  reject_if: :all_blank


          has_many :valorcampo, through: :respuestafor,
            class_name: 'Mr519Gen::Valorcampo'
          accepts_nested_attributes_for :valorcampo,  reject_if: :all_blank

          campofecha_localizado :fechainicio
          campofecha_localizado :fechafin

          validates :fechainicio, presence: true

          validate :fechas_en_orden
          def fechas_en_orden
            if (fechafin && fechainicio && fechafin < fechainicio) then
                  errors.add(:fechainicio, "La fecha de inicio debe ser " +
                             " anterior a la de terminación")
            end
            if (fechainicio && respuestafor && respuestafor.fechaini && 
                respuestafor.fechaini < fechainicio) then
                  errors.add(:fechainicio, "La fecha de comienzo de " +
                             "aplicación debe ser posterior " +
                             "a la de inicio")
            end
            if (fechainicio && respuestafor && respuestafor.fechacambio && 
                respuestafor.fechacambio < fechainicio) then
                  errors.add(:fechainicio, "La fecha de actualización " +
                             "debe ser posterior " +
                             "a la de inicio")
            end
          end

          attr_accessor :fechaini_localizada
          def fechaini_localizada
            !self.respuestafor.nil? && 
                !self.respuestafor.fechaini_localizada.nil?  ?
                self.respuestafor.fechaini_localizada : nil
          end

          def fechaini_localizada=(val)
            if self.respuestafor.nil?
              self.respuestafor = Mr519Gen::Respuestafor.new
            end
            self.respuestafor.fechaini_localizada = val
          end
          
          attr_accessor :fechacambio_localizada
          def fechacambio_localizada
            !self.respuestafor.nil? && 
                !self.respuestafor.fechacambio_localizada.nil?  ?
                self.respuestafor.fechacambio_localizada : nil
          end

          def fechacambio_localizada=(val)
            if self.respuestafor.nil?
              self.respuestafor = Mr519Gen::Respuestafor.new
            end
            self.respuestafor.fechacambio_localizada = val
          end

          attr_accessor :formulario_id
          def formulario_id
            !self.respuestafor.nil? && 
                !self.respuestafor.formulario_id.nil?  ?
                self.respuestafor.formulario_id : nil
          end

          def formulario_id=(val)
            if self.respuestafor.nil?
              self.respuestafor = Mr519Gen::Respuestafor.new
            end
            self.respuestafor.formulario_id = val
          end


          def presenta_mr519_gen(atr)
            case atr.to_s
            when 'valorcampo'
              if self.respuestafor.nil?
                ''
              elsif self.respuestafor.valorcampo.nil?
                ''
              else
                self.respuestafor.valorcampo.inject("") {
                  |memo, r| memo + ' ' + r.valor
                }
              end
            else
              presenta_gen(atr)
            end
          end

          def presenta(atr)
            presenta_mr519_gen(atr)
          end

          scope :filtro_fechainiini, lambda { |f|
            joins(:respuestafor).where(
              'mr519_gen_respuestafor.fechaini >= ?', f)
            # El control de fecha HTML estándar retorna la fecha
            # en formato yyyy-mm-dd siempre
          }

          scope :filtro_fechainifin, lambda { |f|
            joins(:respuestafor).where(
              'mr519_gen_respuestafor.fechaini <= ?', f)
          }

          scope :filtro_usuario, lambda { |uid|
            where(usuario_id: uid)
          }
          
          scope :filtro_formulario, lambda { |fid|
            joins(:respuestafor).where(
              'mr519_gen_respuestafor.formulario_id=?', fid)
          }

        end
      end
    end
  end
end

