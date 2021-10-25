require_dependency "mr519_gen/concerns/controllers/encuestasusuario_controller"

module Mr519Gen
  class EncuestasusuarioController < Sip::ModelosController
    include Mr519Gen::Concerns::Controllers::EncuestasusuarioController
  end
end
