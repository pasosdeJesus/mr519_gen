require 'mr519_gen/concerns/models/planencuesta'

module Mr519Gen
  class Planencuesta < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::Planencuesta
  end
end
