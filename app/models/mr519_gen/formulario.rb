# frozen_string_literal: true

require "mr519_gen/concerns/models/formulario"

module Mr519Gen
  # Modela un formulario con campos definibles por el usuario
  class Formulario < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::Formulario
  end
end
