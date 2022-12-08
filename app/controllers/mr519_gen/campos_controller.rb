require 'mr519_gen/concerns/controllers/campos_controller'

module Mr519Gen
  class CamposController < Msip::ModelosController

    load_and_authorize_resource class: Mr519Gen::Encuestausuario
    include Mr519Gen::Concerns::Controllers::CamposController
  end
end
