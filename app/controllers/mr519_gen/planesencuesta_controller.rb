require_dependency "mr519_gen/concerns/controllers/planesencuesta_controller"

module Mr519Gen
  class PlanesencuestaController < Sip::ModelosController
    include Mr519Gen::Concerns::Controllers::PlanesencuestaController
  end
end
