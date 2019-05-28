# encoding: UTF-8

module Mr519Gen
  module Concerns
    module Controllers
      module CamposController
        extend ActiveSupport::Concern

        included do

          # GET /campos/new
          def new
            if params[:formulario_id]
              @campo = Campo.new
              @campo.formulario_id = params[:formulario_id]
              @campo.nombre = "N"
              @campo.save!(validate: false)
              @campo.nombre += "_" + @campo.id.to_s
              if @campo.save(validate: false)
                respond_to do |format|
                  format.js { 
                    render text: @campo.id.to_s 
                  }
                  format.json { 
                    render json: @campo.id.to_s, status: :created 
                  }
                end
              else
                render inline: 'No implementado', status: :unprocessable_entity 
              end
            else
              render inline: 'Falta id de formulario', 
                status: :unprocessable_entity 
            end
          end

          def destroy
            if params[:id]
              @campo = Campo.find(params[:id])
              @campo.destroy
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

