# encoding: UTF-8

require 'mr519_gen/concerns/models/valorcampo'

module Mr519Gen
  class Valorcampo < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::Valorcampo
  end
end
