module Mr519Gen
  module Concerns
    module Controllers
      module PlanesencuestaController 
        extend ActiveSupport::Concern

        included do

          helper ::ApplicationHelper

          before_action :set_planencuesta, 
            only: [:show, :edit, :update, :destroy]

          def clase 
            "Mr519Gen::Planencuesta"
          end

          def atributos_index
            [
              :id,
              :formulario_id,
              :fechaini_localizada,
              :fechafin_localizada,
              :plantillacorreoinv_id,
              :encuestapersona
            ]
          end

          def atributos_form
            atributos_index - [:id]
          end

          def index_reordenar(registros)
            return registros.reorder(:id)
          end

          def new_modelo_path(o)
            return new_planencuesta_path()
          end

          def genclase
            return 'F'
          end


          private

          def set_planencuesta
            @registro = @planencuesta = Mr519Gen::Planencuesta.find(
              Mr519Gen::Planencuesta.connection.quote_string(params[:id]).to_i
            )
          end

          def lista_params
            atributos_form - [:id]
          end


          # No confiar parametros a Internet, sólo permitir lista blanca
          def planencuesta_params
            params.require(:planencuesta).permit(*lista_params)
          end

        end #included

      end
    end
  end
end


