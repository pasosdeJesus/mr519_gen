# encoding: UTF-8
require_dependency "mr519_gen/concerns/controllers/formularios_controller"

module Mr519Gen
  class FormulariosController < Sip::ModelosController
    include Mr519Gen::Concerns::Controllers::FormulariosController
  end
end
