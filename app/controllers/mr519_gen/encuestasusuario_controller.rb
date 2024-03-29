# frozen_string_literal: true

require "mr519_gen/concerns/controllers/encuestasusuario_controller"

module Mr519Gen
  class EncuestasusuarioController < Msip::ModelosController
    load_and_authorize_resource class: Mr519Gen::Encuestausuario
    before_action :set_encuestausuario,
      only: [:show, :edit, :update, :destroy]
    include Mr519Gen::Concerns::Controllers::EncuestasusuarioController
  end
end
