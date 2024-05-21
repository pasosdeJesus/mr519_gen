# frozen_string_literal: true

require "mr519_gen/concerns/controllers/campos_controller"

module Mr519Gen
  class CamposController < Msip::ModelosController
    before_action :preparar_campo_formulario
    load_and_authorize_resource class: Mr519Gen::Campo
    include Mr519Gen::Concerns::Controllers::CamposController
  end
end
