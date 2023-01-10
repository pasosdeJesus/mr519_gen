# frozen_string_literal: true

require_dependency "mr519_gen/concerns/controllers/planesencuesta_controller"

module Mr519Gen
  class PlanesencuestaController < Msip::ModelosController
    load_and_authorize_resource class: Mr519Gen::Planencuesta
    include Mr519Gen::Concerns::Controllers::PlanesencuestaController
  end
end
