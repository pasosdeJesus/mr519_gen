# encoding: UTF-8
require_dependency "mr519_gen/concerns/controllers/encuestaspersona_controller"

module Mr519Gen
  class EncuestaspersonaController < Sip::ModelosController
    include Mr519Gen::Concerns::Controllers::EncuestaspersonaController
  end
end
