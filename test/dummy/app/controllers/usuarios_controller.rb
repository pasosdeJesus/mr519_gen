# frozen_string_literal: true

require "msip/concerns/controllers/usuarios_controller"

class UsuariosController < Msip::ModelosController
  include Msip::Concerns::Controllers::UsuariosController
end
