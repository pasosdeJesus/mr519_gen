# frozen_string_literal: true

require "mr519_gen/concerns/models/respuestafor"

module Mr519Gen
  # Respuesta a un formulario, relaciona los campos del formulario con
  # los valores que una persona diligencia.
  class Respuestafor < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::Respuestafor
  end
end
