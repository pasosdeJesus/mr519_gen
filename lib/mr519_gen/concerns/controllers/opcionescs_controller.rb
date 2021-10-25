module Mr519Gen
  module Concerns
    module Controllers
      module OpcionescsController
        extend ActiveSupport::Concern

        included do

          # GET /opcionescs/new
          def new
            if params[:formulario_campo_id]
              @opcioncs = Opcioncs.new
              @opcioncs.campo_id = params[:formulario_campo_id]
              @opcioncs.nombre = "N"
              @opcioncs.valor= "N"
              if @opcioncs.save(validate: false)
                respond_to do |format|
                  format.js { 
                    render text: @opcioncs.id.to_s 
                  }
                  format.json { 
                    render json: @opcioncs.id.to_s, status: :created 
                  }
                end
              else
                render inline: 'No implementado', status: :unprocessable_entity 
              end
            else
              render inline: 'Falta id de campo', 
                status: :unprocessable_entity 
            end
          end

          def destroy
            if params[:id]
              @opcioncs = Opcioncs.find(params[:id])
              @opcioncs.destroy
              respond_to do |format|
                format.html { render inline: 'No implementado', 
                              status: :unprocessable_entity }
                format.json { head :no_content }
              end
            end
          end

        end #included

      end
    end
  end
end

