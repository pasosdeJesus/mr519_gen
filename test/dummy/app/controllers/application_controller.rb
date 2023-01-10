# frozen_string_literal: true

require "msip/application_controller"
class ApplicationController < Msip::ApplicationController
  # Previente ataques CSRF elevando una excepción
  # En el caso de APIs, en cambio puedes querer usar :null_session
  protect_from_forgery with: :exception
end
