require_dependency "mr519_gen/concerns/controllers/formularios_controller"

module Mr519Gen
  class FormulariosController < Msip::ModelosController

    load_and_authorize_resource class: Mr519Gen::Formulario
    before_action :set_formulario, 
      only: [:show, :edit, :update, :destroy]

    include Mr519Gen::Concerns::Controllers::FormulariosController
  end
end
