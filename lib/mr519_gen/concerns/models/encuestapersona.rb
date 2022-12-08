module  Mr519Gen
  module Concerns
    module Models
      module Encuestapersona
        extend ActiveSupport::Concern

        included do
          include Msip::Modelo 
          include Msip::Localizacion

          has_secure_token :adurl

          # Evita que rails la suponga en plural
          self.table_name = 'mr519_gen_encuestapersona'

          belongs_to :persona, class_name: 'Msip::Persona', 
            foreign_key: 'persona_id', validate: true, optional: true
          belongs_to :formulariodec, class_name: 'Mr519Gen::Formulario', 
            foreign_key: 'formulario_id', validate: true, optional: true
          belongs_to :planencuesta, class_name: 'Mr519Gen::Planencuesta',
            foreign_key: :planencuesta_id 
          belongs_to :respuestafor, class_name: 'Mr519Gen::Respuestafor', 
            foreign_key: 'respuestafor_id', validate: true, optional: false
          accepts_nested_attributes_for :respuestafor,  reject_if: :all_blank

          has_one :formulario, through: :respuestafor,
            class_name: 'Mr519Gen::Formulario'
          accepts_nested_attributes_for :formulario,  reject_if: :all_blank


          has_many :valorcampo, through: :respuestafor,
            class_name: 'Mr519Gen::Valorcampo'
          accepts_nested_attributes_for :valorcampo,  reject_if: :all_blank

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


          def presenta_nombre
            if persona.nil?
              return id
            else
              return persona.presenta_nombre
            end
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

          def self.modelos_path
            'encuestaspersona_path'
          end

          def modelos_path
            'encuestaspersona_path'
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

          scope :filtro_persona, lambda { |idp|
            where(persona_id: idp)
          }
 
#          scope :filtro_usuario, lambda { |uid|
#            where(usuario_id: uid)
#          }
          
          scope :filtro_formulario_id, lambda { |fid|
            joins(:respuestafor).where(
              'mr519_gen_respuestafor.formulario_id=?', fid)
          }

        end
      end
    end
  end
end

