# frozen_string_literal: true

require "mr519_gen/concerns/models/opcioncs"

module Mr519Gen
  # Opción en un campo de selección
  class Opcioncs < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::Opcioncs
  end
end
