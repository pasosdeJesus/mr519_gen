# encoding: UTF-8

module Mr519Gen
  module Concerns
    module Controllers
      module EncuestasusuarioController
        extend ActiveSupport::Concern

        included do

          before_action :set_encuestausuario, 
            only: [:show, :edit, :update, :destroy]
          load_and_authorize_resource class: Mr519Gen::Encuestausuario

          def clase
            "Mr519Gen::Encuestausuario"
          end

          def genclase
            return 'F'
          end

          def atributos_index
            [ :id, 
              :usuario,
              :formulario,
              :fecha_localizada, 
              :fechainicio_localizada, 
              :fechafin_localizada,
              :valorcampo
            ]
          end

          def atributos_form
            atributos_show - [:id]
          end

          def atributos_show
            atributos_index
          end

          def index_reordenar(c)
            c = c.reorder('mr519_gen_encuestausuario.fecha DESC')
            return c
          end

          # GET /encuestasusuario/new
          def new
            @registro = @encuestausuario = Encuestausuario.new
            @registro.usuario = current_usuario
            @registro.fechainicio = Date.today
            @registro.formulario = Mr519Gen::Formulario.new
            @registro.formulario.nombre = 'Encuesta'
            @registro.save!(validate: false)
            redirect_to mr519_gen.edit_encuestausuario_path(@registro)
          end

          def asegura_camposdinamicos(encuestausuario)
            if encuestausuario.nil? || encuestausuario.formulario.nil?
              return
            end
            ci = encuestausuario.formulario.campo_ids
            cd = encuestausuario.valorcampo.map(&:campo_id)
            sobran = cd - ci
            borrar = encuestausuario.valorcampo.where(campo_id: sobran).
              map(&:id)
            encuestausuario.valorcampo_ids -= borrar
            puts encuestausuario.valorcampo_ids 
            faltan = ci - cd
            faltan.each do |f|
              vc = Mr519Gen::Valorcampo.new(campo_id: f, valor: '')
              vc.save!(validate: false)
              evc = Mr519Gen::EncuestausuarioValorcampo.new(
                encuestausuario_id: encuestausuario.id, 
                valorcampo_id: vc.id)
              evc.save!(validate: false)
            end
          end

          def edit_mr519_gen
            @registro = Mr519Gen::Encuestausuario.find(params[:id])
            authorize! :edit, @registro
            asegura_camposdinamicos(@registro)
            @registro.save!(validate: false)
          end

          # GET /encuestasusuario/1/edit
          def edit
            edit_mr519_gen
            render layout: 'application'
          end

          private

          def set_encuestausuario
            @registro = @encuestausuario = Encuestausuario.find(
              Encuestausuario.connection.quote_string(params[:id]).to_i
            )
          end

          def lista_params
            l = atributos_form
            l[l.index(:usuario)] = :usuario_id
            l[l.index(:formulario)] = :formulario_id
            l += [ :valorcampo_attributes => [
              :id,
              :campo_id,
              :valor
            ] ]
            return l
          end

          # Lista blanca de parametros
          def encuestausuario_params
            params.require(:encuestausuario).permit(lista_params)
          end

        end # included do


      end
    end
  end
end


