# frozen_string_literal: true

require "mr519_gen/concerns/models/respuestafor"

module Mr519Gen
  class Respuestafor < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::Respuestafor
  end
end
