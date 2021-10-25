require_dependency "mr519_gen/concerns/controllers/opcionescs_controller"

module Mr519Gen
  class OpcionescsController < Sip::ModelosController
    include Mr519Gen::Concerns::Controllers::OpcionescsController
  end
end
