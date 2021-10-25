require_dependency "mr519_gen/concerns/controllers/encuestaspersona_controller"

module Mr519Gen
  class EncuestaspersonaController < Sip::ModelosController

    load_and_authorize_resource class: Mr519Gen::Encuestapersona
    before_action :set_encuestapersona, 
      only: [:show, :edit, :update, :destroy]
    include Mr519Gen::Concerns::Controllers::EncuestaspersonaController
  end
end
