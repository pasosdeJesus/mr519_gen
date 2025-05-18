# frozen_string_literal: true

module Mr519Gen
  module Concerns
    module Controllers
      module CamposController
        extend ActiveSupport::Concern

        included do
          def destroy
          end

          def create
          end

          private

          def preparar_campo_formulario
            @registro = @formulario = Mr519Gen::Formulario.new(
              campo: [Mr519Gen::Campo.new],
            )
          end
        end # included
      end
    end
  end
end
