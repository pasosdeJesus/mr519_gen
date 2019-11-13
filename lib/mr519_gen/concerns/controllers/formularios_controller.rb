# encoding: UTF-8

module Mr519Gen
  module Concerns
    module Controllers
      module FormulariosController
        extend ActiveSupport::Concern

        included do

          before_action :set_formulario, 
            only: [:show, :edit, :update, :destroy]
          load_and_authorize_resource class: Mr519Gen::Formulario

          def clase
            "Mr519Gen::Formulario"
          end

          def genclase
            return 'M'
          end

          def atributos_index
            [ :id, 
              :nombre,
              :nombreinterno,
              :campos,
              #:opcionescs,
            ]
          end

          def atributos_form
            atributos_show - [:id]
          end

          def atributos_show
            atributos_index
          end

          def index_reordenar(c)
            c = c.reorder('mr519_gen_formulario.id')
            return c
          end

          # GET /formularios/new
          def new
            @registro = @formulario = Formulario.new
            @formulario.nombre = 'Formulario Nuevo'
            @formulario.nombreinterno = 'formulario_nuevo'
            @registro.save!(validate: false)
            @formulario.nombre += " " + @registro.id.to_s
            @formulario.nombreinterno += "_" + @registro.id.to_s
            @registro.save!(validate: false)
            redirect_to mr519_gen.edit_formulario_path(@registro)
          end

          def edit_mr519_gen
            @registro = Mr519Gen::Formulario.find(params[:id])
            authorize! :edit, @registro
            @registro.save!(validate: false)
          end

          # GET /formularios/1/edit
          def edit
            edit_mr519_gen
            render layout: 'application'
          end

          private

          def set_formulario
            @registro = @formulario = Formulario.find(
              Formulario.connection.quote_string(params[:id]).to_i
            )
          end

          def mr519_gen_params
            atributos_form + 
            [ 
                :campo_attributes => [
                :ancho,
                :ayudauso,
                :columna,
                :fila,
                :id,
                :nombre,
                :nombreinterno,
                :obligatorio,
                :tipo,
                :tablabasica,
                :_destroy,
                :opcioncs_attributes => [
                  :id,
                  :campo_id,
                  :nombre,
                  :valor,
                  :_destroy ]
              ],
            ]
          end

          def lista_params
            mr519_gen_params
          end

          # Lista blanca de parametros
          def formulario_params
            params.require(:formulario).permit(lista_params)
          end

        end # included do


      end
    end
  end
end


