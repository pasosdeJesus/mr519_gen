# encoding: UTF-8
require_dependency "mr519_gen/concerns/controllers/campos_controller"

module Mr519Gen
  class CamposController < Sip::ModelosController
    include Mr519Gen::Concerns::Controllers::CamposController
  end
end
