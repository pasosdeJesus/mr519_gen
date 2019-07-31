# encoding: UTF-8

require 'mr519_gen/concerns/models/encuestapersona'

module Mr519Gen
  class Encuestapersona < ActiveRecord::Base
    include Mr519Gen::Concerns::Models::Encuestapersona
  end
end
