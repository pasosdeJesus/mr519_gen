require_dependency "mr519_gen/concerns/controllers/encuestasusuario_controller"

module Mr519Gen
  class EncuestasusuarioController < Sip::ModelosController

    load_and_authorize_resource class: Mr519Gen::Encuestausuario
    before_action :set_encuestausuario, 
      only: [:show, :edit, :update, :destroy]
    include Mr519Gen::Concerns::Controllers::EncuestasusuarioController
  end
end
