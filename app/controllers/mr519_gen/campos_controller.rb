require 'mr519_gen/concerns/controllers/campos_controller'

module Mr519Gen
  class CamposController < Sip::ModelosController

    load_and_authorize_resource class: Mr519Gen::Encuestausuario
    include Mr519Gen::Concerns::Controllers::CamposController
  end
end
