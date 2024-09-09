# frozen_string_literal: true

require "mr519_gen/concerns/models/planencuesta"

module Mr519Gen
  # Plan para una encuesta
  class Planencuesta < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::Planencuesta
  end
end
