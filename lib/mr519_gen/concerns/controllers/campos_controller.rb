# frozen_string_literal: true

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
                  format.js do
                    render(text: @campo.id.to_s)
                  end
                  format.json do
                    render(json: @campo.id.to_s, status: :created)
                  end
                end
              else
                render(inline: "No implementado", status: :unprocessable_entity)
              end
            else
              render(
                inline: "Falta id de formulario",
                status: :unprocessable_entity,
              )
            end
          end

          def destroy
            return unless params[:id]

            @campo = Campo.find(params[:id])
            @campo.destroy
            respond_to do |format|
              format.html do
                render(
                  inline: "No implementado",
                  status: :unprocessable_entity,
                )
              end
              format.json do
                render(json: "", status: :ok)
              end
            end
          end
        end # included
      end
    end
  end
end
