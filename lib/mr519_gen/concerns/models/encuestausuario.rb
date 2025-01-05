# frozen_string_literal: true

module Mr519Gen
  module Concerns
    module Models
      module Encuestausuario
        extend ActiveSupport::Concern

        included do
          include Msip::Modelo
          include Msip::Localizacion

          # Evita que rails la suponga en plural
          self.table_name = "mr519_gen_encuestausuario"

          belongs_to :usuario,
            class_name: "::Usuario",
            validate: true,
            optional: false
          belongs_to :respuestafor,
            class_name: "Mr519Gen::Respuestafor",
            validate: true,
            optional: false
          accepts_nested_attributes_for :respuestafor, reject_if: :all_blank

          has_one :formulario,
            through: :respuestafor,
            class_name: "Mr519Gen::Formulario"
          accepts_nested_attributes_for :formulario, reject_if: :all_blank

          # has_many :valorcampo, through: :respuestafor,
          #  class_name: 'Mr519Gen::Valorcampo'
          # accepts_nested_attributes_for :valorcampo,  reject_if: :all_blank

          campofecha_localizado :fechainicio
          campofecha_localizado :fechafin

          validates :fechainicio, presence: true

          validate :fechas_en_orden
          def fechas_en_orden
            if fechafin && fechainicio && fechafin < fechainicio
              errors.add(:fechainicio, "La fecha de inicio debe ser " +
                         " anterior a la de terminación")
            end
            if fechainicio && respuestafor && respuestafor.fechaini &&
                respuestafor.fechaini < fechainicio
              errors.add(:fechainicio, "La fecha de comienzo de " +
                         "aplicación debe ser posterior " +
                         "a la de inicio")
            end
            if fechainicio && respuestafor && respuestafor.fechacambio &&
                respuestafor.fechacambio < fechainicio
              errors.add(:fechainicio, "La fecha de actualización " +
                         "debe ser posterior " +
                         "a la de inicio")
            end
          end

          attr_accessor :fechaini

          def fechaini
            if !respuestafor.nil? &&
                !respuestafor.fechaini.nil?
              respuestafor.fechaini
            end
          end

          def fechaini=(val)
            self.respuestafor = Mr519Gen::Respuestafor.new if respuestafor.nil?
            respuestafor.fechaini = val
          end

          attr_accessor :fechacambio

          def fechacambio
            if !respuestafor.nil? &&
                !respuestafor.fechacambio.nil?
              respuestafor.fechacambio
            end
          end

          def fechacambio=(val)
            self.respuestafor = Mr519Gen::Respuestafor.new if respuestafor.nil?
            respuestafor.fechacambio = val
          end

          attr_accessor :formulario_id

          def formulario_id
            if !respuestafor.nil? &&
                !respuestafor.formulario_id.nil?
              respuestafor.formulario_id
            end
          end

          def formulario_id=(val)
            self.respuestafor = Mr519Gen::Respuestafor.new if respuestafor.nil?
            respuestafor.formulario_id = val
          end

          def presenta_mr519_gen(atr)
            case atr.to_s
            when "valorcampo"
              if respuestafor.nil?
                ""
              elsif respuestafor.valorcampo.nil?
                ""
              else
                respuestafor.valorcampo.inject("") do |memo, r|
                  memo + " " + r.valor
                end
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
              "mr519_gen_respuestafor.fechaini >= ?", f
            )
            # El control de fecha HTML estándar retorna la fecha
            # en formato yyyy-mm-dd siempre
          }

          scope :filtro_fechainifin, lambda { |f|
            joins(:respuestafor).where(
              "mr519_gen_respuestafor.fechaini <= ?", f
            )
          }

          scope :filtro_usuario, lambda { |uid|
            where(usuario_id: uid)
          }

          scope :filtro_formulario, lambda { |fid|
            joins(:respuestafor).where(
              "mr519_gen_respuestafor.formulario_id=?", fid
            )
          }
        end
      end
    end
  end
end
