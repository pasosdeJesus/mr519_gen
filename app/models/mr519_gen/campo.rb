# frozen_string_literal: true

require "mr519_gen/concerns/models/campo"

module Mr519Gen
  # Un campo en un formulario, puede ser de diversos tipos (entero, fecha,
  # cadena, etc.)
  class Campo < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::Campo
  end
end
