# frozen_string_literal: true

module Mr519Gen
  module Concerns
    module Controllers
      module OpcionescsController
        extend ActiveSupport::Concern

        included do
          def create
          end

          def destroy
          end

          def update
          end

          private

          def preparar_opcion_campo_formulario
            @campo = Mr519Gen::Campo.new(opcioncs: [Mr519Gen::Opcioncs.new])
            @formulario = Mr519Gen::Formulario.new(campo: [@campo])
            @campo.opcioncs[0].campo = Mr519Gen::Campo.new
          end
        end # included
      end
    end
  end
end
