# frozen_string_literal: true

require "mr519_gen/concerns/models/encuestausuario"

module Mr519Gen
  class Encuestausuario < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::Encuestausuario
  end
end
