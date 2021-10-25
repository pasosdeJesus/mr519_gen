require_dependency "mr519_gen/concerns/controllers/planesencuesta_controller"

module Mr519Gen
  class PlanesencuestaController < Sip::ModelosController
    load_and_authorize_resource class: Mr519Gen::Planencuesta
    include Mr519Gen::Concerns::Controllers::PlanesencuestaController
  end
end
