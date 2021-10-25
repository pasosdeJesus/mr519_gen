require 'mr519_gen/concerns/models/opcioncs'

module Mr519Gen
  class Opcioncs < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::Opcioncs
  end
end
