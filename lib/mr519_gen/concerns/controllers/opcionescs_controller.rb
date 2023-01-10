# frozen_string_literal: true

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
              @opcioncs.valor = "N"
              if @opcioncs.save(validate: false)
                respond_to do |format|
                  format.js do
                    render(text: @opcioncs.id.to_s)
                  end
                  format.json do
                    render(json: @opcioncs.id.to_s, status: :created)
                  end
                end
              else
                render(inline: "No implementado", status: :unprocessable_entity)
              end
            else
              render(
                inline: "Falta id de campo",
                status: :unprocessable_entity,
              )
            end
          end

          def destroy
            return unless params[:id]

            @opcioncs = Opcioncs.find(params[:id])
            @opcioncs.destroy
            respond_to do |format|
              format.html do
                render(
                  inline: "No implementado",
                  status: :unprocessable_entity,
                )
              end
              format.json { head(:no_content) }
            end
          end
        end # included
      end
    end
  end
end
