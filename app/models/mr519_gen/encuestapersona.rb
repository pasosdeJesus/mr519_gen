# frozen_string_literal: true

require "mr519_gen/concerns/models/encuestapersona"

module Mr519Gen
  # Encuesta a una persona externa (i.e que no tiene cuenta en el sistema de
  # información)
  class Encuestapersona < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::Encuestapersona
  end
end
