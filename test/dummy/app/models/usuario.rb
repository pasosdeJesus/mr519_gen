# frozen_string_literal: true

require "mr519_gen/concerns/models/usuario"

class Usuario < ActiveRecord::Base
  include Mr519Gen::Concerns::Models::Usuario
end
