# frozen_string_literal: true

require "mr519_gen/concerns/models/planencuesta"

module Mr519Gen
  # Plan para efectuar una encuesta (e.g. fechas de aplicación, formulario)
  class Planencuesta < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::Planencuesta
  end
end
